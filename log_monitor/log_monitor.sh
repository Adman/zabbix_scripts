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
    -d      Regular expression for date/time reading from log
EOF
}

FILE="/var/log/auth.log"
TIME="%H:%M:%S"
KEYWORD="WARNING"
DATE_REGEX="^[A-Za-z]{3} [0-9]{1,2} [0-9]{2}:[0-9]{2}:[0-9]{2}"

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
        d)
            DATE_REGEX="$OPTARG"
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
    dateString=`echo $line | grep -oE "$DATE_REGEX" | head -n 1`
    if [ -n "$dateString" ]; then
        currentDate=`date -d "$dateString" "+%s"`
        if [ $currentDate -gt $startDate ]; then
            FOUND=`echo $line | grep -c $KEYWORD`
            if [[ "$FOUND" == "1" ]]; then
                COUNT=$((COUNT + 1))
            fi
        else
            echo $COUNT
            exit
        fi
    fi
done
