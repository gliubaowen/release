#/bin/bash

# -------------------------------------------------------------------------------
# Filename:     
# Version:     1.0
# Date:        2018-11-07
# Author:      LiuBaoWen
# Email:       bwliush@cn.ibm.com
# Description: 
# Notes:       
# -------------------------------------------------------------------------------

path="`date '+%Y%m%d'`_`date '+%H%M%S'`"
AppPort=`more /opt/app/appPorts.properties | grep start | cut -d = -f 2`
 for allport in $AppPort;
    do 
     echo $allport;
     AppName=`more /opt/app/appPorts.properties | grep $allport| cut -d - -f 1,2`;
     lsof -i:$allport > /dev/null;
	if
		 [ $? != 0 ]
        then
            echo 【×】"$AppName"的"$allport"服务异常

	else
             echo 【√】"$AppName"的"$allport"服务启动正常
	fi
      echo "=============================="
      sleep 1	
done

