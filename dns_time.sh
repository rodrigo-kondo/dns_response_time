#!/bin/bash
TMP=:
while read -r domain
do
    while read -r server
    do
        response_time="$(drill @$server $domain | grep -o "Query time: [0-9]*" | grep -o "[0-9]*")"
        echo "$server-> $domain::$response_time"
        TMP+="$server,$domain,$response_time""\\n"
    done < servers.txt
    echo
done < domains.txt
	echo
#	echo -e "$TMP"
	while read -r server
	do
		echo "$server ->>>>"
		echo -n "avg:"
		echo "$(echo -e $TMP |grep $server |cut -d ',' -f 3 |awk 'NF{sum+=$1} END {print sum}')"/"$(wc -l domains.txt|grep -o "[0-9]*")"|bc 
		echo -e $TMP |grep $server |cut -d ',' -f 3 |sort -n |echo min:$(head -1)
		echo -e $TMP |grep $server |cut -d ',' -f 3 |sort -n |echo max:$(tail -1)
		echo -e $TMP|grep $server |cut -d ',' -f 3|sort -n |uniq -c |awk '{$2=$2"->"$1;$1="";print} '
		echo 
	done <servers.txt
exit
