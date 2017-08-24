my $result = open my $fd, ">", "/etc/passwd";
print $! if $!;
print "\n";

# add error line
