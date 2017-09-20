package Daemon;
use Base;
use LogFile;
use Carp qw/croak cluck/;
use POSIX qw/setsid WNOHANG/;
use IO::File;

use constant PIDPATH => '/tmp/';

my ($pid, $pidfile, $logfile);

sub init_server {
	$pidfile = shift || get_pid_filename();
	$logfile = shift;
	my $fh = open_pid_file($pidfile);
	become_daemon();
	print $fh $$;
	close $fh;
	init_log($logfile);
	return $pid = $$;
}

sub become_daemon {
	die "Can't fork" unless defined (my $child = fork);
	exit 0 if $child;
	setsid();  #become session leader
	open(STDIN, "<", "/dev/null");
	open(STDOUT, ">", "/dev/null");
	open(STDERR, ">&", STDOUT);
	chdir '/';
	$ENV{PATH} = '/bin:/sbin:/usr/bin:/usr/sbin';
	$SIG{CHLD} = \&reap_child;
}

sub get_pid_filename {
	my $basename = basename($0, '.pl');
	return PIDPATH . "$basename.pid";
}

sub open_pid_file {
	my $file = shift;
	if (-e $file) {
		my $fh = IO::File->new($file) || return;
		my $pid = <$fh>;
		croak "Server already running with PID: $pid" if kill 0 => $pid;
		croak "Can't unlink PID file $file" unless -w $file && unlink $file;
	}

	return IO::File->new($file, O_WRONLY|O_CREAT|O_EXCL, 0644)
			or die "Can't create $file: $!\n";
}


sub reap_child {
	do {} while waitpid(-1, WNOHANG) > 0;
}

END { unlink $pidfile if defined $pid and $$ == $pid }

1;
