#!/bin/sh

cfengine=${1}
dbengine=${2}

. $(dirname "$0")/functions.sh

port="$(get_port ${cfengine})"
db="$(get_db ${dbengine})"

test_url="http://127.0.0.1:8080/wheels/tests/core?db=${db}&format=txt&only=failure,error&reload=true"
result_file="/tmp/${cfengine}-${db}-result.txt"

echo "\nRUNNING SUITE (${cfengine}/${dbengine}):\n"
echo ${test_url}
echo ${result_file}
cat ${result_file}

http_code=$(curl -s -o "${result_file}" --write-out "%{http_code}" "${test_url}";)

echo "\npwd:"
pwd

echo "\nls:"
ls

echo "\nbox server status"
/usr/local/bin/box server status

echo "\nwhich box"
which box

echo "\n"
cat $result_file

if [ "$http_code" -eq "200" ]; then
    echo "\nPASS: HTTP Status Code was 200"
else
    echo "\nFAIL: Status Code: $http_code"
    exit 1
fi
