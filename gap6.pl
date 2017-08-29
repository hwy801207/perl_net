#!/usr/bin/perl

use strict;
use IO::Socket;
use IO::SessionSet;

$IO::SessionSet::DEBUG = 0;

my $host = shift or die "Usage gab6.pl host [port]\n";
my $port = shift || 'echo';

my $socket = IO::Socket::INET->new("$host:$port");
my $set = IO::SessionSet->new or die;

my $connection = $set->add($socket);
my $stdin      = $set->add(\*STDIN);
my $stdout     = $set->add(\*STDOUT);


$stdout->set_choke(sub {
  my ($session, $do_choke) = @_;
  $connection->readable(!$do_choke);
});

$connection->set_choke(sub {
  my ($sesson, $do_choke) = @_;
  $stdin->readable(!$do_choke);
});

my $data;

while ($set->sessions)  {
  my @ready = $set->wait();

  foreach (@ready) {
    if ($_ eq $connection) {
      if (my $bytes = $connection->read($data, 1024)) {
        $stdout->write($data) if $bytes > 0;
      }
      else {
        warn "connection terminated by remote host\n";
        $connection->close;
        $stdout->close;
        $stdin->close;
      }
    }
    if ($_ eq $stdin) {
        if (my $bytes = $stdin->read($data, 1024)) {
          $connection->write($data) if $bytes > 0;
        }
        else {
          $connection->handle->shutdown(1);
        }
    }
  }
}
