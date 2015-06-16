build_name="$image-$MariaDBVersion"
echo Build name is $build_name
cmake . -DBUILDNAME=$build_name
#make 
sudo make install
. /usr/local/mariadb-maxscale/system-test/set_env.sh $replicationIP $galeraIP
ctest -VV -D Nightly 
#--track $image
#ctest -VV --track $image


date_str=`date +%Y%m%d-%H`
report_dir=/var/www/html/test/LOGS/$image/$source/$value/$date_str/
echo "dir for logs $report_dir"
rm -rf $report_dir/*
mkdir -p $report_dir

echo "moving logs"
mv LOGS/* $report_dir
chmod a+r -R  $report_dir

