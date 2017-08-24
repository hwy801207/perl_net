package IO::Getline;
use v5.18.0;
use IO::Handle;
use Carp qw'croak';
use Errno 'EWOULDBLOCK';
use constant READSIZE => 1024;

our $AUTOLOAD;
# return 0  eof
# return 0E0 if EWOULDBLOCK
# return
# return error if met error
sub new {
  my $cls = shift;
  my $handle = shift || croak "Usage: Readline->new(\$handle)";
  my $buffer = '';
  $handle->blocking(0);
  my $self = bless {
                    buffer    => $buffer,
                    handle    => $handle,
                    index     => 0,
                    eof       => 0,
                    error     => 0,
  }, $cls;

  return $self;
}


sub AUTOLOAD {
    my $self = shift;
    my $name = $AUTOLOAD =~ s/.*:://;
    eval { $self->{handle}->$name(@_) };
    carok $@ if $@;
}

sub read {
    my $self = shift;
    return 0 if $self->{eof};
    return if $self->{error};
    my $handle = $self->{handle};
    # 先读socket， 先改变状态，后判$断
    my $len = $handle->sysread($self->{buffer}, READSIZE, $self->{index});
    if (defined $len) {
          if ($len == 0) {
            $self->{eof}++;
            return 0;
          }
          else {
            my $index = index($self->{buffer}, $/, $self->{index});
            if ($index != -1){
              $_[0] = substr($self->{buffer}, 0, $index+length($/));
              substr($self->{buffer}, 0, $index+length($/)) = '';
              $self->{index} = 0;
            } else {
              $self->{index} += $len;
            }
            return length($_[0]);
       }
     }
      else {
        $self->{error} = $!;
        if ($! == EWOULDBLOCK) {
          return '0E0';
        }
        else {
          return;
        }
     }
}

sub eof {
  return shift->{eof};
}

sub error {
  return shift->{error};
}

sub flush {
    my $self = shift;
    $self->{buffer} = '';
    $self->{index} = 0;
}

1;
