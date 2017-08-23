#!/usr/bin/perl
#
use strict;
use Chatbot::Eliza;
use POSIX ":sys_wait_h";
use IO::Socket::INET;

use constant PORT => 9900;

my $quit = 0;

$SIG{CHLD} = sub { while (waitpid(-1, WNOHANG) > 0) { print "sub process exit by value: $?\n"; } };

$SIG{INT} = sub { $quit++ };


# default autoflush is true
my $sock = IO::Socket::INET->new(
		Listen => 5,
		LocalAddr => 'localhost',
		LocalPort => PORT,
		Proto	  => 'tcp',
		Reuse	=> 1,
		Timeout => 3600
	);

die "create socket failed $@" unless $sock;

while (! $quit) {

	next unless my $conn_sock = $sock->accept();
	if (fork == 0) {
		$sock->close;
		print "get connect from ".$conn_sock->peerhost."\n";
		interact($conn_sock);
		exit 0;
	}
	$conn_sock->close
}

sub interact {
	my $conn_sock = shift;
	STDIN->fdopen($conn_sock, "<") or die "Can't reopen STDIN: $!";
	STDOUT->fdopen($conn_sock, ">") or die "Can't reopen STDOUT: $!";
	$| = 1;
	my $bot = Chatbot::Eliza->new;
	$bot->command_interface();
}

sub Chatbot::Eliza::_testquit {
	my ($self, $string) = @_;
	return 1 unless defined $string;
	return 1 if $string eq "quit" or $string eq "exit";
}
