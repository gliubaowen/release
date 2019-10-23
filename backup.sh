#!/bin/bash

###############################################
## Filename:    backup.sh
## Version:     0.1
## Date:        2019-10-23
## Author:      LiuBaoWen
## Email:       bwliush@cn.ibm.com
## Description: 备份应用
## Notes:       
###############################################

workspaces=$(dirname "$0")

. $workspaces/common-constants

#项目名
app_name=$1

cp $app_dir/$run_dir/$app_name/$app_name*.jar $app_dir/$backup_dir/$app_name/

echo $?
