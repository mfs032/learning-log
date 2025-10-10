#!/bin/bash
seq 1 2 99



for i in $(seq 1 99); do
	if [ $((i % 2)) -ne 0 ]; then
		echo &i
	fi
done

i=1
while [ $i -lt 99 ]; do
	echo $i
	i=$(expr $i + 2)
done