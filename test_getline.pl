use strict;
use IO::Getline;
use IO::Select;

my $s = IO::Select->new(\*STDIN);
my $readline = IO::Getline->new(\*STDIN);
my $line;
while ($s->can_read) {
	my $ret = $readline->read($line) || last;
	print $line if $ret > 0;
}

