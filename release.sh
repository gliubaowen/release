#!/bin/bash

# -------------------------------------------------------------------------------
# Filename:    release.sh
# Version:     0.1
# Date:        2019-05-31
# Author:      LiuBaoWen
# Email:       bwliush@cn.ibm.com
# Description: 发布应用
# Notes:       
# -------------------------------------------------------------------------------

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

#一，编译项目源码
bash compile.sh $app_name

#二，停止旧的应用
bash stop-app.sh $app_name

#三，备份旧的应用
#bash backup.sh $app_name

#四，移动新应用，启动新应用
bash start-app.sh $app_name

#五，检查是否启动成功
#bash monitor.sh $app_name

#六，启动成功则结束，启动失败则回滚
#bash rollback.sh $app_name

