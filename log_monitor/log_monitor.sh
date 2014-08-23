#!/bin/bash

usage()
{
cat << EOF
usage: $0 [options]

This script reads given log and shows number of errors, warnings etc. in last hour

OPTIONS:
    -h      Show this message
    -f      Log file to check
    -t      Time regex (default %H:%M:%S)
    -k      Keyword to look for in log (default WARNING)
EOF
}

FILE="/var/log/auth.log"
TIME="%H:%M:%S"
KEYWORD="WARNING"

while getopts "hf:t:k:" opt; do
    case $opt in 
        h)
            usage
            exit 1
            ;;
        f)
            FILE="$OPTARG"
            ;;
        t)
            TIME="$OPTARG"
            ;;
        k)
            KEYWORD="$OPTARG"
            ;;
        \?)
            echo "Invalid option"
            usage
            exit 1
            ;;
    esac
done

FROM=$(date +%b" "%d" "$TIME -d "-1 hour")
NOW=$(date +%b" "%d" "$TIME)

COUNT=0

tac $FILE | \
while read CMD; do
    AVAILABLE=`awk "($0 >= from){++n}END{print n}" from="$(LC_TIME=C date +"%b %d $TIME" -d -1hour)" $CMD`
    if [ $AVAILABLE > 0 ]; then
       COUNT+=`grep -c $KEYWORD`
    else
        break
    fi
done

echo $COUNT

#LINES=`awk '($0 >= from){++n}END{print n}' from="$(LC_TIME=C date +'%b %d $TIME' -d -1hour)" $FILE`
#tail -$LINES $FILE | grep -c "$KEYWORD"
