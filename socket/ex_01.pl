#!/usr/bin/perl
#
use POSIX ":sys_wait_h";
use IO::Socket::INET;

# default autoflush is true
my $sock = IO::Socket::INET->new(
		Listen => 5,
		LocalAddr => 'localhost',
		LocalPort => 9900,
		Proto	  => 'tcp'
	);


while (1) {
	my $new_sock = $sock->accept();
	if (fork == 0) {
		print "get connect from ".$new_sock->peerhost."\n";
		$sock->close;
		while (1) {
		my $ret = $new_sock->syswrite("hello");
		if ($ret == length("hello")) {
			# 多个子进程一起打标准输出的日志
			print "all data is send\n";
		}
		sleep 1;
	}
}
}

# how to get all sub process status?
