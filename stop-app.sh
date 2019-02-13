#!/bin/bash

# -------------------------------------------------------------------------------
# Filename:    stop-app.sh
# Version:     0.1
# Date:        2018-11-07
# Author:      LiuBaoWen
# Email:       bwliush@cn.ibm.com
# Description: 
# Notes:       
# -------------------------------------------------------------------------------

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

workspaces=$(dirname "$0")

. $workspaces/common-constants

#项目名
app=$1



