#!/bin/bash
#
# Copyright 2017 Intel Corporation
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom
# the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
# THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# SPDX-License-Identifier: MIT
#

######################################
############# USER INPUT #############
######################################
ip_address=localhost
_time=60
clients=2000
portbase=4400
cipher=AES128-SHA;

# Cores to use for client traffic generation.  When 
#   running the CPS tests on one system, use every core that is 
#   not being used for nginx threads.
# 
#   Use this definition for systems with 22 cores:
#_cores_used="-c 24-47,72-95"

# The following are run to determine the total_physical_cores and the _cores_used 
cores_per_socket=$(  lscpu | grep -E '^Thread|^Core|^Socket|^CPU\(' | sed -n '3p' |awk '{print $4}' )
socket_count=$( lscpu | grep -E '^Thread|^Core|^Socket|^CPU\(' | sed -n '4p' |awk '{print $2}' )

total_physical_cores=$(( $cores_per_socket * $socket_count ))
#_cores_used="-c 12-$total_physical_cores"
#_cores_used="-c 32"
_cores_used="-c 32-63,96-127"
OPENSSL_DIR=/usr/local/ssl/
######################################
############# USER INPUT #############
######################################

#Check for OpenSSL Directory
if [ ! -d $OPENSSL_DIR ];
then
    printf "\n$OPENSSL_DIR does not exist.\n\n"
    printf "Please modify the OPENSSL_DIR variable in the User Input section!\n\n"
    exit 0
fi

helpAndError () {
    printf "\nThis script is to run the CPS testing HTTPS.\n"
    printf "\nTo use this script: ./download.sh \n"
    printf "\nTo do a dry-run, use the emulation flag:\n"
    printf "./download.sh --emulation\n\n"
    exit 0
}

#Check for h flag or no command line args
if [[ $1 == *"h"* ]]; then
    helpAndError
    exit 0
fi

#Check for emulation flag
if [[ $@ == **emulation** ]]
then
    emulation=1

else
   emulation=0
fi


#cmd1 is the first part of the commandline and cmd2 is the second partrt
#The total commandline will be cmd1 + "192.168.1.1:4400" + cmd2
cmd1="$OPENSSL_DIR/bin/openssl s_time -connect"
cmd2="-new -cipher $cipher -www /zero.html -time $_time"

#Print out variables to check
printf "\n Location of OpenSSL:           $OPENSSL_DIR\n"
printf " IP Addresses:                  $ip_address\n"
printf " Time:                          $_time\n"
printf " Clients:                       $clients\n"
printf " Port Base:                     $portbase\n"
printf " Cipher:                        $cipher\n"
printf " Cores Used:                    $_cores_used\n\n"

#read

#Remove previous .test files
rm -rf ./.test_*

#Get starttime 
starttime=$(date +%s)

#Kick off the tests after checking for emulation
if [[ $emulation -eq 1 ]]
then
    for (( i = 0; i < ${clients}; i++ )); do
        printf "$cmd1 $ip_address:$(($portbase)) $cmd2 > .test_$(($portbase))_$i &\n"
    done
    exit 0
else
    for (( i = 0; i < ${clients}; i++ )); do
        taskset $_cores_used $cmd1 $ip_address:$(($portbase)) $cmd2 > .test_$(($portbase))_$i &
    done
fi

waitstarttime=$(date +%s)
# wait until all processes complete
while [ $(ps -ef | grep "openssl s_time" | wc -l) != 1 ];
do
    sleep 1
done

total=$(cat ./.test_$(($portbase))* | awk '(/^[0-9]* connections in [0-9]* real/){ total += $1/$4 } END {print total}')
echo $total >> .test_sum
sumTotal=$(cat .test_sum | awk '{total += $1 } END { print total }')
printf "Connections per second:      $sumTotal CPS\n"
printf "Finished in %d seconds (%d seconds waiting for procs to start)\n" $(($(date +%s) - $starttime)) $(($waitstarttime - $starttime))
rm -rf ./.test_*

