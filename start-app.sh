#!/bin/bash

# -------------------------------------------------------------------------------
# Filename:    start-app.sh
# Version:     0.1
# Date:        2019-05-31
# Author:      LiuBaoWen
# Email:       bwliush@cn.ibm.com
# Description: 启动应用
# Notes:       
# -------------------------------------------------------------------------------

workspaces=$(dirname "$0")

. $workspaces/common-constants

export LANG="en_US.UTF-8"

#项目名
app=$1

#进入项目目录
cp $app_dir/$temp_dir/$app/target/$app*.jar $app_dir/$temp_dir/$app/$run_dir/

java -jar $app_dir/$temp_dir/$app/$run_dir/$app*.j


