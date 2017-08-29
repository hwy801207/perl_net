use strict;
use warnings;

use DB::Schema;

my $schema = DB::Schema->connect(
  "dbi:Pg:dbname=testdb;host=192.168.2.3",
  "hwy",
  "hwy",
  { RaiseError => 1, PrintError => 0},
);
#print $schema->data_sources;
#$schema->deploy({add_drop_table => 1});
my $customer_rs = $schema->resultset('Customer');
my $order_rs = $schema->resultset('Order');

# $customer_rs->create({
  # customer_id => 1,
  # first_name  => 'weiyi',
  # last_name   => 'huang'
# });
# my @rs = $customer_rs->all;
foreach (1..10) {
  $order_rs->create({
    order_id => $_,
    number   => $_,
    delivered => 1,
    total     => $_ + 2.0,
    customer_id => 1
  });
}
while (my $customer = $customer_rs->next) {
  my $orders_rs = $customer->orders;
  my $total = 0;
  while (my $order = $orders_rs->next) {
    $total += $order->total;
  }
  printf "Customer: %40s total %0.2f\n", $customer->full_name, $total;
}
