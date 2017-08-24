package Chatbot::Eliza::Polite;
use base Chatbot::Eliza;

sub welcome {
	my $self = shift;
	$self->botprompt($self->name.":\t");
	$self->userprompt("you:\t");

	return join('',
			$self->botprompt,
			$self->{initial}-> [int rand scalar @{ $self->{initial}}],
			"\n",
			$self->userprompt);
}

sub one_line {
	my $self = shift;
	my $in = shift;
	my $reply;

	if ($self->_testquit($in)) {
		$reply = $self->{final}->[int rand scalar @{ $self->{final} } ];
		$self->{_quit}++;
		return $reply . "\n";
	}
	$reply = $self->transform($in);

	return join('',
			$self->botprompt,
			$replay, "\n",
			$self->userprompt );

}

sub done { return shift->{_quit} }

1;
