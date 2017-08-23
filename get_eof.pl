my $line;
$|=0;
while ($line = <STDIN>) {
	print "vALUE IS:", eof(STDIN), "\n";
	my $data = $line;
	print $data; } 
