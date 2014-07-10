cat /home/ec2-user/kvm/f | sudo socat STDIO UNIX-CONNECT:/tmp/socket002
cat /home/ec2-user/kvm/f | sudo socat STDIO UNIX-CONNECT:/tmp/socket2
echo "stopped..."
