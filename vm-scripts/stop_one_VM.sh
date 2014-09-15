#!/bin/bash

# $1 - last digits of IP

cat /home/ec2-user/kvm/f | sudo socat STDIO UNIX-CONNECT:/tmp/socket$1
