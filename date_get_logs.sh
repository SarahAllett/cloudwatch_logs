#! /usr/bin/env bash

# OSX specific. Times are [[[mm]dd]HH]MM[[cc]yy][.ss]

start_time=$(date -ju 03051600 +"%s")000
end_time=$(date -ju 03051700 +"%s")000

for group in 'logStreamName' 'logStreamName'; do
    mkdir -p logdump/$group
    for stream in $(aws logs describe-log-streams --log-group-name $group | jq -r '.logStreams[].logStreamName'); do
        filename="logdump/$group/$stream.txt"
        aws logs get-log-events \
            --log-group-name $group --log-stream-name $stream \
            --start-time $start_time --end-time $end_time \
            | jq --raw-output '.events[] | (.timestamp/1000|todate) + ": " + .message' > $filename
        echo Exported: $filename
        if ! [ -s $filename ]; then
            rm $filename
            echo "Deleted:  $filename (empty)"
        fi
    done
done
