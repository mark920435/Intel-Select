PROXY=/root/scripts/set-proxy.sh
source $PROXY

yum -y install numactl-devel
yum -y group install "Development Tools"
wget https://git.kernel.org/pub/scm/utils/rt-tests/rt-tests.git/snapshot/rt-tests-0.92.tar.gz
tar xvzf rt-tests-0.92.tar.gz
cd rt-tests-0.92
make
make install

