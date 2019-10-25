#!/bin/bash

###############################################
# Filename:    install.sh 
# Version:     0.1
# Date:        2019-10-23
# Author:      LiuBaoWen
# Email:       bwliush@cn.ibm.com
# Description: MAVEN安装应用
# Notes:       
###############################################

export LANG="en_US.UTF-8"

workspaces=$(dirname "$0")

. $workspaces/common-constants

if [ $# -lt 1 ]
	then
	        echo "USAGE:$0 USAGE|APPNAME"
		    exit 1
fi

#项目名
app_name=$1

bash update-src.sh $app_name

cd $app_dir/$temp_dir/$app_name

#一，部署项目
mvn install -DskipTests

echo $?
