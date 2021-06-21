
source ./QATzip-env.sh

InstallDependency(){
  read -p "Install Dependency? (yes/no) " yn
  if [ $yn == 'yes' ]; then
    if [ $OS_NAME == 'rhel' ]
    then
      yum -y groupinstall "Development Tools"
      yum -y install pciutils
      yum -y install kernel-devel-$(uname -r)
      yum -y install gcc
      yum -y install wget
    fi
    if [ $OS_NAME == 'ubuntu' ]
    then
      apt install build-essential
    fi
  fi
}

DownloadQAT(){
  read -p "Download QAT4.12? (yes/no) " yn
  if [ $yn == 'yes' ]; then
    echo "[Download QAT1.7.l.4.12]"
    mkdir $ICP_ROOT
    cd $ICP_ROOT
    wget --no-check-certificate https://01.org/sites/default/files/downloads//qat1.7.l.4.12.0-00011.tar.gz
    tar -zxof qat1.7.l.4.12.0-00011.tar.gz
    rm qat1.7.l.4.12.0-00011.tar.gz
  fi  
}

InstallQAT(){
  read -p "Install QAT? (yes/no) " yn
  if [ $yn == 'yes' ]; then
    if [ $OS_NAME == 'rhel' ]
    then
      yum -y groupinstall "Development Tools"
      yum -y install pciutils
      yum -y install libudev-devel
      yum -y install kernel-devel-$(uname -r)
      yum -y install gcc
      yum -y install openssl-devel
      yum -y install elfutils-libelf-devel
    fi
    if [ $OS_NAME == 'ubuntu' ]
    then
      apt-get update
      apt-get install pciutils-dev
      apt-get install g++
      apt-get install pkg-config
      apt-get install libssl-dev 
    fi
    cd $ICP_ROOT 
    ./configure
    make install -j 10
    make install samples-install -j 10
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
    cd $ICP_ROOT/build/
    systemctl stop qat_service
    rm -rf /$SCRIPT_ROOT/cpa_sample_code.txt
    for num in $(seq 0 $NUM_QAT_CONFIG)
    do
      \cp -f $CONFIG_DIR/c6xx_dev0.conf.qat /etc/c6xx_dev$num.conf
    done
    systemctl restart qat_service
    sleep 5
    ./cpa_sample_code > /$SCRIPT_ROOT/cpa_sample_code.txt
  fi
}

DownloadNASM(){
  read -p "Download NASM? (yes/no) " yn
  if [ $yn == 'yes' ]; then
    cd /
    wget --no-check-certificate https://www.nasm.us/pub/nasm/releasebuilds/2.14.02/nasm-2.14.02.tar.gz
    tar xf nasm-2.14.02.tar.gz
    mv nasm-2.14.02 nasm
    rm -rf nasm-2.14.02.tar.gz
  fi
}

InstallNASM(){
  read -p "Install NASM? (yes/no) " yn
  if [ $yn == 'yes' ]; then
    cd $NASM_ROOT
    ./autogen.sh
    ./configure
    make -j 10
    make install -j 10
  fi
}

UninstallNASM(){
  if [ -d "$NASM_ROOT" ]
  then
    cd $NASM_ROOT
    make clean
    cd
    rm -rf $NASM_ROOT
  fi
}

DownloadOpenssl(){
  read -p "Download Openssl? (yes/no) " yn
  if [ $yn == 'yes' ]; then
    echo "[Download OpenSSL1.1.1i]"
    cd /
    git clone https://github.com/openssl/openssl.git
    cd $OPENSSL_SOURCE
    git checkout OpenSSL_1_1_1i    
  fi
}

InstallOpenssl(){
  read -p "Install Openssl? (yes/no) " yn
  if [ $yn == 'yes' ]; then 
    cd $OPENSSL_SOURCE
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

DownloadIntelIpsec(){
  read -p "Download Intel IPsec? (yes/no) " yn
  if [ $yn == 'yes' ]; then
    cd /
    git clone https://github.com/intel/intel-ipsec-mb.git
    mv intel-ipsec-mb intel_ipsec_mb/
    cd $IPSEC_ROOT
    git checkout v0.54
  fi
}

InstallIntelIpsec(){
  read -p "Install Intel IPsec? (yes/no) " yn
  if [ $yn == 'yes' ]; then
    if [ $OS_NAME == 'rhel' ]
    then
      DownloadNASM
      InstallNASM
    fi
    cd $IPSEC_ROOT
    make -j 10
    if [ $OS_NAME == 'ubuntu' ]
    then
      rm /usr/lib/libIPSec_MB.*
      rm /lib/x86_64-linux-gnu/libIPSec_MB.*
      ln -s $IPSEC_ROOT/intel-ipsec-mb.h $IPSEC_ROOT/include/
      ln -s $IPSEC_ROOT/libIPSec_MB.so.0 /usr/lib/
      ## Error on RHEL
      ln -s $IPSEC_ROOT/libIPSec_MB.so.0 /lib/x86_64-linux-gnu/
      ln -s $IPSEC_ROOT/libIPSec_MB.so /lib/x86_64-linux-gnu/
    fi
    if [ $OS_NAME == 'rhel' ]
    then
      rm /usr/lib/libIPSec_MB.*
      ln -s $IPSEC_ROOT/intel-ipsec-mb.h $IPSEC_ROOT/include/
      ln -s $IPSEC_ROOT/libIPSec_MB.so.0 /usr/lib/
      ln -s $IPSEC_ROOT/libIPSec_MB.so /usr/lib/
    fi
  fi
}

UninstallIntelIpsec(){
  if [ -d "$IPSEC_ROOT" ]
  then
    cd $IPSEC_ROOT
    make uninstall
    make clean
    cd 
    rm -rf $IPSEC_ROOT
  fi
}

DownloadMB(){
  read -p "Download Crypto Multi-buffer Library? (yes/no) " yn
  if [ $yn == 'yes' ]; then
    cd /
    git clone https://github.com/intel/ipp-crypto.git
    cd $MB_LIB
    git checkout -b for_qat_engine_0_6_4
    git reset --hard ippcp_2020u3
  fi
}

InstallMB(){
  read -p "Install Crypto Multi-buffer Library? (yes/no) " yn
  if [ $yn == 'yes' ]; then
    if [ $OS_NAME == 'ubuntu' ]
    then
      apt-get install -y cmake libpcre3 libpcre3-dev nasm
    fi
    if [ $OS_NAME == 'rhel' ]
    then
      yum install -y cmake
    fi

    cd $MB_LIB/sources/ippcp/crypto_mb
    cmake . -B"_build" \
      -DOPENSSL_INCLUDE_DIR=$OPENSSL_INSTALL/include \
      -DOPENSSL_LIBRARIES=$OPENSSL_INSTALL/lib \
      -DOPENSSL_ROOT_DIR=$OPENSSL_SOURCE
    cd _build
    make all -j 10
    make install -j 10
  fi
}

UninstallMB(){
  if [ -d "$MB_LIB/sources/ippcp/crypto_mb/_build" ]
  then
    cd $MB_LIB/sources/ippcp/crypto_mb/_build
    make clean
    cd 
    rm -rf $MB_LIB
  fi
}

DownloadQATEngine(){
  read -p "Download QAT engine? (yes/no) " yn
  if [ $yn == 'yes' ]; then
    echo "[Download QAT Engine v0.6.4]"
    cd /
    git clone https://github.com/intel/QAT_Engine.git
    cd $QATENGINE_SOURCE
    git checkout v0.6.4
  fi
}

InstallQATEngine(){
  read -p "Install QAT engine? (yes/no) " yn
  if [ $yn == 'yes' ]; then
    export PERL5LIB=$PERL5LIB:$OPENSSL_SOURCE
    cd $QATENGINE_SOURCE
    ./autogen.sh
    if [[ "$WITH_QAT_SW" == "1" ]]
    then
      echo "[Configure QAT Engine with QAT SW]"
      sleep 3
      ./configure \
      --enable-multibuff_offload \
      --enable-vaes_gcm \
      --enable-ipsec_offload \
      --with-ipsec_install_dir=$IPSEC_ROOT  \
      --with-openssl_install_dir=$OPENSSL_INSTALL
    fi
    if [[ "$WITH_QAT_HW" == "1" ]]
    then
      echo "[Configure QAT Engine with QAT HW]"
      sleep 3
      ./configure \
        --with-qat_dir=$ICP_ROOT \
        --with-openssl_install_dir=$OPENSSL_INSTALL \
        --with-openssl_dir=$OPENSSL_SOURCE
    fi
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
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/ 
    echo ["Test QAT Engine"]
    systemctl stop qat_service
    for num in $(seq 0 $NUM_QAT_CONFIG)
    do
      \cp -f $CONFIG_DIR/c6xx_dev0.conf.openssl /etc/c6xx_dev$num.conf
    done
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
    for num in $(seq 0 $NUM_QAT_CONFIG)
    do
      \cp -f $CONFIG_DIR/c6xx_dev0.conf.openssl /etc/c6xx_dev$num.conf
    done
    systemctl start qat_service
    
    cd $OPENSSL_INSTALL/bin
    
    #RSA2K
    echo "[RSA2k Core 1c]"                                                                    > OpensslSpeedTest.txt
    taskset -c 2,66 ./openssl speed -elapsed -async_jobs 72 -multi 2 rsa2048                     >> OpensslSpeedTest.txt
    echo "[RSA2k QAT 1c]" >> OpensslSpeedTest.txt
    taskset -c 2,66 ./openssl speed -elapsed -engine qatengine -async_jobs 72 -multi 2 rsa2048 >> OpensslSpeedTest.txt
    echo "[RSA2k Core 8c]" >> OpensslSpeedTest.txt
    taskset -c 2-9,66-73 ./openssl speed -elapsed -async_jobs 72 -multi 16 rsa2048 >> OpensslSpeedTest.txt
    echo "[RSA2k QAT 8c]" >> OpensslSpeedTest.txt
    taskset -c 2-9,66-73 ./openssl speed -elapsed -engine qatengine -async_jobs 72 -multi 16 rsa2048 >> OpensslSpeedTest.txt

    #RSA4k
    echo "[RSA4k Core 1c]" >> OpensslSpeedTest.txt
    taskset -c 2,66 ./openssl speed -elapsed -async_jobs 72 -multi 2 rsa4096 >> OpensslSpeedTest.txt
    echo "[RSA4k QAT 1c]" >> OpensslSpeedTest.txt
    taskset -c 2,66 ./openssl speed -elapsed -engine qatengine -async_jobs 72 -multi 2 rsa4096 >> OpensslSpeedTest.txt
    echo "[RSA4k Core 8c]" >> OpensslSpeedTest.txt
    taskset -c 2-9,66-73 ./openssl speed -elapsed -async_jobs 72 -multi 16 rsa4096 >> OpensslSpeedTest.txt
    echo "[RSA4k QAT 8c]" >> OpensslSpeedTest.txt
    taskset -c 2-9,66-73 ./openssl speed -elapsed -engine qatengine -async_jobs 72 -multi 16 rsa4096 >> OpensslSpeedTest.txt

    #AES128-CBC-HMAC-SHA1
    echo "[AES128-CBC-HMAC-SHA1 Core 1c]" >> OpensslSpeedTest.txt
    taskset -c 2,66 ./openssl speed -elapsed -async_jobs 72 -multi 2 -evp aes-128-cbc-hmac-sha1 >> OpensslSpeedTest.txt
    echo "[AES128-CBC-HMAC-SHA1 QAT 1c]" >> OpensslSpeedTest.txt
    taskset -c 2,66 ./openssl speed -elapsed -engine qatengine -async_jobs 72 -multi 2 -evp aes-128-cbc-hmac-sha1 >> OpensslSpeedTest.txt
    echo "[AES128-CBC-HMAC-SHA1 Core 8c]" >> OpensslSpeedTest.txt
    taskset -c 2-9,66-73 ./openssl speed -elapsed -async_jobs 72 -multi 16 -evp aes-128-cbc-hmac-sha1 >> OpensslSpeedTest.txt
    echo "[AES128-CBC-HMAC-SHA1 QAT 8c]" >> OpensslSpeedTest.txt
    taskset -c 2-9,66-73 ./openssl speed -elapsed -engine qatengine -async_jobs 72 -multi 16 -evp aes-128-cbc-hmac-sha1 >> OpensslSpeedTest.txt

    #AES128-CBC-HMAC-SHA256
    echo "[AES128-CBC-HMAC-SHA256 Core 1c]" >> OpensslSpeedTest.txt
    taskset -c 2,66 ./openssl speed -elapsed -async_jobs 72 -multi 2 -evp aes-128-cbc-hmac-sha256 >> OpensslSpeedTest.txt
    echo "[AES128-CBC-HMAC-SHA256 QAT 1c]" >> OpensslSpeedTest.txt
    taskset -c 2,66 ./openssl speed -elapsed -engine qatengine -async_jobs 72 -multi 2 -evp aes-128-cbc-hmac-sha256 >> OpensslSpeedTest.txt
    echo "[AES128-CBC-HMAC-SHA256 Core 8c]" >> OpensslSpeedTest.txt
    taskset -c 2-9,66-73 ./openssl speed -elapsed -async_jobs 72 -multi 16 -evp aes-128-cbc-hmac-sha256 >> OpensslSpeedTest.txt
    echo "[AES128-CBC-HMAC-SHA256 QAT 8c]" >> OpensslSpeedTest.txt
    taskset -c 2-9,66-73 ./openssl speed -elapsed -engine qatengine -async_jobs 72 -multi 16 -evp aes-128-cbc-hmac-sha256 >> OpensslSpeedTest.txt

    #AES256-CBC-HMAC-SHA256
    echo "[AES256-CBC-HMAC-SHA256 Core 1c]" >> OpensslSpeedTest.txt
    taskset -c 2,66 ./openssl speed -elapsed -async_jobs 72 -multi 2 -evp aes-256-cbc-hmac-sha256 >> OpensslSpeedTest.txt
    echo "[AES256-CBC-HMAC-SHA256 QAT 1c]" >> OpensslSpeedTest.txt
    taskset -c 2,66 ./openssl speed -elapsed -engine qatengine -async_jobs 72 -multi 2 -evp aes-256-cbc-hmac-sha256 >> OpensslSpeedTest.txt
    echo "[AES256-CBC-HMAC-SHA256 Core 8c]" >> OpensslSpeedTest.txt
    taskset -c 2-9,66-73 ./openssl speed -elapsed -async_jobs 72 -multi 16 -evp aes-256-cbc-hmac-sha256 >> OpensslSpeedTest.txt
    echo "[AES256-CBC-HMAC-SHA256 QAT 8c]" >> OpensslSpeedTest.txt
    taskset -c 2-9,66-73 ./openssl speed -elapsed -engine qatengine -async_jobs 72 -multi 16 -evp aes-256-cbc-hmac-sha256 >> OpensslSpeedTest.txt

    #AES128-gcm
    echo "[AES128-GCM Core 1c]" >> OpensslSpeedTest.txt
    taskset -c 2,66 ./openssl speed -multi 2 -elapsed -evp aes-128-gcm >> OpensslSpeedTest.txt
    echo "[AES128-GCM QAT 1c]" >> OpensslSpeedTest.txt
    taskset -c 2,66 ./openssl speed -engine qatengine -multi 2 -elapsed -evp aes-128-gcm >> OpensslSpeedTest.txt
    echo "[AES128-GCM Core 8c]" >> OpensslSpeedTest.txt
    taskset -c 2-9,66-73 ./openssl speed -multi 16 -elapsed -evp aes-128-gcm >> OpensslSpeedTest.txt
    echo "[AES128-GCM QAT 8c]" >> OpensslSpeedTest.txt
    taskset -c 2-9,66-73 ./openssl speed -engine qatengine -multi 16 -elapsed -evp aes-128-gcm >> OpensslSpeedTest.txt
    
    #AES256-gcm
    echo "[AES256-GCM Core 1c]" >> OpensslSpeedTest.txt
    taskset -c 2,66 ./openssl speed -multi 2 -elapsed -evp aes-256-gcm >> OpensslSpeedTest.txt
    echo "[AES256-GCM QAT 1c]" >> OpensslSpeedTest.txt
    taskset -c 2,66 ./openssl speed -engine qatengine -multi 2 -elapsed -evp aes-256-gcm >> OpensslSpeedTest.txt
    echo "[AES256-GCM Core 8c]" >> OpensslSpeedTest.txt
    taskset -c 2-9,66-73 ./openssl speed -multi 16 -elapsed -evp aes-256-gcm >> OpensslSpeedTest.txt
    echo "[AES256-GCM QAT 8c]" >> OpensslSpeedTest.txt
    taskset -c 2-9,66-73 ./openssl speed -engine qatengine -multi 16 -elapsed -evp aes-256-gcm >> OpensslSpeedTest.txt

    ## ECDH Compute Key Asynchronous vs Synchronous vs Software
    #echo "[ECDH Core 1c]" >> OpensslSpeedTest.txt
    #taskset -c 2,66 ./openssl speed -multi 2 -elapsed -async_jobs 72 ecdh >> OpensslSpeedTest.txt
    #echo "[ECDH QAT 1c]" >> OpensslSpeedTest.txt
    #taskset -c 2,66 ./openssl speed -multi 2 -engine qatengine -elapsed -async_jobs 72 ecdh >> OpensslSpeedTest.txt
    #echo "[ECDH Core 8c]" >> OpensslSpeedTest.txt
    #taskset -c 2-9,66-73 ./openssl speed -multi 16 -elapsed -async_jobs 72 ecdh >> OpensslSpeedTest.txt
    #echo "[ECDH QAT 8c]" >> OpensslSpeedTest.txt
    #taskset -c 2-9,66-73 ./openssl speed -multi 16 -engine qatengine -elapsed -async_jobs 72 ecdh >> OpensslSpeedTest.txt


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

DownloadHaproxy(){
  read -p "Download Haproxy (yes/no)" yn
  if [ $yn == 'yes' ]; then
    cd /
    wget http://www.haproxy.org/download/1.9/src/haproxy-1.9.4.tar.gz --no-check-certificate
    tar -xf haproxy-1.9.4.tar.gz
    mv haproxy-1.9.4 haproxy
  fi
}

InstallHaproxy(){
  read -p "Install Haproxy (yes/no)" yn
  if [ $yn == 'yes' ]; then
    cd $HAPROXY_ROOT
    #export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/$OPENSSL_INSTALL/lib
    make -j10 TARGET=linux_glibc USE_OPENSSL=1 SSL_INC=$OPENSSL_INSTALL/include SSL_LIB=$OPENSSL_INSTALL/lib
  fi
}

UninstallHaproxy(){
  if [ -d $HAPROXY_ROOT ]
  then
    cd $HAPROXY_ROOT
    make uninstall
    make clean
    cd
    rm -rf $HAPROXY_ROOT
  fi
}

RunHaproxy(){
  read -p "Run Haproxy (yes/no)" yn
  if [ $yn == 'yes' ]; then
    pkill haproxy
    #Create certification
    cd $HAPROXY_ROOT
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/$OPENSSL_INSTALL/lib
    $OPENSSL_INSTALL/bin/openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 \
                                     -keyout myhaproxy.key -out myhaproxy.crt \
                                     -subj "/C=US/ST=MA /L=Hudson/O=Intel/OU=DCG/CN=dcg.intel.com"
    cat $HAPROXY_ROOT/myhaproxy.crt $HAPROXY_ROOT/myhaproxy.key > $HAPROXY_ROOT/myhaproxy.pem
    \cp -f $SCRIPT_ROOT/config/myhaproxy-qatengine.cfg $HAPROXY_ROOT/.
    \cp -f $SCRIPT_ROOT/config/myhaproxy-noqat.cfg $HAPROXY_ROOT/.
    taskset -c 6-11,70-75 $HAPROXY_ROOT/haproxy -f $HAPROXY_ROOT/myhaproxy-qatengine.cfg
    #taskset -c 6-11,70-75 $HAPROXY_ROOT/haproxy -f $HAPROXY_ROOT/myhaproxy-noqat.cfg
    touch /nginx/html/zero.html
    sleep 5
    ps -aux | grep haproxy
  fi
}

DownloadQATzip(){
  read -p "Download QATzip (yes/no)" yn
  if [ $yn == 'yes' ]; then
    echo "[Install QATzip]"
    cd /
    git clone https://github.com/intel/QATzip.git
    cd $QZ_ROOT
    git checkout v1.0.2
  fi
}

InstallQATzip(){
  read -p "Install QATzip (yes/no)" yn
  if [ $yn == 'yes' ]; then
    cd $QZ_ROOT
    echo 1024 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
    rmmod usdm_drv
    insmod $ICP_ROOT/build/usdm_drv.ko max_huge_pages=1024 max_huge_pages_per_process=64
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
  rmmod usdm_drv
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

DownloadNginx(){
  read -p "Download NGINX (yes/no)" yn
  if [ $yn == 'yes' ]; then
    cd /
    git clone https://github.com/intel/asynch_mode_nginx.git
    cd $NGINX_SOURCE
    git checkout v0.4.4
  fi
}

InstallNginx(){
  read -p "Install NGINX (yes/no)" yn
  if [ $yn == 'yes' ]; then
    cd $NGINX_SOURCE
    if [ $OS_NAME == 'ubuntu' ]
    then
      apt-get install -y zlib1g-dev
    fi
    if [ $OS_NAME == 'rhel' ]
    then 
      yum install -y zlib-devel pcre-devel
    fi
    if [[ "$WITH_QAT_SW" == "1" ]] || [[ "$WITH_HAPROXY" == "1" ]] || [[ "$WITH_QAT_HW" == "1" ]] && [[ "$WITH_QAT_ZIP" == "0" ]]
    then
      echo "[Configure Nginx with QAT_SW]"
      ./configure \
        --prefix=$NGINX_INSTALL_DIR \
        --with-http_ssl_module \
        --with-stream_ssl_module \
        --add-dynamic-module=modules/nginx_qat_module/ \
        --with-cc-opt="-DNGX_SECURE_MEM -I$OPENSSL_INSTALL/include -Wno-error=deprecated-declarations" \
        --with-ld-opt="-Wl,-rpath=$OPENSSL_INSTALL/lib -L$OPENSSL_INSTALL/lib -lz"
    fi
    if [[ "$WITH_QAT_HW" == "1" ]] && [[ "$WITH_QAT_ZIP" == "1" ]]
    then
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
    fi
    make -j 10
    make install -j 10
    mkdir -p /nginx/certs
    cd /nginx/certs
    $OPENSSL_INSTALL/bin/openssl req -x509 \
            -sha256 \
            -nodes \
            -days 365 \
            -newkey rsa:2048 \
            -keyout server.key \
            -out server.crt \
            -subj "/C=US/ST=MA /L=Hudson/O=Intel/OU=DCG/CN=dcg.intel.com"
  fi
}

UninstallNginx(){
  pkill nginx
  if [ -d $NGINX_SOURCE ]
  then
    rm -rf $NGINX_INSTALL_DIR
    cd $NGINX_SOURCE
    make clean
    cd
    rm -rf $NGINX_SOURCE
  fi
}

RunNginx(){
  read -p "Run NGINX (yes/no)" yn
  if [ $yn == 'yes' ]; then
    pkill nginx
    if [[ "$WITH_QAT_HW" == "1" ]] && [[ "$WITH_QAT_ZIP" == "1" ]]
    then
      echo "[Run Nginx with QATzip with 3c6t]"
      systemctl stop qat_service
      for num in $(seq 0 $NUM_QAT_CONFIG)
      do
        \cp -f $CONFIG_DIR/c6xx_dev$num.conf.qatzip /etc/c6xx_dev$num.conf
#        \cp -f $QZ_ROOT/config_file/c6xx/multiple_process_opt/c6xx_dev0.conf /etc/c6xx_dev$num.conf
      done
      echo "[Allocate Hugepage for QATzip]"
      echo 1024 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
      rmmod usdm_drv
      insmod $ICP_ROOT/build/usdm_drv.ko max_huge_pages=1024 max_huge_pages_per_process=16
      sleep 3
      systemctl start qat_service
      sleep 5
      \cp -f $CONFIG_DIR/nginx.conf.qatzip $NGINX_INSTALL_DIR/conf/nginx.conf.offload
      \cp -f $CONFIG_DIR/nginx.conf.gzip $NGINX_INSTALL_DIR/conf/nginx.conf
      taskset -c 2-10 $NGINX_INSTALL_DIR/sbin/nginx -c $NGINX_INSTALL_DIR/conf/nginx.conf.offload
      ## Gzip
      # taskset -c 2-10 $NGINX_INSTALL_DIR/sbin/nginx -c $NGINX_INSTALL_DIR/conf/nginx.conf
      sleep 5
      ps -aux | grep nginx
    fi  
    if [[ "$WITH_QAT_ZIP" == "0" ]] || [[ "$WITH_QAT_SW" == "1" ]]
    then
      systemctl stop qat_service
      for num in $(seq 0 $NUM_QAT_CONFIG)
      do
        \cp -f $CONFIG_DIR/c6xx_dev0.conf.openssl /etc/c6xx_dev$num.conf
      done
      systemctl start qat_service
      sleep 5
      if [[ "$WITH_HAPROXY" == "0" ]]
      then
        echo "[Run Nginx with 16c32t without Haproxy]"
        \cp -f $CONFIG_DIR/nginx.conf.mb $NGINX_INSTALL_DIR/conf/nginx.conf.offload
        \cp -f $CONFIG_DIR/nginx.conf.core $NGINX_INSTALL_DIR/conf/nginx.conf
        taskset -c 2-17,66-81 $NGINX_INSTALL_DIR/sbin/nginx -c $NGINX_INSTALL_DIR/conf/nginx.conf.offload
        #taskset -c 2-17,66-81 $NGINX_INSTALL_DIR/sbin/nginx -c $NGINX_INSTALL_DIR/conf/nginx.conf
      fi
      if [[ "$WITH_HAPROXY" == "1" ]]
      then
        echo "[Run Nginx with 4c8t with Haproxy]"
        \cp -f $CONFIG_DIR/nginx.conf.default $NGINX_INSTALL_DIR/conf/nginx.conf
        taskset -c 2-5,66-69 $NGINX_INSTALL_DIR/sbin/nginx -c $NGINX_INSTALL_DIR/conf/nginx.conf
      fi
      sleep 5
      ps -aux | grep nginx
      if [[ "$WITH_HAPROXY" == "1" ]]
      then
          RunHaproxy
      fi
    fi
  fi
}

InstallNginxStack(){
  InstallDependency
  if [[ "$WITH_QAT_HW" == "1" ]]; then
    DownloadQAT
    InstallQAT
    RunCPASampleCode
  fi
  DownloadOpenssl
  InstallOpenssl
  if [[ "$WITH_QAT_SW" == "1" ]]; then
    DownloadIntelIpsec
    InstallIntelIpsec
    DownloadMB
    InstallMB
  fi
  DownloadQATEngine
  InstallQATEngine
  QATEngineTest
  OpensslSpeedTest
  if [[ "$WITH_HAPROXY" == "1" ]]; then
    DownloadHaproxy
    InstallHaproxy
  fi 
  if [[ "$WITH_QAT_HW" == "1" ]] && [[ "$WITH_QAT_ZIP" == "1" ]]; then
    DownloadQATzip
    InstallQATzip
    #QATzipPerfTest
  fi 
  DownloadNginx
  InstallNginx
  RunNginx
}

UninstallQATzipStack(){
  UninstallNginx
  UninstallQATzip
  UninstallQATEngine
  UninstallOpenssl
  UninstallQAT
}


UninstallQATSWStack(){
  UninstallNginx
  UninstallHaproxy
  UninstallQATEngine
  UninstallIntelIpsec
  UninstallOpenssl
  UninstallMB
  UninstallNASM
}

InstallNginxStack
#UninstallQATzipStack
#UninstallQATSWStack
