#!/usr/bin/env perl

# automatically enables "strict", "warnings", "utf8" and Perl 5.16 features
use Mojolicious::Lite;
use Mojolicious::Plugin::CGI;
use FindBin qw/$Bin/;

plugin CGI => [ '/example_form' => "examples/cgi_tt.pl" ];

app->start;
