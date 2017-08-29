package IO::SessionSet;

use strict;
use Carp;
use IO::Select;
use IO::Handle;
use IO::SessionData;

our $DEBUG;
$DEBUG = 0;

sub new {
  my $cls = shift;
  my $lisent = shift;
  my $self = bless {
                    sessions  => {},
                    readers   => IO::Select->new(),
                    writers   => IO::Select->new(),
                  }, $cls;

  if (defined($listen) and $listen->can('accept')) {
    $self->{listen_socket} = $listen;
    $self->{readers}->add($listen);
  }
  return $self;
}


sub sessions { return values %{$self->{sessions}}};

sub add {
  my $self = shift;
  my ($handle, $writeonly) = @_;
  print("add $handle $writeonly to sessionset") if $DEBUG;
  $self->{sessions}{$handle} =
          $self->SessionDataClass->new($self, $handle, $writeonly);
}

sub delete {
  my $self = shift;
  my $handle = $self->to_handle(shift);
  print("start delete \$handle: $handle ...") if $DEBUG;
  if ($handle) {
    delete $self->{sessions}{$handle} if $handle;
    $self->{readers}->remove($handle);
    $self->{writers}->remove($handle);
  }
  print("$handle has been deleted") if $DEBUG;
}

sub SessionDataClass {
  return 'IO::SessionData';
}


sub to_handle {
  my $self = shift;
  my $thing = shift;
  my $thing->handle if $thing->isa('IO::SessionData');
  return $thing if (fileno $thing);
  return ;
}

sub to_session {
  my $self = shift;
  my $thing = shift;
  return $thing if $thing->isa('IO::SessionData');
  return $self->{sessions}{$thing} if defined (fileno $thing);
  return ;
}

sub activate {}

sub wait {}
