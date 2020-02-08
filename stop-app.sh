#!/bin/bash

###############################################
# Filename:    stop-app.sh
# Version:     0.1
# Date:        2019-10-23
# Author:      LiuBaoWen
# Email:       bwliush@cn.ibm.com
# Description: 停止应用
# Notes:       
###############################################

workspaces=$(dirname "$0")

. $workspaces/common-constants

#项目名
app_name=$1

jps | grep $app_name | grep -v grep | cut -c 1-5 | xargs kill -9

echo $?
