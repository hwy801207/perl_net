#!/usr/bin/perl

print "Redirecting STDOUT\n";
open my $saveout, ">&", STDOUT;
open STDOUT, ">", "test.txt";

print "STDOUT is redirected\n";
system "date";

open STDOUT, ">&", $saveout;
print "STDOUT restored\n";
