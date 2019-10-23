#!/bin/bash

###############################################
# Filename:    rollback.sh
# Version:     0.1
# Date:        2019-10-23
# Author:      LiuBaoWen
# Email:       bwliush@cn.ibm.com
# Description: 回滚应用
# Notes:       
###############################################

workspaces=$(dirname "$0")

. $workspaces/common-constants

#项目名
app_name=$1

#停止发布失败应用
bash stop-app.sh $app_name

#还原旧的jar包

#启动原来应用
bash start-app.sh $app_name

echo $?
