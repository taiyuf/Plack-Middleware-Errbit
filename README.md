Plack::Middleware::Errbit
============

# NAME

Plack::Middleware::Hoptoad - Sends application errors to Hoptoad

# SYNOPSIS

    enable "Errbit", api_key => "...", host => "...", port => "...";

# DESCRIPTION

This middleware catches exceptions (run-time errors) happening in your application and sends them to <Hoptoad>.


# LICENSE

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

# SEE ALSO

Plack::Middleware::StackTrace
