#!/usr/bin/env perl

# automatically enables "strict", "warnings", "utf8" and perl 5.16 features
use Mojolicious::Lite -signatures;
use Mojolicious::Plugin::TtRenderer;

# automatically render *.html.tt templates
plugin 'tt_renderer';

any '/example_form' => sub ($c) {
    $c->stash(
        result => $c->param( 'user_input' )
    );
};

app->start;
