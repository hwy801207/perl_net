package Base;
use strict;
use warnings;
use feature (); 
use Exporter;
use LogFile;

sub import {
	strict->import;
	warnings->import;
	feature->import(':5.10');
	LogFile->import;
}

1
