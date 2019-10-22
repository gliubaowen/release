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

#项目名
app=$1

export LANG="en_US.UTF-8"

nohup java -jar 


