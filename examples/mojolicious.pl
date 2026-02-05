#!/usr/bin/env perl

# in reality this would be in a separate file
package ExampleApp;

# automatically enables "strict", "warnings", "utf8" and perl 5.16 features
use Mojo::Base 'Mojolicious', -signatures;

sub startup ($self) {
    $self->plugin( 'tt_renderer' );

    $self->routes->any('/example_form')
        ->to('ExampleController#example_form');
}

# in reality this would be in a separate file
package ExampleApp::ExampleController;

use Mojo::Base 'Mojolicious::Controller', -signatures;

sub example_form ($self) {
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
