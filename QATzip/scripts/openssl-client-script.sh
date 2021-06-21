#!/bin/bash

################################################################################
# default parameters

#ip_address=192.168.10.100
ip_address=localhost
param_time=90
client_count=2500
portbase=4400
cipher=AES128-SHA;
#OPENSSL_DIR=/usr
OPENSSL_DIR=/usr/local/ssl



################################################################################
# help functions
print_help() {
    echo -e "\nUse this script to generate traffic using OpenSSL s_time clients. "
    echo -e "\nOpenSSL s_time clients can be used to test the maximum number of connections that can be establised with a server."
    echo -e "\nInput Parameters:"
	echo -e "\n\t-i | --target-ip\n\t\tSet the target IP address for OpenSSL s_time test."
	echo -e "\n\t-t | --run-time\n\t\tSet the run time in seconds for s_time (default=30s)"
	echo -e "\n\t-c | --client-count\n\t\tSet the number of OpenSSL s_time client processes to spawn (default=500)"
	echo -e "\n\t-d | --dry-run\n\t\tDo not start OpenSSL s_time processes, just print the command"
	echo -e "\n\t-h | --help\n\t\tPrint this help"
}

################################################################################
# Parse the parameters
TEMP=`getopt -o i:t:c:hd --long target-ip:,run-time:,client-count:,help,dry-run -n 'Yikes: ' -- "$@"`
if [[ $? -ne 0 ]]; then
	print_help
	exit 1
fi

eval set -- "$TEMP"
while true; do
	case $1 in
		-i | --target-ip ) ip_address=$2; shift 2 ;;
		-t | --run-time ) param_time=$2; shift 2 ;;
		-c | --client-count ) client_count=$2; shift 2 ;;
		-d | --dry-run ) dry_run=1; shift ;;
		-h | --help ) print_help; shift; exit 0 ;;
		-- ) shift; break ;;
		* ) break ;;
	esac
done

if [[ -z "$ip_address" ]]; then
	echo -e "Target (server) IP address not specified. Use [-i | --target-ip] flag to specify the target IP address. Exiting."
	exit 1
fi

################################################################################
# Run the workload

#cmd1 is the first part of the commandline and cmd2 is the second partrt
#The total commandline will be cmd1 + "192.168.1.1:4400" + cmd2
cmd1="$OPENSSL_DIR/bin/openssl s_time -connect"
cmd2="-new -cipher $cipher -time $param_time"

#Print out variables to check
printf "\n Location of OpenSSL:           $OPENSSL_DIR\n"
printf " IP Addresses:                  $ip_address\n"
printf " Time:                          $param_time\n"
printf " Clients:                       $client_count\n"
printf " Port Base:                     $portbase\n"
printf " Cipher:                        $cipher\n"
printf " Cores Used:                    $_cores_used\n\n"

#Remove previous .test files
rm -rf ./.test_*

#Get starttime
starttime=$(date +%s)

#Kick off the tests after checking for emulation
if [[ "$dry_run" -eq "1" ]]; then
    for (( i = 0; i < $client_count; i++ )); do
        printf "$cmd1 $ip_address:$(($portbase)) $cmd2 > .test_$(($portbase))_$i &\n"
    done
    exit 0
else
    for (( i = 0; i < $client_count; i++ )); do
		# taskset -c $(( $i % $(nproc) )) $cmd1 $ip_address:$(($portbase)) $cmd2 > .test_$(($portbase))_$i &
		# $cmd1 $ip_address:$(($portbase)) $cmd2 > .test_$(($portbase))_$i &
		# taskset -c 6-31,38-63 $cmd1 $ip_address:$(($portbase)) $cmd2 > .test_$(($portbase))_$i &


                 taskset -c $1-$2,$3-$4 $cmd1 $ip_address:$(($portbase)) $cmd2 > .test_$(($portbase))_$i &
   done
fi

waitstarttime=$(date +%s)
# wait until all processes complete
while [ $(ps -ef | grep "openssl s_time" | wc -l) != 1 ]; do
    sleep 1
done

total=$(cat ./.test_$(($portbase))* | awk '(/^[0-9]* connections in [0-9]* real/){ total += $1/$4 } END {print total}')
echo $total >> .test_sum
sumTotal=$(cat .test_sum | awk '{total += $1 } END { print total }')
printf "Connections per second:      $sumTotal CPS\n"
printf "Finished in %d seconds (%d seconds waiting for procs to start)\n" $(($(date +%s) - $starttime)) $(($waitstarttime - $starttime))
rm -rf ./.test_*
