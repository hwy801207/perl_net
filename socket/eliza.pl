use Chatbot::Eliza;

$|=1;

sub Chatbot::Eliza::_testquit {
	my ($self, $string) = @_;
	return 1 unless defined $string;
	foreach (@{$self->{quit}}) {
		return 1 if $string =~ /\b$_\b/i;
	}
}
my $bot = Chatbot::Eliza->new;

$bot->command_interface();
