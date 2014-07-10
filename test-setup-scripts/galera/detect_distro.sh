#!/bin/bash
release_info==$(cat /etc/*-release 2>/dev/null)
 
        if [[ $(echo "$release_info" | grep 'Red Hat') != "" || $(echo "$release_info" | grep 'CentOS') != "" ]]; then 
                distro_type="redhat"; 
        elif [[ $(echo "$release_info" | grep 'Ubuntu') != "" ]] ; then 
                distro_type="ubuntu"; 
        elif [[ $(echo "$release_info" | grep 'Debian') != "" ]]; then 
                distro_type="debian"; 
	elif [[ $(echo "$release_info" | grep 'Fedora') != "" ]]; then 
		distro_type="fedora";
        fi;  



if [[ "x$distro_typeo" == "x" ]] ; then       # debian 6 may not have any /etc/*-release
        deb_ver=$(cat /etc/debian_version 2>/dev/null) 
        if [[ "$deb_ver" =~ 6\..* ]] ; then 
                distro_type="debian"
        fi
fi

if [[ "$release_info" == "" ]]; then
        echo "Error: unable to determine target machine OS version."
        exit 1
fi

# Now distro version
case "$distro_type" in
        "redhat")
                linux_name="CentOS"
                repoArch=""
                distro_version=$(release_info=$(cat /etc/*-release); \
                        [[ "$release_info" =~ [[:space:]]*([0-9]*\.[0-9]*) ]] && echo ${BASH_REMATCH[1]})
                ;;
        "fedora")
                linux_name="Fedora"
                repoArch=""
                distro_version=$(release_info=$(cat /etc/*-release); \
                        [[ "$release_info" =~ [[:space:]]*([0-9]*\.[0-9]*) ]] && echo ${BASH_REMATCH[1]})
                ;;

        "debian")
                linux_name="Debian"
                repoArch=""
                distro_version=$(release_info=$(cat /etc/debian_version); \
                        [[ "$release_info" =~ [[:space:]]*([0-9]*\.[0-9]*) ]] && echo ${BASH_REMATCH[1]})
                case "$distro_version" in
                        "6"*) distro_version_name="squeeze"
                                ;;
                        "7"*) distro_version_name="wheezy"
                                ;;
                        "8"*) distro_version_name="sid"
                                ;;
                esac
                ;;
        "ubuntu")
                linux_name="Ubuntu"
                repoArch="[arch=amd64]"
                distro_version=`cat /etc/*-release | grep "DISTRIB_RELEASE=" | sed "s/DISTRIB_RELEASE=//"`
                distro_version_name=`cat /etc/*-release | grep "DISTRIB_CODENAME=" | sed "s/DISTRIB_CODENAME=//"`
                ;;
esac

echo $linuxname
echo $distro_version
echo $distro_version_name

