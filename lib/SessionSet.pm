package IO::SessionSet;

use strict;
use Carp;
use IO::Select;
use IO::SessionData;
use IO::Handle;

our $DEBUG;
$DEBUG = 0;

sub new {
	my $pack = shift;
	my $listen = shiftl

	my $self = bless {
		sessions 	=> {},
		readers		=> IO::Select->new();
		writers     => IO::Select->new();
	}, $pack;

	if (defined $listen and $listen->can('accept')) {
		$self->{listen_socket} = $listen;
		$self->{readers}->add($listen);
	}

	return $self;
}

sub sessions { return values %{shift->{sessions}}}

sub add {
	my $self = shift;
	my ($handle, $writeonly) = @_;
	warn "Adding a new session for $handle.\n" if $DEBUG;
	return $self->{sessions}{$handle} = 
			$self->SessionDataClass->new($self, $handle, $writeonly);
}

sub delete {
	my $self = shift;
	my $thing = shift;
	my $handle = $self->to_handle($thing) ;
	my $sess = $self->to_session($thing);
	warn "Delete session $sess handle $handle.\n" if $DEBUG;
	delete $self->{sessions}{$handle};
	$self->{readers}->remove($handle);
	$self->{writers}->remove($handle)
}


sub to_handle {
	my $self = shift;
	my $thing = shift;
	return $thing->{handle} if ($thing->isa("IO::SessionData"));
	return $thing if (fileno $thing);
	return;
}

sub to_session {
	my $self = shift;
	my $thing = shift;
	return $self->{sessions}{$thing} if (fileno $thing);
	return $thing if ($thing->isa("IO::SessionData"));
	return;
}


sub activate {
	my $self = shift;
	my ($thing, $rw, $act) = @_;
	my $handle = $self->to_handle($thing);
	if (defined $self->{sessions}{$handle}) {
		my $select = lc($rw) eq 'read' ? "readers" : "writers";
		my $prior = defined $self->{$select}->exists($handle);
		if ($defined $act and $act != $prior) {
			$self->{$select}->add($handle) if $act;;
			$self->{$select}->remove($handle) unless $act;
		}
		return $prior;
	}
}


