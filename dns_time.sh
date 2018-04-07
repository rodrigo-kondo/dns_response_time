#!/bin/bash
if [ -f .tmp ]; then 
	read -r -p "this script will erase \".tmp\"file Are you sure? [y/N] " response
	case "$response" in
    	[yY][eE][sS]|[yY]) 
         	: > .tmp
	;;
    	*)
		exit
	;;
	esac
fi
echo 
 while read -r domain
do
    while read -r server
    do
        response_time="$(drill @$server $domain | grep -o "Query time: [0-9]*" | grep -o "[0-9]*")"
        echo " $server-> $domain::$response_time "
        echo "$server,$domain,$response_time " >> .tmp
    done < servers.txt
    echo
done < domains.txt
	echo
	while read -r server
	do
		echo "$server ->>>>"
		echo -n "avg:"
		echo "$(< .tmp grep "$server" |cut -d ',' -f 3|awk 'NF{sum+=$1} END {print sum}')"/"$(wc -l domains.txt|grep -o "[0-9]*")"| bc 
		< .tmp grep "$server" |cut -d ',' -f 3|sort -n |echo min:"$(head -1)" 
		< .tmp grep "$server" |cut -d ',' -f 3|sort -n |echo max:"$(tail -1)"
		echo 
	done <servers.txt
rm .tmp 
exit
