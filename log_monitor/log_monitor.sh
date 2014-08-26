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


COUNT=0

startDate=$(date +%s -d -1hour)
tac $FILE | \
while read line; do
    currentDate=$(date -d "$(awk '{print $1,$2,$3}' <(echo $line))" "+%s")
    if [ $currentDate -gt $startDate ]; then
        FOUND=`echo $line | grep -c $KEYWORD`
        echo $line
        if [[ "$FOUND" == "1" ]]; then
            COUNT=$((COUNT + 1))
        fi
    else
        echo $COUNT
        break
    fi
done
