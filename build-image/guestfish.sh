run
mount /dev/sda1 /
touch /etc/cloud/cloud-init.disabled

download /etc/ssh/sshd_config /tmp/sshd_config.new
! sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /tmp/sshd_config.new
! sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /tmp/sshd_config.new
upload /tmp/sshd_config.new /etc/ssh/sshd_config

umount /
quit
