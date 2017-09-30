#!/usr/bin/env bash

id=`cat /tmp/web_fork.pid`

if [[ $id > 0 ]];then
	kill -9 $id
	rm -rf /tmp/web_fork.pid
fi

perl -Ilib web_fork.pl
