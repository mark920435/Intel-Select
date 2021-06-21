SCRIPTS=/root/scripts
TREX_CFG=$SCRIPTS/trex/trex-cfg.yaml
PROXY=$SCRIPTS/set-proxy.sh
TREX_PATH=/opt/trex

source $PROXY
yum -y install wget
mkdir -p $TREX_PATH
cd $TREX_PATH
wget --no-cache --no-check-certificate https://trex-tgn.cisco.com/trex/release/latest
tar -xzvf latest
yum -y install kernel-devel-`uname -r`
yum -y group install "Development Tools"
