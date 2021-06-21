if [ -z "$BUILD_IMAGE_DIR" ]
then
    echo "export BUILD_IMAGE_DIR=<path to build-image directory>"
    exit
fi

read -p "Make sure your system has network access. Do you want to continue? (Y/N) " yn
if [ $yn != 'Y' ]
then exit
fi

#export http_proxy=http://proxy-us.intel.com:911
#export https_proxy=http://proxy-us.intel.com:911

APPLICATION=$1
IMAGE_URL=https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2.xz
IMAGE_DIR=/var/lib/libvirt/images
IMAGE=$IMAGE_DIR/$APPLICATION.qcow2
GUESTFISH_FILE=$BUILD_IMAGE_DIR/guestfish.sh
XML=$BUILD_IMAGE_DIR/xml/$APPLICATION.xml
VM_NAME=$APPLICATION
VM_SCRIPTS=$BUILD_IMAGE_DIR/scripts



if [ -z "$(env | grep ${APPLICATION}_MAC)" ] || [ -z "$(env | grep ${APPLICATION}_IP)" ]
then
    echo "export ${APPLICATION}_MAC=<MAC address for $APPLICATION VM>"
    echo "export ${APPLICATION}_IP=<IP address for $APPLICATION VM>"
    exit
else
    VM_IP=${APPLICATION}_IP
    VM_MAC=${APPLICATION}_MAC
fi

echo "VM_IP = ${!VM_IP}"
echo "VM_MAC = ${!VM_MAC}"

if [ ! -z "$(virsh list --all | grep $APPLICATION)" ]
then
  virsh list --all
  read -p "$APPLICATION VM exists. Do you want to re-create the $APPLICATION VM? (Y/N) " yn
  if [ $yn != 'Y' ]
  then exit
  else
    virsh destroy $APPLICATION
    virsh undefine $APPLICATION
  fi
fi

if [ -f $IMAGE ]
then
  echo "[Removing the existing $APPLICATION image...]"
  rm -f $IMAGE
fi

#wget -P $IMAGE_DIR $IMAGE_URL
#unxz $IMAGE_DIR/CentOS-7-x86_64-GenericCloud.qcow2.xz
cp $IMAGE_DIR/CentOS-7-x86_64-GenericCloud.qcow2 $IMAGE

echo "[Changing the password of the VM......]"
virt-customize -a $IMAGE --root-password password:intel123 --uninstall cloud-init

echo "[Setting up the management IP address......]"
virsh version
virsh net-list
virsh net-start default
virsh net-autostart --network default
virsh net-update default add ip-dhcp-host '<host mac="'${!VM_MAC}'" ip="'${!VM_IP}'"/>' --live --config
virsh net-destroy default
virsh net-start default

echo "[Enabling ssh on the VM......]"
yum -y install libguestfs-tools
guestfish --rw -a $IMAGE -f $GUESTFISH_FILE

echo "[Bringing up the VM......]"
setenforce 0
virsh define $XML
virsh start $VM_NAME

sleep 60

echo "[Installing ssh tools......]"
yum -y install sshpass
rm -f /root/.ssh/known_hosts
echo "" > $VM_SCRIPTS/set-proxy.sh
read -p "Apply proxy setting in the VM? (Y/N) " yn
if [ $yn == 'Y' ]
then
  read -p "Enter your proxy setting for http: " http_proxy
  echo "export http_proxy=$http_proxy" >> $VM_SCRIPTS/set-proxy.sh
  read -p "Enter your proxy setting for https: " https_proxy
  echo "export https_proxy=$https_proxy" >> $VM_SCRIPTS/set-proxy.sh
fi
echo "[Passing scripts to the VM......]"
sshpass -p intel123 scp -o StrictHostKeyChecking=no -r $VM_SCRIPTS root@${!VM_IP}:/root/.
echo "[Setting hostname......]"
sshpass -p intel123 ssh -o StrictHostKeyChecking=no root@${!VM_IP} "hostnamectl set-hostname $APPLICATION; reboot"
sleep 60
echo "[Updating kernel on the VM......]"
sshpass -p intel123 ssh -o StrictHostKeyChecking=no root@${!VM_IP} "./scripts/upgrade-kernel-$APPLICATION.sh"
sleep 60
#echo "Updating grub on the VM......"
#sshpass -p intel123 ssh -o StrictHostKeyChecking=no root@${!VM_IP} "./scripts/update-grub-$APPLICATION.sh"
#sleep 60
#echo "[Running $APPLICATION......]"
#sshpass -p intel123 ssh -o StrictHostKeyChecking=no root@${!VM_IP} "./scripts/install-$APPLICATION.sh;./scripts/run-$APPLICATION.sh"
#echo "[Sending the log back to the host......]"
#sshpass -p intel123 scp -o StrictHostKeyChecking=no root@${!VM_IP}:/root/$APPLICATION.log /root/.
