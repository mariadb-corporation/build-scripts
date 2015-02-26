sed -i "s/log_daemon_msg \"Starting MaxScale\"/export DAEMON_COREFILE_LIMIT='unlimited'; ulimit -c unlimited; log_daemon_msg \"Starting MaxScale\" /" /etc/init.d/maxscale
echo /tmp/core-%e-%s-%u-%g-%p-%t > /proc/sys/kernel/core_pattern
