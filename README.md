# NAME

Plack::Middleware::Errbit - Sends application errors to Errbit

# SYNOPSIS

    enable "Errbit", api_key => "...", host => "...", port => "...";

# DESCRIPTION

This middleware catches exceptions (run-time errors) happening in your
application and sends them to [Errbit](https://github.com/errbit/errbit).

# AUTHOR

Taiyu Fujii

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO

[Plack::Middleware::StackTrace](https://metacpan.org/pod/Plack::Middleware::StackTrace)
