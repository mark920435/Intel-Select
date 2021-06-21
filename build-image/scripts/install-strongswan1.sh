PROXY=/root/scripts/set-proxy.sh
STRONGSWAN_SCRIPTS=/root/scripts/strongswan1

source $PROXY


yum -y install pciutils
yum install -y kernel-devel-$(uname -r)
yum -y groupinstall "Development Tools"
yum -y install libudev-devel
yum -y install gmp-devel
mkdir -p /QAT
cd /QAT
wget https://01.org/sites/default/files/downloads/qat1.7.l.4.9.0-00008.tar.gz
tar -xzof  qat1.7.l.4.9.0-00008.tar.gz
./configure
make 
make install

cd
wget https://download2.strongswan.org/strongswan-5.8.0.tar.bz2
tar -xjvf strongswan-5.8.0.tar.bz2
cd strongswan-5.8.0
./configure --enable-systemd --enable-swanctl --enable-gcm
make
make install


$STRONGSWAN_SCRIPTS/set-strongswan-IP.sh
cp $STRONGSWAN_SCRIPTS/ipsec.conf /usr/local/etc/ipsec.conf
cp $STRONGSWAN_SCRIPTS/ipsec.secrets /usr/local/etc/ipsec.secrets
cp $STRONGSWAN_SCRIPTS/sysctl.conf /etc/sysctl.conf
