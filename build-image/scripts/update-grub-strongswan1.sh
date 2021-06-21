OLD_GRUB=$(cat /etc/default/grub | grep GRUB_CMDLINE_LINUX | cut -d "\"" -f 2)
NEW_GRUB="$OLD_GRUB crashkernel=auto console=ttyS0,115200 rw hugepagesz=1G hugepages=8 default_hugepagesz=1G panic=30 init=/sbin/init intel_pstate=disable nmi_watchdog=0 audit=0 nosoftlockup processor.max_cstate=1 intel_idle.max_cstate=1 hpet=disable mce=off tsc=reliable numa_balancing=disable memory_corruption_check=0"

sed -i "s@$OLD_GRUB@$NEW_GRUB@" /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
sleep 30
reboot
