package Daemon;
use Base;
use Carp qw/croak cluck/;
use POSIX qw/:signal_h setsid WNOHANG/;
use IO::File;
use Carp::Heavy;
use File::Basename;
use Cwd;
use Sys::Syslog qw/:DEFAULT setlogsock/;
use Exporter qw/import/;

our @EXPORT= qw/init_server launch_child prepare_child
			    kill_children do_relaunch log_debug log_notice
				log_warn log_die %CHILDREN/;

our $VERSION = '1.00';

our %CHILDREN;
use constant PIDPATH => '/tmp';
use constant FACILITY => 'local0';

my ($pid, $pidfile, $logfile, $saved_dir, $CWD);

sub init_server {
	my ($user, $group);
	($pidfile, $user, $group) = @_;
	$pidfile ||= get_pid_filename();
	my $fh = open_pid_file($pidfile);
	become_daemon();
	print $fh $$;
	$fh->close;
	init_log();
	change_privileges($user, $group) if defined $user and defined $group;
	return $pid = $$;
}

sub become_daemon {
	die "Can't fork" unless defined (my $child = fork);
	exit 0 if $child;
	POSIX::setsid();  #become session leader
	open(STDIN, "<", "/dev/null");
	open(STDOUT, ">", "/dev/null");
	open(STDERR, ">&STDOUT");
	$CWD = getcwd;
	chdir '/';
	umask(0);
	$ENV{PATH} = '/bin:/sbin:/usr/bin:/usr/sbin';
	delete @ENV{'IFS', 'CDPATH', 'ENV', 'BASH_ENV'};
	$SIG{CHLD} = \&reap_child;
}

sub change_privileges {
	my ($user, $group) = @_;
	my $uid = ($user);
	my $gid = getgrnam($group);
	$) = "$gid $gid";
	$( = $gid;
	$> = $uid;
}

sub launch_child {
	my $callback = shift;
	my $home = shift;
	my $signals = POSIX::SigSet->new(SIGINT, SIGTERM, SIGCHLD, SIGHUP);
	sigprocmask(SIG_BLOCK, $signals);
	log_die("can't fork: $!") unless defined (my $child = fork());
	if ($child) {
		$CHILDREN{$child} = $callback || 1;
	} else {
		$SIG{HUP} = $SIG{INT} = $SIG{CHLD} = $SIG{TERM} = "DEFAULT";
		prepare_child($home);
	}
	sigprocmask(SIG_UNBLOCK, $signals);
	log_warn("child pid: $child");
	return $child;
}

sub prepare_child{
	my $home = shift;
	if ($home) {
		local($>, $<) = ($<, $>);
		chdir $home || croak "chdir failed $!";
		chroot $home || croak "chroot $home failed: $!";
	}
	$< = $>; # set real UID
}




sub get_pid_filename {
	my $basename = basename($0, '.pl');
	return PIDPATH . "/$basename.pid";
}

# pid 文件操作
sub open_pid_file {
	my $file = shift;
	if (-e $file) {
		my $fh = IO::File->new($file) || return;
		my $pid = <$fh>;
		croak "Invalid PID file" unless $pid =~ /^(\d+)$/;
		# 杀进程
		croak "Server already running with PID: $pid" if kill 0 => $pid;
		cluck "Removeing PID file for defunct server process $pid\n";
		# 删pid文件
		croak "Can't unlink PID file $file" unless -w $file && unlink $file
	}
	return IO::File->new($file, O_WRONLY|O_CREAT|O_EXCL, 0644)
		or die "Can't create $file: $!\n";
}

# 收割子进程
sub reap_child {
	while ((my $child = waitpid(-1, WNOHANG)) > 0) {
		$CHILDREN{$child}-> ($child) if ref $CHILDREN{$child} eq 'CODE';
		delete $CHILDREN{$child};
	}
}

# kill 子进程 
sub kill_children {
	kill TERM => keys %CHILDREN;
	# sleep 被信号中断，从而从循环中跳出来
	sleep while %CHILDREN;
}

# 重新运行程序
sub do_relaunch {
	$> = $<; # 有效用户替换为实际用户,获取了特权
	chdir $1 if $CWD =~  m#([./a-zA-Z0-9_-]+)#;
	croak "bad program name" unless $0 =~ m#([a-zA-Z0-9_-])#;
	my $program = $1;
	my $port = $1 if $ARGV[0] =~ /(\d+)/;
	unlink $pidfile;
	exec 'perl', '-T', $program, $port or croak "Could not exec: $!";
}

# 利用系统日志
sub init_log {
	setlogsock('unix');
	my $basename = basename($0);
	openlog($basename, 'pid', FACILITY);
	$SIG{__WARN__} = \&log_warn;
	$SIG{__DIE__} = \&log_die;
}

sub log_debug { syslog('debug', _msg(@_))}
sub log_notice { syslog('notice', _msg(@_))}
sub log_warn{ syslog('warning', _msg(@_))}
sub log_die {
	syslog('crit', _msg(@_)) unless $^S;
	die @_;
}

sub _msg {
	my $msg = join('', @_) || "Something's wrong";
	my ($pack, $filename, $line) = caller(1);
	$msg .= " at $filename line $line\n" unless $msg =~ /\n$/;
	$msg;
}

END { 
	$> = $<; # regain privileges
	unlink $pidfile if defined $pid and $$ == $pid 
}

1;

__END__
