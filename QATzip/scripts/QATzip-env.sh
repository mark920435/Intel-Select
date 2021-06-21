export SCRIPT_ROOT=`pwd`
export ICP_ROOT=/QAT
export OPENSSL_SOURCE=/openssl
export OPENSSL_INSTALL=/usr/local/ssl
export OPENSSL_ENGINES=$OPENSSL_INSTALL/lib/engines-1.1
export QATENGINE_SOURCE=/QAT_Engine
export QZ_ROOT=/QATzip
export NGINX_INSTALL_DIR=/nginx
export NGINX_SOURCE=/asynch_mode_nginx
export CONFIG_DIR=$SCRIPT_ROOT/config
export IPSEC_ROOT=/intel_ipsec_mb
export NASM_ROOT=/nasm
export MB_LIB=/ipp-crypto
#export LD_LIBRARY_PATH=$OPENSSL_SOURCE:$ICP_ROOT/build/:$OPENSSL_LIB:/lib64/
export HAPROXY_ROOT=/haproxy
export OS_NAME=$(cat /etc/os-release | grep ID | sed -n 1p| cut -d "=" -f 2 | tr -d \")
export NUM_QAT_ENDPOINT=$(lspci | grep QuickAssist | wc -l)
export NUM_QAT_CONFIG=$((NUM_QAT_ENDPOINT-1))

export WITH_QAT_HW=1
export WITH_QAT_SW=0
export WITH_QAT_ZIP=1
export WITH_HAPROXY=0
