PROXY=/root/scripts/set-proxy.sh
source $PROXY
yum -y update
yum -y install wget
sleep 30
reboot
