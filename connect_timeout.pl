use IO::Socket;
use Errno qw/EWOULDBLOCK EINPROGRESS/;
use IO::Select;

sub connect_with_timeout {
  my ($host, $port, $timeout) = @_;
  my $sock = IO::Socket::INET->new( Proto   => 'tcp',
                                    Type    => SOCK_STREAM) or die $@;
  $sock->blocking(0); # non blocking

  my $addr = sockaddr_in($port, scalar inet_aton($host));
  my $result = $sock->connect($addr);
  unless($result) {
    die "Can't connect: $!" unless $! == EINPROGRESS;
    my $s = IO::Select->new($sock);
    die "Timeout!" unless $s->can_write($timeout);
    unless ($sock->connected) {
      $! = $sock->sockopt(SO_ERROR);
      die "Can't connect: $!";
    }
  }

  $sock->blocking(1);
  return $sock;
}
