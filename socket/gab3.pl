#!/usr/bin/perl

use strict;
use IO::Socket;

use constant BUFSIZE => 1024;

my $host = shift || 'localhost';
my $port = shift || 9900;
my $data;

my $socket = IO::Socket::INET->new("$host:$port");

die "connect to $host $port failed by $@" unless $socket;

my $child = fork;

if ($child) {
	$SIG{CHLD} = sub { exit 0};
	user_to_host($socket);
	$socket->shutdown(1);
	sleep;
}
else {
	host_to_user($socket);
	warn "Conn closed by foreign host: ".$socket->peerhost."\n";
}

sub user_to_host {
	my $s = shift;
	syswrite($s, $data) while sysread(STDIN, $data, BUFSIZE);
}

sub host_to_user {
	my $s = shift;
	syswrite(STDOUT, $data) while sysread($s, $data, BUFSIZE);
}
