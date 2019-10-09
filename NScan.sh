#!/bin/bash

function ip_next {
	IP=$1
	
	IFS=. read -r -a OCTETS <<< $IP

	if [[ ${OCTETS[0]} -gt 255 || ${OCTETS[1]} -gt 255 || ${OCTETS[2]} -gt 255 || ${OCTETS[3]} -gt 255 ]]; then
		retval=""
		return 1; 
	fi

	for i in 3 2 1 0; do
		OCTETS[$i]=$((${OCTETS[$i]} + 1))
		
		if [ ! ${OCTETS[$i]} -gt 255 ]; then
			retval="${OCTETS[0]}.${OCTETS[1]}.${OCTETS[2]}.${OCTETS[3]}"
			return 0
		fi

		OCTETS[$i]=0
	done
}

declare -A PIDS
declare -A RESULTS
IP=$1
QT=$2
W=$3

for i in {0..$QT}; do 
	ping -4 -w $W $IP > /dev/null &
	PIDS["$!"]=$IP
	ip_next $IP
	IP=$retval
	#echo $i
done

for pid in ${!PIDS[@]}; do
	wait $pid
	if [ $? -eq 0 ]; then
		RESULTS[${PIDS[$pid]}]="Can be pinged"
	fi
done

for i in ${!RESULTS[@]}; do
	echo $i
done
