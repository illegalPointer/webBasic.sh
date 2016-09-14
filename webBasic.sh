#!/bin/bash
# Web Basic Tests
# Usage: sh webBasic.sh testname URL

YELLOW='\033[0;33m'
GRAY='\033[0;37m'
GREEN='\033[1;32m'
RED='\033[1;31m'

HOPPY=""
NIKTO=""
DIRB=""
DIRLIST=""

HOME="$(echo ~)"

ARGS=2

if [ "$#" != "${ARGS}" ]; then
  echo "${RED}Illegal number of parameters!${GRAY}"
  echo "${GREEN}Usage: sh webBasic.sh testname URL${GRAY}"
else
  screen -d -m -S "hoppy_$1" python ${HOPPY} -h $2 --save "${HOME}/${1}_hoppy.txt" --threads 10
  screen -d -m -S "nikto_$1" perl ${NIKTO} -host $2 -output "${HOME}/${1}_nikto.txt"
  screen -d -m -S "dirb_$1" ${DIRB} $2 ${DIRLIST} -o "${HOME}/${1}_dirb.txt"
  sleep 1
  echo "${YELLOW}Ended. Session list:${GRAY}"
  screen -ls
fi
