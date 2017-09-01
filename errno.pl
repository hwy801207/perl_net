my $result = open my $fd, ">", "/etc/passwd";
print $! if $!;
print "\n";


# add error line
#
sub add {
	my $x = 5 + $y;
	print $x, "\n";
	my $y = 10;
	print $x, "\n";
}

add();
