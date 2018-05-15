#!/bin/bash
log="/tmp/user_data.log"
date=`date`
user_data_uri="http://169.254.169.254/latest/user-data"
response=$(curl --write-out %{http_code} --silent --output /dev/null ${user_data_uri})
if [ $response -eq 200 ];
then
        stream=`curl -s http://169.254.169.254/latest/user-data`
        sed -i -- "s/%STREAM%/${stream}/g" /etc/aws-kinesis/agent.json
        service aws-kinesis-agent start
        echo "$date - awk-kinesis-agent start : $stream" >> $log
else
        echo "$date - Fail to load user-data : $response" >> $log
fi
