export qemu_cmd_ppc="/home/ec2-user/vm-scripts/qemu-2.2.1/ppc64-softmmu/qemu-system-ppc64 -cpu POWER8 -M pseries"
export qemu_cmd_x86="qemu-system-x86_64 -smp 4 --enable-kvm"

if [ -z $qemu_arch ] ; then
	export qemu_arch="x86_64"
fi

if [ $qemu_arch == "ppc" ] ; then
	export qemu_cmd=$qemu_cmd_ppc
else
	export qemu_cmd=$qemu_cmd_x86
fi
