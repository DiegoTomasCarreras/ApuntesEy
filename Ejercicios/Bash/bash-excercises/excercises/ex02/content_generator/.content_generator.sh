#!/bin/bash
content_generation() {
failcount=0
while [ 100  -ge $failcount ]
do
	sleep $(( RANDOM % 5))
	connection_status=$(( RANDOM ))
	echo "Connecting - $connection_status" >> applog.log
	if [[ $connection_status -gt 19000 ]]; then
		echo "Connection failed - Err Code $connection_status" >> applog.log
		let failcount=$failcount+1
		echo "Current failcount is $failcount"
	else
		echo "Connection successful - $connection_status" >> applog.log
	fi
done
}
content_generation
