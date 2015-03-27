#set -x
#. ./set_env.sh $replicationIP $galeraIP
#ssh -i $maxscale_sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$maxscale_IP "cd $maxdir; mkdir _build; cd _build; cmake ..; make testall"  
#sleep 300
#echo "testall done"

