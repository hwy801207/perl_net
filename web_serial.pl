#!/usr/bin/perl -w
use Web; 
use IO::Socket;

my $port = shift || 8080;
my $socket = IO::Socket::INET->new(LocalPort  => $port,
								   Listen	  => SOMAXCONN,
							   	   Reuse	  => 1)
								   or die "Can't create listen $!";


while (my $c = $socket->accept) {
	handle_connection($c);
	close $c;
}

close $socket;
