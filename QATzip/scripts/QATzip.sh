source ./QATzip-env.sh

InstallQAT(){
  read -p "Install QAT? (yes/no) " yn
  if [ $yn == 'yes' ]; then
  
    echo "[Download QAT1.7.l.4.12]"
    
    mkdir $ICP_ROOT
    cd $ICP_ROOT
    wget https://01.org/sites/default/files/downloads//qat1.7.l.4.12.0-00011.tar.gz
    tar -zxof qat1.7.l.4.12.0-00011.tar.gz
    rm qat1.7.l.4.12.0-00011.tar.gz
    
    yum -y groupinstall "Development Tools"
    yum -y install pciutils
    yum -y install libudev-devel
    yum -y install kernel-devel-$(uname -r)
    yum -y install gcc
    yum -y install openssl-devel
    
    ./configure
    make install -j 10
  
    echo "[Verify QAT driver]"
    lsmod | grep qa
    service qat_service start
  fi
}

UninstallQAT(){
  if [ -d "$ICP_ROOT" ]
  then
    cd $ICP_ROOT
    make uninstall
    cd
    rm -rf $ICP_ROOT
  fi
}

RunCPASampleCode(){
  read -p "Run CPA sample code? (yes/no) " yn
  if [ $yn == 'yes' ]; then 
    echo "[Run QAT cpa sample code]"
    cd $ICP_ROOT
    make install samples-install -j 10
    cd $ICP_ROOT/build/
    systemctl stop qat_service
    rm -rf /$SCRIPT_ROOT/cpa_sample_code.txt
    \cp -f $CONFIG_DIR/c6xx_dev0.conf.qat /etc/c6xx_dev0.conf
    \cp -f $CONFIG_DIR/c6xx_dev1.conf.qat /etc/c6xx_dev1.conf
    \cp -f $CONFIG_DIR/c6xx_dev2.conf.qat /etc/c6xx_dev2.conf
    systemctl start qat_service
    ./cpa_sample_code > /$SCRIPT_ROOT/cpa_sample_code.txt
  fi
}

InstallOpenssl(){
  read -p "Install Openssl? (yes/no) " yn
  if [ $yn == 'yes' ]; then
  
    echo "[Download OpenSSL1.1.1i]"
    cd /
    git clone https://github.com/openssl/openssl.git
    cd $OPENSSL_SOURCE
    git checkout OpenSSL_1_1_1i
    ./config --prefix=$OPENSSL_INSTALL -Wl,-rpath,$OPENSSL_INSTALL/lib
    make depend -j 10
    make -j 10
    make install -j 10
  fi
}

UninstallOpenssl(){
  if [ -d "$OPENSSL_SOURCE" ]
  then
    cd $OPENSSL_SOURCE
    make uninstall
    make clean
    cd
    rm -rf $OPENSSL_SOURCE
  fi
}

InstallQATEngine(){
  read -p "Install QAT engine? (yes/no) " yn
  if [ $yn == 'yes' ]; then
  
    echo "[Download QAT Engine v0.6.4]"
    cd /
    git clone https://github.com/intel/QAT_Engine.git
    cd $QATENGINE_SOURCE
    git checkout v0.6.4
    ./autogen.sh
    ./configure \
      --with-qat_dir=$ICP_ROOT \
      --with-openssl_install_dir=$OPENSSL_INSTALL
    make -j 10
    make install -j 10
   
    echo "[Check usdm_drv]"
    lsmod | grep usdm
  fi
}

UninstallQATEngine(){
  if [ -d $QATENGINE_SOURCE ]
  then
    cd $QATENGINE_SOURCE
    make uninstall
    make clean
    cd
    rm -rf $QATENGINE_SOURCE
  fi
}

QATEngineTest(){
  read -p "QAT engine functional test? (yes/no) " yn
  if [ $yn == 'yes' ]; then
  
    echo ["Test QAT Engine"]
    systemctl stop qat_service
    \cp -f $QATENGINE_SOURCE/qat/config/c6xx/multi_process_optimized/c6xx_dev*.conf /etc/.
    sed -i 's/LimitDevAccess = 1/LimitDevAccess = 0/g' /etc/c6xx_dev0.conf
    echo "modified c6xx_dev0.conf"
    sed -i 's/LimitDevAccess = 1/LimitDevAccess = 0/g' /etc/c6xx_dev1.conf
    echo "modified c6xx_dev1.conf"
    sed -i 's/LimitDevAccess = 1/LimitDevAccess = 0/g' /etc/c6xx_dev2.conf
    echo "modified c6xx_dev2.conf"
    systemctl start qat_service
    cd $OPENSSL_INSTALL/bin
    ./openssl engine -t -c -vvvv qatengine
  fi
}

OpensslSpeedTest(){
  read -p "Openssl speed test? (yes/no) " yn
  if [ $yn == 'yes' ]; then
  
    echo "[Run speed with the QAT OpenSSL Engine]"

    systemctl stop qat_service
    \cp -f $QATENGINE_SOURCE/qat/config/c6xx/multi_process_optimized/c6xx_dev*.conf /etc/.
    sed -i 's/LimitDevAccess = 1/LimitDevAccess = 0/g' /etc/c6xx_dev0.conf
    echo "modified c6xx_dev0.conf"
    sed -i 's/LimitDevAccess = 1/LimitDevAccess = 0/g' /etc/c6xx_dev1.conf
    echo "modified c6xx_dev1.conf"
    sed -i 's/LimitDevAccess = 1/LimitDevAccess = 0/g' /etc/c6xx_dev2.conf
    echo "modified c6xx_dev2.conf"
    systemctl start qat_service
    
    cd $OPENSSL_INSTALL/bin
    
    #RSA2K
    taskset -c 1 ./openssl speed -async_jobs 150 -multi 1 rsa2048 
    taskset -c 1 ./openssl speed -engine qatengine -async_jobs 150 -multi 1 rsa2048
    ## RSA 2K Asynchronous vs Synchronous vs Software
    #./openssl speed -engine qatengine -elapsed -async_jobs 72 rsa2048
    #./openssl speed -engine qatengine -elapsed rsa2048
    #./openssl speed -elapsed rsa2048
    ## ECDH Compute Key Asynchronous vs Synchronous vs Software
    #./openssl speed -engine qatengine -elapsed -async_jobs 36 ecdh
    #./openssl speed -engine qatengine -elapsed ecdh
    #./openssl speed -elapsed ecdh
    ## Chained Cipher: aes-128-cbc-hmac-sha1 Asynchronous vs Synchronous vs Software
    #./openssl speed -engine qatengine -elapsed -async_jobs 128 -multi 2 -evp aes-128-cbc-hmac-sha1
    #./openssl speed -engine qatengine -elapsed -multi 2 -evp aes-128-cbc-hmac-sha1
    #./openssl speed -elapsed -multi 2 -evp aes-128-cbc-hmac-sha1
  fi
}

InstallQATzip(){
  read -p "Install QATzip (yes/no)" yn
  if [ $yn == 'yes' ]; then
    echo "[Install QATzip]"
    cd /
    git clone https://github.com/intel/QATzip.git
    cd $QZ_ROOT
    git checkout v1.0.2
    echo 1024 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
    rmmod usdm_drv
    insmod $ICP_ROOT/build/usdm_drv.ko max_huge_pages=1024 max_huge_pages_per_process=16
    cd $QZ_ROOT
    ./configure --with-ICP_ROOT=$ICP_ROOT
    make clean
    make all install
  fi
}

UninstallQATzip(){
  if [ -d $QZ_ROOT ]
  then
    cd $QZ_ROOT
    make uninstall
    make clean
    cd
    rm -rf $QZ_ROOT
  fi
}

QATzipPerfTest(){
  ## Bug in run_perf_test.sh
  read -p "QATzip performance test (yes/no)" yn
  if [ $yn == 'yes' ]; then
    \cp -f $QZ_ROOT/config_file/c6xx/multiple_process_opt/c6xx_dev*.conf /etc/.
    systemctl restart qat_service
    sleep 5
    systemctl status qat_service
    $QZ_ROOT/test/performance_tests/run_perf_test.sh
  fi
}

InstallNginx(){
  read -p "Install NGINX (yes/no)" yn
  if [ $yn == 'yes' ]; then
    cd /
    git clone https://github.com/intel/asynch_mode_nginx.git
    cd asynch_mode_nginx
    git checkout v0.4.4
    ./configure \
      --prefix=$NGINX_INSTALL_DIR \
      --without-http_rewrite_module \
      --with-http_ssl_module \
      --with-http_stub_status_module \
      --with-http_v2_module \
      --with-stream \
      --with-stream_ssl_module \
      --add-dynamic-module=modules/nginx_qatzip_module \
      --add-dynamic-module=modules/nginx_qat_module/ \
      --with-cc-opt="-DNGX_SECURE_MEM -I$OPENSSL_INSTALL/include -I$QZ_ROOT/include -Wno-error=deprecated-declarations" \
      --with-ld-opt="-Wl,-rpath=$OPENSSL_INSTALL/lib -L$OPENSSL_INSTALL/lib -L$QZ_ROOT/src -lqatzip -lz"
    make -j 10
    make install -j 10
  fi
}

UninstallNginx(){
  if [ -d $NGINX_SOURCE ]
  then
    rm -rf $NGINX_INSTALL_DIR
    cd $NGINX_SOURCE
    make clean
    cd
    rm -rf $NGINX_SOURCE
  fi
}

NginxQATzip(){
  read -p "Run NGINX with QATzip (yes/no)" yn
  if [ $yn == 'yes' ]; then
    pkill nginx
    systemctl stop qat_service
    \cp -f $CONFIG_DIR/c6xx_dev0.conf.qatzip /etc/c6xx_dev0.conf
    \cp -f $CONFIG_DIR/c6xx_dev1.conf.qatzip /etc/c6xx_dev1.conf
    \cp -f $CONFIG_DIR/c6xx_dev2.conf.qatzip /etc/c6xx_dev2.conf
    systemctl start qat_service
    \cp -f $CONFIG_DIR/nginx.conf.qatzip $NGINX_INSTALL_DIR/conf/nginx.conf
    taskset -c 1-3,29-31 $NGINX_INSTALL_DIR/sbin/nginx -c $NGINX_INSTALL_DIR/conf/nginx.conf
    ps -aux | grep nginx
  fi
}

InstallQATzipStack(){
  InstallQAT
  RunCPASampleCode
  InstallOpenssl
  InstallQATEngine
  QATEngineTest
  OpensslSpeedTest
  InstallQATzip
  QATzipPerfTest
  InstallNginx
  NginxQATzip
}

UninstallQATzipStack(){
  pkill nginx
  UninstallNginx
  UninstallQATzip
  UninstallQATEngine
  UninstallOpenssl
  UninstallQAT
}

InstallQATzipStack
#UninstallQATzipStack
