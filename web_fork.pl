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
				   				   Listen	=> 500,
							   	   Reuse	=> 1,
							   	   )
									   or die "Can't create listen socket $!\n";
my $IN = IO::Select->new($socket);

# 问题出在这里
init_server(PIDFILE);

log_warn "Listening for connections on port $port\n";
# accept loop

while (!$DONE) {
	log_warn("start loop ...");
	next unless $IN->can_read(0);
	log_warn("step here ....");
	next unless my $c = $socket->accept;
	log_warn("get connection from!!!");
	my $child = launch_child();
	unless ($child) {
		undef $socket;
		handle_connection($c);
		exit 0;
	}
	undef $c;
	log_warn("tail loog ...");
}

log_warn "Normal terminatation\n";

