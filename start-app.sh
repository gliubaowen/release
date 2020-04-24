#!/bin/bash

###############################################
# Filename:    start-app.sh
# Version:     0.1
# Date:        2020-04-24
# Author:      LiuBaoWen
# Email:       bwliush@cn.ibm.com
# Description: 启动应用
# Notes:       
###############################################

workspaces=$(dirname "$0")

. $workspaces/common-constants

export LANG="en_US.UTF-8"

#项目名
app_name=$1

echo "启动APP开始"

#进入项目目录
mkdir -p $app_dir/$run_dir/$app_name

cp $app_dir/$temp_dir/$app_name/target/$app_name*.jar $app_dir/$run_dir/$app_name/

echo exit | nohup java -jar $app_dir/$run_dir/$app_name/$app_name*.jar > $log_dir/$release_log/nohup.out &

echo $?

echo "启动APP完成"

