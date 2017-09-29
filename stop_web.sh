#!/bin/bash

id=`cat web_fork.pl`

if [[ $id > 0 ]];then
	kill -9 $id
	rm -rf /tmp/web_fork.pid
fi

perl -Ilib web_fork.pl
