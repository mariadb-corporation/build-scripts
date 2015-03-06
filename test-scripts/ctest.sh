build_name="$image-$MariaDBVersion"
echo Build name is $build_name
cmake . -DBUILDNAME=$build_name
make 
. ./set_env_f.sh $replicationIP $galeraIP
ctest -VV -D Nightly 
#--track $image
#ctest -VV --track $image


date_str=`date +%Y%m%d-%H`
report_dir=/var/www/html/test/LOGS/$image/$source/$value/$date_str/
rm -rf $report_dir/*
mkdir -p $report_dir

mv LOGS/* $report_dir
