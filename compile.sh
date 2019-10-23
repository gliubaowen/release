#!/bin/bash

###############################################
# Filename:    compile.sh
# Version:     0.1
# Date:        2019-10-23
# Author:      LiuBaoWen
# Email:       bwliush@cn.ibm.com
# Description: 编译代码
# Notes:       
###############################################

workspaces=$(dirname "$0")

. $workspaces/common-constants

#项目名
app_name=$1

#进入项目目录
cd $app_dir/$temp_dir/$app_name

#build 项目源码
mvn package -DskipTests

echo $?
