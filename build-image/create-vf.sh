#echo 1 > /sys/bus/pci/devices/0000\:18\:00.0/sriov_numvfs
#echo 1 > /sys/bus/pci/devices/0000\:18\:00.1/sriov_numvfs
#echo 1 > /sys/bus/pci/devices/0000\:af\:00.0/sriov_numvfs
#echo 1 > /sys/bus/pci/devices/0000\:af\:00.1/sriov_numvfs
#echo 1 > /sys/bus/pci/devices/0000\:b1\:00.0/sriov_numvfs
#echo 1 > /sys/bus/pci/devices/0000\:b1\:00.1/sriov_numvfs

ip link set enp24s0f0 vf 0 mac a2:39:6e:12:73:ad spoofchk off trust on
ip link set enp24s0f1 vf 0 mac 62:6e:0e:4d:87:e3 spoofchk off trust on
ip link set enp175s0f0 vf 0 mac ca:5c:ce:46:60:74 spoofchk off trust on
ip link set enp175s0f1 vf 0 mac 1e:77:e9:24:7c:b1 spoofchk off trust on
ip link set enp177s0f0 vf 0 mac 12:18:2f:cb:97:57 spoofchk off trust on
ip link set enp177s0f1 vf 0 mac 2a:7f:cb:e0:37:3e spoofchk off trust on

ip link show enp24s0f0
ip link show enp24s0f1
ip link show enp175s0f0
ip link show enp175s0f1
ip link show enp177s0f0
ip link show enp177s0f1
