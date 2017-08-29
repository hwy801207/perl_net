use strict;
use IO::Socket;
use IO::Select;
use HTTPFetch;

my %CONNECTIONS;

my $readers = IO::Select->new;
my $writers = IO::Select->new;

while (my $url = shift) {
  next unless my $object = HTTPFetch->new($url);
  $CONNECTIONS{$object->socket} = $object;
  $writers->add($object->socket);
}

while ( my ($readable, $writable) = IO::Select->select($readers, $writers)) {
  foreach (@$writable) {
    my $obj = $CONNECTIONS{$_};
    my $result = $obj->send_request;
    $readers->add($_) if $result;
    $writable->remove($_);
  }
  foreach (@$readable) {
    my $obj = $CONNECTIONS{$_};
    my $result = $obj->read;
    unless ($result) {
      $readers->remove($_);
      delete $CONNECTIONS{$_};
    }
  }
  last unless $readers->count or $writers->count;
}
