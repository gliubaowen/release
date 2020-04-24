#!/bin/bash

###############################################
# Filename:    update-src.sh
# Version:     0.1
# Date:        2020-04-24
# Author:      LiuBaoWen
# Email:       bwliush@cn.ibm.com
# Description: 更新源代码
# Notes:       
###############################################

workspaces=$(dirname "$0")

. $workspaces/common-constants

#项目名
app_name=$1

echo "更新源码开始"

export LANG="en_US.UTF-8"

cd $app_dir/$temp_dir/$app_name

git pull

echo $?

echo "更新源码完成"
