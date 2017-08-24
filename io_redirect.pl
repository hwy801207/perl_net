$|=1;
open my $fd, "<", "cctv.txt";
open my $ofd, ">", "newcctv.txt";
select $ofd;

while (<STDIN>) {
	print STDOUT $_;
}

my $buffer;

my $bytes = read(STDIN, $buffer, 20);

if ($bytes == 20) {
	print $buffer;
}
else {
	print "--", $buffer;
}

# add a comment line
