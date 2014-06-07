# NAME

CGI::Alternatives - Documentation for alternative solutions to CGI.pm

# VERSION

0.03

# DESCRIPTION

This module doesn't do anything, it exists solely to document alternatives
to the [CGI](https://metacpan.org/pod/CGI).pm module. This documentation is a work in progress, an example
script will be shown in raw CGI.pm and then the equivalent implementation
for each alternative will be shown. Resources to further information and
documentation will also be included.

# BUT WHY?

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

# NOTE ABOUT THE EXAMPLES

All of the following are functionally identical. They display a very simple
form with one text input box. When the form is submit it is redisplayed with
the original input displayed below the input box.

All the examples are commented, however i do not explain the details of the
frameworks - i would be duplicating the framework's docs if i did that, so
have a look at the links provided and investigate further.

All of the examples in this documentation can be found within the examples/
directory within this distribution.

# RAW CGI.pm EXAMPLES

This is the base script that will be re-implemented using the other frameworks

There are two versions - one that uses the HTML generation functions of CGI.pm
and one that uses Template Toolkit. This is where we get into the first issue
with CGI.pm - poor separation of concerns.

## CGI.pm With Inline HTML Functions

## CGI.pm Using Template Toolkit

I'm including this example to show that it is easy to move the html
generation out of the raw CGI.pm script and into a template for better
separation of concerns

    #!/usr/bin/env perl

    # most CGI.pm scripts i encounter don't use script or warnings.
    # please don't omit these, you are asking for a world of pain
    # somewhere down the line if you choose to develop sans strict
    use strict;
    use warnings;

    use FindBin qw/ $Script $Bin /;
    use Template;
    use CGI qw/ -utf8 /; 

    # necessary objects
    my $cgi = CGI->new;
    my $tt  = Template->new({
        INCLUDE_PATH => "$Bin/templates",
    });

    # the user input
    my $res = $cgi->param( 'user_input' );

    # we're using TT but we *still* need to print the Content-Type header
    # we can't put that in the template because we need it to be reusable
    # by the various other frameworks
    my $out = $cgi->header(
        -type    => 'text/html',
        -charset => 'utf-8',
    );

    # TT will append the output to the passed referenced SCALAR
    $tt->process(
        "example_form.html.tt",
        {
            result => $res,
        },
        \$out,
    ) or die $tt->error;

    print $out;

## The Template File

Here's a key point - this template file will be re-used by **all** the following
framework examples with absolutely no modifications. We can move between the
frameworks without having to do any porting of the HTML because it has been
divorced from the controller code

    <html>
        <meta charset="utf-8"> 
        <head>An Example Form</head>
        <body>
            <form action="/example_form" method="post">
                <p>
                Say something: <input name="user_input" type="text" /><br />
                [% IF result %]
                    <br />You wrote: [% result %]
                [% END %]
                <br />
                <br />
                <input type="submit" />
                </p>
            </from>
        </body>
    </html>

One important point to make is the action is /example\_form, so the CGI.pm
scripts above would have to be called example\_form or the webserver would
have to be setup to redirect routes to /example\_form to whatever the cgi
script is called (cgi.pl and cgi\_tt.pl in the examples/ directory)

# PSGI

[http://metacpan.org/pod/PSGI](http://metacpan.org/pod/PSGI)

# Plack

[http://metacpan.org/pod/Plack](http://metacpan.org/pod/Plack)

# Mojolicious

[http://metacpan.org/pod/Mojolicious](http://metacpan.org/pod/Mojolicious)

[http://mojolicio.us/](http://mojolicio.us/)

Mojolicious is a feature rich modern web framework, with no none-core
dependencies. It is incredibly easy to get a web app up and running with
Mojolicious.

## Mojolicious Lite App

Note that we are using the TtRenderer plugin here, as by default Mojolicious
uses its own .ep format

    #!/usr/bin/env perl

    # automatically enables "strict", "warnings", "utf8" and perl 5.10 features
    use Mojolicious::Lite;
    use Mojolicious::Plugin::TtRenderer;

    # automatically render *.html.tt templates
    plugin 'tt_renderer';

    any '/example_form' => sub {
        my ( $self ) = @_;
        $self->stash(
            result => $self->param( 'user_input' )
        );
    };

    app->start;

To run this script (and all the following Mojolicious examples):

    morbo examples/mojolicious_lite.pl

That makes the routes available at http://\*:3000 - you don't need another
weberver

## Mojolicious Full App

    #!/usr/bin/env perl

    # in reality this would be in a separate file
    package ExampleApp;

    # automatically enables "strict", "warnings", "utf8" and perl 5.10 features
    use Mojo::Base qw( Mojolicious );

    sub startup {
        my ( $self ) = @_;

        $self->plugin( 'tt_renderer' );

        $self->routes->any('/example_form')
            ->to('ExampleController#example_form');
    }

    # in reality this would be in a separate file
    package ExampleApp::ExampleController;

    use Mojo::Base 'Mojolicious::Controller';

    sub example_form {
        my ( $self ) = @_;

        $self->stash(
            result => $self->param( 'user_input' )
        );

        $self->render( 'example_form' );
    }

    # in reality this would be in a separate file
    package main;

    use strict;
    use warnings;

    use Mojolicious::Commands;

    Mojolicious::Commands->start_app( 'ExampleApp' );

This is a "full fat" version of the app in Mojolicious, as stated in the
comments you would split the packages out into separate files in the real
thing

## Mojolicious Lite App Wrapping The CGI.pm Script(s)

    #!/usr/bin/env perl

    # automatically enables "strict", "warnings", "utf8" and Perl 5.10 features
    use Mojolicious::Lite;
    use Mojolicious::Plugin::CGI;
    use FindBin qw/$Bin/;

    plugin CGI => [ '/example_form' => "examples/cgi_tt.pl" ];

    app->start;

This is an interesting example - we can wrap the existing CGI.pm scripts with
Mojolicious and then add new routes to the Mojolicious app - this gives us a
migration path. There is one thing to consider - if you are serving your cgi
scripts using a persistent webserver (e.g. mod\_perl) then you will see a hit
in the performance because Mojolicious::Plugin::CGI will exec the cgi script
for each request.

# Dancer

[http://metacpan.org/pod/Dancer](http://metacpan.org/pod/Dancer)

# Catalyst

[http://metacpan.org/pod/Catalyst](http://metacpan.org/pod/Catalyst)

# Others

[https://metacpan.org/search?q=web+frameworks](https://metacpan.org/search?q=web+frameworks)

# Dependency Handling

# AUTHOR INFORMATION

Lee Johnson - `leejo@cpan.org`

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

# SEE ALSO
