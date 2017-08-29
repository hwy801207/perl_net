use strict;
use Chatbot::Eliza::Polite;
use IO::Socket;
use IO::LineBufferedSet;


my %SESSIONS;

use constant PORT => 12000;

my $listen_socket = IO::Socket::INET->new(LocalPort => PORT,
                                          Listen    => 20,
                                          Proto     => 'tcp',
                                          Reuse     => 1,);

my $sessions = IO::LineBufferedSet->new($listen_socket);
while (1) {
  my @ready = $sessions->wait();
  if (@ready > 0) {
    for my $conn (@ready) {
      my $eliza;
      if (!($eliza = $SESSIONS{$conn})) {
        $eliza = $SESSIONS{$conn} = new Chatbot::Eliza::Polite;
        $conn->write($eliza->welcome);
        next;
      }

      # if we get here
      my $user_input;
      my $bytes = $conn->getline($user_input);
      if ($bytes > 0) {
        chomp($user_input);
        $conn->write($eliza->one_line($user_input));
      }
      $conn->close if !$bytes || $eliza->done;
    }
  }
}
