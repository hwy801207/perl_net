#!/usr/bin/perl
use IO::Socket;
use IO::Select;
use Chatbot::Eliza::Polite;
use strict;
use warnings;


my %sessions;
use constant PORT => 9900;
my $listen_sock = IO::Socket::INET->new(LocalPort => PORT,
					Listen	  => 20,
					Proto	  => 'tcp',
					Reuse     => 1);
die $@ unless $listen_sock;
my $readers = IO::Select->new;

warn "Listening for connections";

while (1) {
	my @ready = $readers->can_read;
	for my $handle (@ready) {
		if ($handle eq $listen_sock) {
			my $connect = $listen_sock->accept();
			my $eliza = $sessions{$connect} = Chatbot::Eliza::Polite->new;
			syswrite($connect, $eliza->welcome);
			$readers->add($connect);
		}
		elsif (my $eliza = $sessions{$handle}) {
			my $user_input;
			my $bytes = sysread($handle, $user_input, 1024);

			if ($bytes > 0) {
				chomp $user_input;
				my $response = $eliza->one_line($user_input);
				syswrite($handle, $response);
			}

			if ( !$bytes or $eliza->done) {
				$readers->remove($handle);
				close $handle;
				delete $sessions{$handle};
			}
		}
	}
}


