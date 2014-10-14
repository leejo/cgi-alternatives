package CGI::Alternatives;

use strict;
use warnings;

our $VERSION = '0.12';

1;

=head1 NAME

CGI::Alternatives - Documentation for alternative solutions to CGI.pm

=for html
<a href='https://travis-ci.org/leejo/cgi-alternatives?branch=master'><img src='https://travis-ci.org/leejo/cgi-alternatives.svg?branch=master' alt='Build Status' /></a>
<a href='https://coveralls.io/r/leejo/cgi-alternatives?branch=master'><img src='https://coveralls.io/repos/leejo/cgi-alternatives/badge.png?branch=master' alt='Coverage Status' /></a>

=head1 VERSION

0.12

=head1 DESCRIPTION

This module doesn't do anything, it exists solely to document alternatives
to the L<CGI>.pm module.

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

=head1 NOTE ABOUT THE EXAMPLES

All of the following are functionally identical. They display a very simple
form with one text input box. When the form is submit it is redisplayed with
the original input displayed below the input box.

This example may be trivial, but that is the point. The frameworks shown here
feature a great deal of functionality for dealing with other parts of your
application and dealing with that in a maintainable way, with full separation
of concerns and easy testing.

All the examples are commented, where i feel it is necessary to highlight the
differences between the implementations, however i do not explain the details
of the frameworks - i would be duplicating the framework's docs if i did that,
so have a look at the links provided and investigate further.

All of the examples in this documentation can be found within the examples/
directory within this distribution. If you want to run them you will need to
install the necessary CPAN modules, these are not included as dependencies in
this distribution.

=head1 RAW CGI.pm EXAMPLES

This is the base script that will be re-implemented using the other frameworks

There are two versions - one that uses the HTML generation functions of CGI.pm
and one that uses Template Toolkit. This is where we get into the first issue
with CGI.pm - poor separation of concerns. CGI.pm (and cgi-lib.pl) existed years
before template engines were available in perl. As a consequence, to make the
generation of html easier, functions were added to output HTML direct from
scripts themselves. In doing this you immediately increase the maintenance
burden as any changes required to the HTML need to be done within the scripts.
You can't just hand a template to the web-designers and allow them to work their
magic. Don't mix the business logic and the presentation layer. Just don't.

=head2 CGI.pm With Inline HTML Functions

A simple example with form using the html generation functions of CGI.pm. Please
don't use these functions, i am merely showing them here for comparison reasons.

    #!/usr/bin/env perl

    # most CGI.pm scripts i encounter don't use strict or warnings.
    # please don't omit these, you are asking for a world of pain
    # somewhere down the line if you choose to develop sans strict
    use strict;
    use warnings;

    use CGI qw/ -utf8 /; 

    my $cgi  = CGI->new;
    my $res  = $cgi->param( 'user_input' );
    my $out  = $cgi->header(
        -type    => 'text/html',
        -charset => 'utf-8',
    );

    # html output functions. at best this is a lesson in obfuscation
    # at worst it is an unmaintainable nightmare (and i'm using
    # relatively clean perl code and a very very simple example here)
    $out .= $cgi->start_html( "An Example Form" );

    $out .= $cgi->start_form(
        -method  => "post",
        -action  => "/example_form",
    );

    $out .= $cgi->p(
        "Say something: ",
        $cgi->textfield( -name => 'user_input' ),
        $cgi->br,
        ( $res ? ( $cgi->br, "You wrote: $res" ) : () ),
        $cgi->br,
        $cgi->br,
        $cgi->submit,
    );

    $out .= $cgi->end_form;
    $out .= $cgi->end_html;

    print $out;

=head2 CGI.pm Using Template Toolkit

I'm including this example to show that it is easy to move the html
generation out of the raw CGI.pm script and into a template for better
separation of concerns.

    #!/usr/bin/env perl

    # most CGI.pm scripts i encounter don't use strict or warnings.
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

=head2 The Template File

Here's a key point - this template file will be re-used by B<all> the following
framework examples with absolutely no modifications. We can move between the
frameworks without having to do any porting of the HTML because it has been
divorced from the controller code. What did i say? Separation of concerns: win.

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

One important point to make is the action is /example_form, so the CGI.pm
scripts above would have to be called example_form or the webserver would
have to be setup to redirect routes to /example_form to whatever the cgi
script is called (cgi.pl and cgi_tt.pl in the examples/ directory)

Note that I have used L<Template::Toolkit> here, another excellent template
engine is L<Text::Xslate>. I would B<avoid> L<Mason>(2) and L<HTML::Template>.
Please don't write your own template engine.

=head1 PSGI/Plack

L<http://metacpan.org/release/PSGI>

L<http://metacpan.org/release/Plack>

L<http://plackperl.org/>

PSGI is an interface between Perl web applications and web servers, and Plack
is a Perl module and toolkit that contains PSGI middleware, helpers and
adapters to web servers.

Plack is a collection of building blocks to create web applications, ranging from
quick & easy scripts, to the foundations of building larger frameworks.

    #!/usr/bin/env perl

    use strict;
    use warnings;
    use feature qw/ state /;

    use FindBin qw/ $Bin /;
    use Template;
    use Plack::Request;
    use Plack::Response;

    my $app = sub {
        my $req = Plack::Request->new( shift );
        my $res = Plack::Response->new( 200 );

        state $tt  = Template->new({
            INCLUDE_PATH => "$Bin/templates",
        });

        my $out;

        $tt->process(
            "example_form.html.tt",
            {
                result => $req->parameters->{'user_input'},
            },
            \$out,
        ) or die $tt->error;

        $res->body( $out );
        $res->finalize;
    };

To run this script:

    plackup examples/plack_psgi.pl

That makes the script (the "app") available at http://*:5000

=head1 Mojolicious

CPAN: L<http://metacpan.org/release/Mojolicious>

Repo: L<http://github.com/kraih/mojo>

Home: L<http://mojolicio.us/>

Mojolicious is a feature rich modern web framework, with no none-core
dependencies. It is incredibly easy to get a web app up and running with
Mojolicious.

=head2 Mojolicious Lite App

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

That makes the page available at http://*:3000/example_form

=head2 Mojolicious Full App

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
thing. Run using:

    morbo examples/mojolicious.pl

=head2 Mojolicious Lite App Wrapping The CGI.pm Script(s)

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
scripts using a persistent webserver (e.g. mod_perl) then you will see a hit
in the performance because Mojolicious::Plugin::CGI will exec the cgi script
for each request. Run using:

    morbo examples/mojolicious_lite_plugin_cgi.pl

=head1 Dancer2

CPAN: L<https://metacpan.org/release/Dancer2>

Repo: L<https://github.com/PerlDancer/Dancer2>

Home: L<http://perldancer.org/>

L<Dancer2> is a rewrite of L<Dancer>, they share a lot in common but
i would recommend L<Dancer2> as it solved some issues with L<Dancer>

    #!/usr/bin/env perl

    # automatically enables strict and warnings
    use Dancer2;
     
    any [ 'get','post' ] => '/example_form' => sub {

        template 'example_form.html.tt', {
            'result' => params->{'user_input'}
        };
    };
     
    start;

Honestly that's just beautiful. The above example can be run with:

    perl examples/dancer2.pl

That makes the page available at http://*:3000/example_form

=head1 Catalyst

CPAN: L<https://metacpan.org/release/Catalyst-Runtime>

Repo: L<git://git.shadowcat.co.uk/catagits/Catalyst-Runtime.git>

Home: L<http://www.catalystframework.org/>

Catalyst is one of the older web frameworks in perl, but is still very popular,
actively maintained, and feature rich. It has a heavier dependency list than
the above frameworks, but this should not be taken as a negative point.

Catalyst is slightly more involved in that you have to set up your entire app
as the first step, this involved running:

    catalyst.pl example_form

Which will create the various directories and scripts for building/running your
app. You then need to add the necessary controllers, views, and templates. This
has all been done automatically through the use of the helper scripts that come
with Catalyst. The important bit, the actual example code, is just this in the
examples/example_form/lib/example_form/Controller/Root.pm controller:

    package example_form::Controller::Root;

    # automatically enables strict and warnings
    use Moose;
    use namespace::autoclean;

    BEGIN { extends 'Catalyst::Controller' }

    __PACKAGE__->config(namespace => '');

    sub example_form : Local {

        my ( $self,$c ) = @_;

        $c->stash(
            template => 'example_form.html.tt',
            result   => $c->req->params->{user_input},
        );
    }

    sub end : ActionClass('RenderView') {}

    __PACKAGE__->meta->make_immutable;

    1;

Then running the server:

    perl examples/example_form/script/example_form_server.pl

Again makes the page available at http://*:3000/example_form

=head1 Others

The three (four) examples above are the "big three", currently very popular
with great communities and support. There are other frameworks available:

L<https://metacpan.org/search?q=web+frameworks>

=head1 Dependency Handling

This is a whole other topic, but given CGI.pm is no longer in the perl core
you would have to install it anyway. It would be a good idea to do this the
right way from beginning. I'm not going to this in detail here, there are
many many good sources of information on the web. Here are some links to get
you started:

Managing perl:

L<https://github.com/tokuhirom/plenv>

L<http://perlbrew.pl/>

Managing perl modules:

L<https://metacpan.org/release/App-cpanminus>

L<https://metacpan.org/release/Carton>

L<https://metacpan.org/pod/Pinto>

L<https://stratopan.com/>

L<https://metacpan.org/release/local-lib>

=head1 SEE ALSO

L<Task::Kensho> - A Glimpse at an Enlightened Perl

=head1 AUTHOR INFORMATION

Lee Johnson - C<leejo@cpan.org> (LEEJO)

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. If you would like to contribute documentation
please raise an issue / pull request:

    https://github.com/leejo/cgi-alternatives

=cut
