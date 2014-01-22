package Plack::Middleware::Errbit;

use strict;
use warnings;
use 5.008_001;
our $VERSION = "0.01";

use parent qw(Plack::Middleware);
use Devel::StackTrace;
use Try::Tiny;
use Plack::Util::Accessor qw(api_key host port);

use AnyEvent::HTTP ();
use XML::Generator;
use Plack::Request;

sub call {
    my($self, $env) = @_;

    my($trace, $exception);
    local $SIG{__DIE__} = sub {
        $trace = Devel::StackTrace->new;
        $exception = $_[0];
        die @_;
    };

    my $res = try { $self->app->($env) };

    if ($trace && (!$res or $res->[0] == 500)) {
        $self->send_exception($trace, $exception, $env);
        $res = [500, ['Content-Type' => 'text/html'], [ "Internal Server Error" ]];
    }

    # break $trace here since $SIG{__DIE__} holds the ref to it, and
    # $trace has refs to Standalone.pm's args ($conn etc.) and
    # prevents garbage collection to be happening.
    undef $trace;

    return $res;
}

sub send_exception {
    my($self, $trace, $exception, $env) = @_;

    my $req = Plack::Request->new($env);

    my $error  = $trace->frame(1);
    my @frames = $trace->frames;
    shift @frames;

    my $api_key            = "api-key";
    my $cgi_data           = "cgi-data";
    my $server_environment = "server-environment";
    my $project_root       = "project-root";
    my $environment_name   = "environment-name";
    my $port               = $self->port ? ':' . $self->port : '';
    my $uri                = $self->host . $port . '/notifier_api/v2/notices';

    my $x = XML::Generator->new;

    my $var_dump = sub {
        my $hash = shift;
        map $x->var({ key => $_ }, $hash->{$_}), keys %$hash;
    };

    my $xml = $x->notice(
        { version => '2.0' },
        $x->$api_key($self->api_key),
        $x->notifier(
            $x->name(__PACKAGE__),
            $x->version($VERSION),
            $x->url("http://search.cpan.org/dist/Plack-Middleware-Errbit"),
        ),
        $x->error(
            $x->class(ref($exception) || "Perl"),
            $x->message("$exception"),
            $x->backtrace(
                map $x->line({
                    method => $_->subroutine,
                    file   => $_->filename,
                    number => $_->line,
                }), @frames
            ),
        ),
        $x->request(
            $x->url($req->uri->as_string),
            $x->component(''),
            $x->action($req->uri->path),
            $x->$cgi_data( $var_dump->($env) ), # filter?
            ( keys %{$req->parameters}    ? $var_dump->($req->parameters) : () ),
            ( keys %{$req->session || {}} ? $var_dump->($req->session) : () ),
        ),
        $x->$server_environment(
            $x->$project_root("/"),
            $x->$environment_name($ENV{PLACK_ENV} || 'development'),
        ),
    );

    warn "xml: " . $xml;

    my $cv = AE::cv;

    AnyEvent::HTTP::http_post $uri,
        $xml, headers => { 'Content-Type' => 'text/xml' }, $cv;

    $cv->recv unless $env->{'psgi.nonblocking'};
}

1;

__END__

=head1 NAME

Plack::Middleware::Errbit - Sends application errors to Errbit

=head1 SYNOPSIS

  enable "Errbit", api_key => "...", host => "...", port => "...";

=head1 DESCRIPTION

This middleware catches exceptions (run-time errors) happening in your
application and sends them to L<Errbit|https://github.com/errbit/errbit>.

=head1 AUTHOR

Taiyu Fujii

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Plack::Middleware::StackTrace>

=cut
