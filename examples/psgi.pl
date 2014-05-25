#!perl

use strict;
use warnings;

use Plack::Request;

my $app = sub {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $params = $req->parameters;
    return [ 200,
		[ "Content-Type" => "text/plain" ],
		[ map { sprintf( "%s = %s\n",$_ => $params->get($_) ) } $params->keys ]
	];
};

Plack::Handler::CGI->new->run($app);
