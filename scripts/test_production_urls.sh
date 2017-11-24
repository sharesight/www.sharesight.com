#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

target_url='https://www.sharesight.com'
test_urls=(
  www.sharesight.co.uk
  sharesight.co.uk
  www.sharesight.co.nz
  sharesight.co.nz
  www.sharesight.com.au
  sharesight.com.au
)
num_test_urls=${#test_urls[@]}

function retrieve_redirect {
  curl -w "%{url_effective}\n" -I -L -s -S $test_url -o /dev/null
}

function check {
  test_url=$1
  expected=$2
  result=$( retrieve_redirect )
  if [ "${result}" = "${expected}" ]; then
    printf "  ${test_url} ${GREEN}all good ✔${NC}\n"
  else
    printf "  ${test_url} ${RED}failed ✖${NC} (got redirected to ${result}, but expected ${expected})\n"
  fi
}

echo "Checking redirection to ${target_url}"
for (( i=0;i<$num_test_urls;i++)); do
  check "http://${test_urls[${i}]}" "${target_url}/"
  check "https://${test_urls[${i}]}" "${target_url}/"
  check "http://${test_urls[${i}]}/path" "${target_url}/path"
  check "https://${test_urls[${i}]}/path" "${target_url}/path"
  check "http://${test_urls[${i}]}?here=there" "${target_url}/?here=there"
  check "https://${test_urls[${i}]}?here=there" "${target_url}/?here=there"
  check "http://${test_urls[${i}]}/path?here=there" "${target_url}/path?here=there"
  check "https://${test_urls[${i}]}/path?here=there" "${target_url}/path?here=there"
done
