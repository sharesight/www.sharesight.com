#!/bin/bash -e
# Taken from sharesight/investapp ~ bin/travis/helpers.sh

ANSI_RED="\033[31;1m"
ANSI_GREEN="\033[32;1m"
ANSI_YELLOW="\033[33;1m"
ANSI_RESET="\033[0m"
ANSI_CLEAR="\033[0K"

announce() {
  announce_time_start
  echo "\$ $@"
  $@
  announce_time_finish
}

fold_start() {
  printf "travis_fold:start:%s\n%b%s%b\n" "$1" $ANSI_YELLOW "$2" $ANSI_RESET
}

fold_end() {
  printf "travis_fold:end:%s\n" "$1"
}

# announce_time_* and fold_time_* are clones, but they use global variables, so it's just duplicated..
announce_time_start() {
  announce_start_time=$(travis_nanoseconds)
  printf "travis_time:start:%b\r%b" $announce_start_time $ANSI_CLEAR
}

announce_time_finish() {
  result=$?
  announce_end_time=$(travis_nanoseconds)
  duration=$(($announce_end_time-$announce_start_time))
  printf "travis_time:end:%b:start=%b,end=%b,duration=%b\r%b" $announce_start_time $announce_start_time $announce_end_time $duration $ANSI_CLEAR
  return $result
}

travis_nanoseconds() {
  cmd="date"
  format="+%s%N"
  os=$(uname)

  if hash gdate > /dev/null 2>&1; then
    cmd="gdate" # use gdate if available
  elif [ "$os" = "Darwin" ]; then
    format="+%s000000000" # fallback to second precision on darwin (does not support %N)
  fi

  $cmd -u $format
}
