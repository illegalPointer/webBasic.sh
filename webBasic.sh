#!/bin/sh
# Web Basic Tests
# Usage: sh webBasic.sh testname URL

YELLOW='\033[0;33m'
GRAY='\033[0;37m'
GREEN='\033[1;32m'
RED='\033[1;31m'

HOPPY="HOPPYLOCATION"
NIKTO="NIKTOLOCATION"
DIRB="DIRBLOCATION"
DIRLIST="DIRLISTLOCATION"
TESTSSL="TESTSSLLOCATION"
SSLENUM="SSLENUMLOCATION"

ARGS=2

if [ "$#" != "${ARGS}" ]; then
  echo "${RED}Illegal number of parameters!${GRAY}"
  echo "${GREEN}Usage: sh webBasic.sh testname URL${GRAY}"
else
  JOBCODE="$1"
  URL="$2"
  HOME="$(echo ~)"
  LOCATION="${HOME}/${JOBCODE}"
  SSL=$(echo ${2} | grep -o "^https:")
  echo "${YELLOW}-----------------------------------${GRAY}"
  echo "${YELLOW}Low Hanging Fruit Harvester${GRAY}"
  echo "${YELLOW}Job Code: ${JOBCODE}${GRAY}"
  echo "${YELLOW}URL: ${URL}${GRAY}"
  echo "${YELLOW}Location: ${LOCATION}"
  if [ ! -z "${SSL}" ]; then
    echo "${YELLOW}SSL: True${GRAY}"
  else
    echo "${YELLOW}SSL: False${GRAY}"
  fi
  echo "${YELLOW}-----------------------------------${GRAY}"
  if [ ! -f ${HOPPY} ] || [ ! -f ${NIKTO} ] \
    || [ ! -f ${DIRB} ] || [ ! -f ${DIRLIST} ] \
    || [ ! -f ${TESTSSL} ] || [ ! -f ${SSLENUM} ]; then
    echo "${RED}ERROR! Can't find a necessary resource${GRAY}"
    if [ ! -f $HOPPY ]; then
	echo "${RED}- Hoppy${GRAY}"
    fi
    if [ ! -f $NIKTO ]; then
	echo "${RED}- Nikto${GRAY}"
    fi
    if [ ! -f $DIRB ]; then
	echo "${RED}- Dirb${GRAY}"
    fi
    if [ ! -f $DIRLIST ]; then
	echo "${RED}- List for dirb (DIRLIST)${GRAY}"
    fi
    if [ ! -f $TESTSSL ]; then
	echo "${RED}- TestSSL${GRAY}"
    fi
    if [ ! -f $SSLENUM ]; then
	echo "${RED}- SSLEnum${GRAY}"
    fi
    echo "${YELLOW}Exiting...${GRAY}"
    exit 1
  fi
  if [ ! -z "$(ls ${HOME} | grep "${JOBCODE}")" ]; then
    read -p "$(echo "${RED}Directory ${JOBCODE} already exists in ${HOME}. Do you want to continue? [Y/n]: ${GRAY}")" -r RESPONSE
    if [ -z $(echo "${RESPONSE}" | grep -o "[Yy]$") ] && [ ! -z "${RESPONSE}" ]; then
      echo "${YELLOW}Exiting...${GRAY}"
      exit 1
    fi
  fi
  mkdir "${LOCATION}" 2>/dev/null
  mkdir "${LOCATION}/screenLogs" 2>/dev/null
  screen -d -L -Logfile "${LOCATION}/screenLogs/$(date +"%Y%m%d-%H%M")_hoppy.log" \
    -m -S "hoppy_${JOBCODE}" python ${HOPPY} -h ${URL} --save "${LOCATION}/${JOBCODE}_hoppy.txt" --threads 10
  screen -d -L -Logfile "${LOCATION}/screenLogs/$(date +"%Y%m%d-%H%M")_nikto.log" \
    -m -S "nikto_${JOBCODE}" perl ${NIKTO} -host ${URL} -output "${LOCATION}/${JOBCODE}_nikto.txt"
  screen -d -L -Logfile "${LOCATION}/screenLogs/$(date +"%Y%m%d-%H%M")_dirb.log" \
    -m -S "dirb_${JOBCODE}" ${DIRB} $${URL} ${DIRLIST} -o "${LOCATION}/${JOBCODE}_dirb.txt"
  if [ ! -z "$SSL" ]; then
    echo "${YELLOW}SSL/TLS URL detected, we will launch SSL tests${GRAY}"
    DOMAIN=$(echo $2 | cut -d"/" -f3 | cut -d":" -f1)
    PORT=$(echo $2 | cut -d"/" -f3 | cut -d":" -f2 | grep -o "[0-9]*")
    if [ -z "$PORT" ]; then
      PORT="443"
    fi
    echo "${YELLOW}SSL/TLS Domain: ${DOMAIN}${GRAY}"
    echo "${YELLOW}SSL/TLS Port: ${PORT}${GRAY}"  
    screen -d -L -Logfile "${LOCATION}/screenLogs/$(date +"%Y%m%d-%H%M")_testssl.log" \
      -m -S "testSSL_$1" bash ${TESTSSL} --logfile "${LOCATION}/${JOBCODE}_${DOMAIN}_${PORT}_testssl.log" ${DOMAIN}":"${PORT}
    screen -d -L -Logfile "${LOCATION}/screenLogs/$(date +"%Y%m%d-%H%M")_sslenum.log" \
      -m -S "sslEnum_$1" perl ${SSLENUM} --outfile "${LOCATION}/${JOBCODE}_${DOMAIN}_${PORT}_sslenum.txt" ${DOMAIN}":"${PORT}
  fi
  sleep 1
  echo "${YELLOW}Ended. Session list:${GRAY}"
  screen -ls
fi
