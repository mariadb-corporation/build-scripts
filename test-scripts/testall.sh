. /usr/local/skysql/maxscale/system-test/set_env_f.sh $replicationIP $galeraIP
ssh -i $Maxscale_sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$Maxscale_IP "cd /usr/local/skysql/maxscale/; mkdir _build; cd _build; cmake ..; make testall"  
sleep 300
echo "testall done"

