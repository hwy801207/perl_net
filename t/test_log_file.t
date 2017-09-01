use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More;

use_ok('LogFile');
can_ok('LogFile', 'init_log');
can_ok('LogFile', 'log_notice');
can_ok('LogFile', 'log_debug');
can_ok('LogFile', 'log_priority');
can_ok('LogFile', 'log_info');
done_testing(6);
init_log("test.log");
log_priority(WARNING);
log_debug("a debug log");
log_notice("a debug log");
