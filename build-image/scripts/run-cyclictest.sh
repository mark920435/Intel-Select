PROXY=/root/scripts/set-proxy.sh
CYCLICTEST=/root/rt-tests-0.92/cyclictest

source $PROXY
for i in $(seq 0 9); do mypid=`pgrep -o ksoftirqd\/$i`;chrt -f -p 2 $mypid; done
for i in $(seq 0 9); do mypid=`pgrep -o ktimersoftd\/$i`;chrt -f -p 3 $mypid; done
for i in $(seq 0 9); do mypid=`pgrep -o rcuc\/$i`;chrt -f -p 4 $mypid; done
echo 0 > /sys/kernel/mm/ksm/merge_across_nodes
echo 2 > /sys/kernel/mm/ksm/run
echo -1 > /proc/sys/kernel/sched_rt_period_us
echo -1 > /proc/sys/kernel/sched_rt_runtime_us
echo 0 > /proc/sys/kernel/timer_migration

yum -y install screen
yum -y install sshpass
screen -d -m bash -c "taskset -c 1-8 $CYCLICTEST -a 1-8 -t 8 -m -n -q -p99 -D 30S -i 200 > cyclictest.log"
sleep 40

#sshpass -p intel123 scp -o StrictHostKeyChecking=no cyclictest.log root@192.168.122.1:/root/.
