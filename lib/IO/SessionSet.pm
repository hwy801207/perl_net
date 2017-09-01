package IO::SessionSet;
use strict;
use IO::Socket;
use IO::Select;
use Carp qw/croak/;

sub new {
	my $cls = shift;
	my $port = shift;
	my $sessions = {};
	return bless { listen => IO::Socket::INET->new({ Localhost => '127.0.0.1',
													 Localport => $port,
												 	 Proto     => 'tcp',
												     Reuse     => 1}
											 ),
				   sessions => $sessions;
				   }, cls;
}

sub listen { return $_[0]->{listen} }

sub wait {
	my $self = shift;
	my $select = shift;
	while (1) {
		my @ready = $select->can_read(0);
		foreach my $sock (@ready) {
			if ($sock == $self->listen) {
				my $conn = $sock->accept()
				$self->{sessions}{fileno $sock } = IO::SessionData->new($self, $sock, 0);
			}
			else {
				if (exists($self->{sessions}{fileno $sock})) {

				}
				else {
					$self-
				}
			}
		}
	}
}
