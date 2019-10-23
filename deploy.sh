#!/bin/bash

###############################################
# Filename:    deploy.sh 
# Version:     0.1
# Date:        2019-10-23
# Author:      LiuBaoWen
# Email:       bwliush@cn.ibm.com
# Description: 部署应用
# Notes:       
###############################################

#一，编译项目源码
#
#二，停止旧的应用
#
#三，备份旧的应用
#
#四，移动新应用，启动新应用
#
#五，检查是否启动成功
#
#六，启动成功则结束，启动失败则回滚

export LANG="en_US.UTF-8"

#项目名
app_name=$1

cd $app_dir/$temp_dir/$app_name

bash update-src.sh $app_name

#一，部署项目
mvn deploy -DskipTests

echo $?