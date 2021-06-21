OLD_GRUB=$(cat /etc/default/grub | grep GRUB_CMDLINE_LINUX | cut -d "\"" -f 2)
NEW_GRUB="$OLD_GRUB biosdevname=0 net.ifnames=0 no_timer_check clocksource=tsc tsc=perfect intel_pstate=disable idle=poll selinux=0 enforcing=0 nmi_watchdog=0 softlockup_panic=0 isolcpus=1-9 nohz_full=1-9 default_hugepagesz=1G hugepagesz=1G hugepages=5 rcu_nocbs=1-9 kthread_cpus=0 irqaffinity=0 rcu_nocb_poll"

sed -i "s/$OLD_GRUB/$NEW_GRUB/" /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
reboot
