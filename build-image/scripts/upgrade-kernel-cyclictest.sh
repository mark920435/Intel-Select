PROXY=/root/scripts/set-proxy.sh
source $PROXY
yum -y update
yum -y install wget
# wget -P /etc/yum.repos.d/ http://linuxsoft.cern.ch/cern/centos/7/rt/CentOS-RT.repo
# wget -P /etc/pki/rpm-gpg/ http://linuxsoft.cern.ch/cern/slc5X/i386/RPM-GPG-KEYs/RPM-GPG-KEY-cern
# yum -y autoremove "tuned-*"
# yum -y install tuned-2.9.0-1.el7fdp
# yum-complete-transaction
# yum clean all && yum makecache
# yum -y groupinstall RT
# sleep 30
# reboot

mkdir -p rt-kernel
wget -P rt-kernel/ http://mirror.centos.org/centos/7/rt/x86_64/Packages/tuned-2.9.0-1.el7fdp.noarch.rpm
wget -P rt-kernel/ http://mirror.centos.org/centos/7/rt/x86_64/Packages/tuned-profiles-realtime-2.9.0-1.el7fdp.noarch.rpm
wget -P rt-kernel/ http://mirror.centos.org/centos/7/rt/x86_64/Packages/rt-setup-2.0-6.el7.x86_64.rpm
wget -P rt-kernel/ http://mirror.centos.org/centos/7/rt/x86_64/Packages/kernel-rt-3.10.0-957.5.1.rt56.916.el7.x86_64.rpm
wget -P rt-kernel/ http://mirror.centos.org/centos/7/rt/x86_64/Packages/kernel-rt-devel-3.10.0-957.5.1.rt56.916.el7.x86_64.rpm
wget -P rt-kernel/ http://mirror.centos.org/centos/7/rt/x86_64/Packages/kernel-rt-kvm-3.10.0-957.5.1.rt56.916.el7.x86_64.rpm

yum -y remove tuned
yum -y install tuna
rpm -ivh rt-kernel/tuned-2.9.0-1.el7fdp.noarch.rpm
rpm -ivh rt-kernel/tuned-profiles-realtime-2.9.0-1.el7fdp.noarch.rpm
rpm -ivh rt-kernel/rt-setup-2.0-6.el7.x86_64.rpm
echo "[Upgrading RT kernel......Please wait......]"
rpm -ivh rt-kernel/kernel-rt-*
sleep 60
reboot

