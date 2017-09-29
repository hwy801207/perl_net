#!/usr/bin/env perl
# file web_fork.pl
use strict;
use warnings;
use Web;
use IO::Socket;
use IO::File;
use IO::Select;
use Daemon;


use constant PIDFILE => "/tmp/web_fork.pid";

my $DONE = 0;
$SIG{INT} = $SIG{TERM} = sub { $DONE++ };


my $port = shift || 8080;

my $socket = IO::Socket::INET->new(LocalPort => $port,
				   				   Listen	=> 200,
							   	   Reuse	=> 1,
							   	   )
									   or die "Can't create listen socket $!\n";
my $IN = IO::Select->new($socket);

init_server(PIDFILE);

warn "Listening for connections on port $port\n";
# accept loop

while (!$DONE) {
	next unless $IN->can_read;
	next unless my $c = $socket->accept;
	my $child = launch_child();
	unless ($child) {
		$socket->close;
		handle_connection($c);
		exit 0;
	}
	$c->close;
}

warn "Normal terminatation\n";

