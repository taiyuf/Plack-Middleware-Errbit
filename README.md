# NAME

Plack::Middleware::Errbit - Sends application errors to Errbit.

[![Build Status](https://travis-ci.org/taiyuf/Plack-Middleware-Errbit.png?branch=master)](https://travis-ci.org/taiyuf/Plack-Middleware-Errbit)

# SYNOPSIS

    enable "Errbit", api_key => "...", host => "...", port => "...", path => "...";

    the default value of path is "/notifier_api/v2/notices".

# DESCRIPTION

This middleware catches exceptions (run-time errors) happening in your
application and sends them to [Errbit](https://github.com/errbit/errbit).


# AUTHOR

Taiyu Fujii

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO

- [Plack::Middleware::Hoptoad](https://github.com/miyagawa/Plack-Middleware-Hoptoad)
- [Plack::Middleware::StackTrace](http://search.cpan.org/~miyagawa/Plack-1.0030/lib/Plack/Middleware/StackTrace.pm)
