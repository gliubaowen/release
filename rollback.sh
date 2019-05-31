#!/bin/bash

# -------------------------------------------------------------------------------
# Filename:    rollback.sh
# Version:     0.1
# Date:        2018-11-07
# Author:      LiuBaoWen
# Email:       bwliush@cn.ibm.com
# Description: 回滚应用
# Notes:       
# -------------------------------------------------------------------------------

workspaces=$(dirname "$0")

. $workspaces/common-constants

#项目名
app=$1

#停止发布失败应用
./stop-app.sh
#启动原来应用
./start-app.sh

