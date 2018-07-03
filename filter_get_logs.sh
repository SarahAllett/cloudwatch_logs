#! /usr/bin/env bash

#OSX specific. Times are [[[mm]dd]HH]MM[[cc]yy][.ss]

start_time=$(date -ju 07021750 +"%s")000
end_time=$(date -ju 07021800 +"%s")000
filter_pattern="toFind"

for group in 'logStreamName' 'logStreamName'; do
    mkdir -p logdump/$group
    for stream in $(aws logs describe-log-streams --log-group-name $group | jq -r '.logStreams[].logStreamName'); do
        filename="logdump/$group/$stream.txt"
        aws logs filter-log-events \
            --log-group-name $group --log-stream-name $stream \
            --start-time $start_time --end-time $end_time \
            --filter-pattern $filter_pattern \
            | jq --raw-output '.events[] | (.timestamp/1000|todate) + ": " + .message' > $filename
        echo Exported: $filename
        if ! [ -s $filename ]; then
            rm $filename
            echo "Deleted:  $filename (empty)"
        fi
    done
done
