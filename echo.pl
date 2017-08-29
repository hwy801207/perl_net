use strict;
use IO::SessionSet;
use IO::Socket;

use constant PORT => 10240;

my $listen_socket = IO::Socket::INET->new(LocalPort => PORT,
                                          Listen    =>20,
                                          Proto     => 'tcp',
                                          Reuse     => 1);

my $session_set = IO::SessionSet->new($listen_socket);

warn "Listen for connection ....\n";

while (1) {
    my @ready = $session_set->wait();

    for my $session (@ready) {
      my $data;
      if (my $rc = $session->read($data, 1024)) {
        $session->write($data) if $rc > 0;
      }
      else {
        $session->close;
      }
    }
}
