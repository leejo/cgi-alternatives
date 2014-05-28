package CGI::Alternatives;

use strict;
use warnings;

our $VERSION = '0.02';

1;

=head1 NAME

CGI::Alternatives - Documentation for alternative solutions to CGI.pm

=head1 VERSION

0.01

=head1 DESCRIPTION

This module doesn't do anything, it exists solely to document alternatives
to the L<CGI> module. This documentation is a work in progress, an example
script will be shown in raw CGI.pm and then the equivalent implementation
for each alternative will be shown. Resources to further information and
documentation will also be included.

=head1 BUT WHY?

CGI.pm hasn't been considered good practice for many years, and there have
been alternatives available for web development in perl for a long time.
Despite this there are still some perl developers that will recommend the
use of CGI.pm for web development and prototyping. The two main arguments
for the use of CGI.pm, often given by those developers, are no longer true:

1) "CGI.pm is a core module so you don't have install anything extra." This
is now incorrect:

	http://perl5.git.perl.org/perl.git/commitdiff/e9fa5a80

If you are doing any serious web development you are going to have to use
external dependencies, DBI is not in the core for example.

2) "CGI.pm scripts are shorter and simpler than alternative implementations."
Again, not true and the following examples will show that.

=head1 PSGI

=head1 Plack

=head1 Mojolicious

=head1 Dancer

=head1 Catalyst

=head1 Others

=head1 Dependency Handling

=head1 AUTHOR INFORMATION

Lee Johnson - C<leejo@cpan.org>

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=head1 SEE ALSO

=cut
