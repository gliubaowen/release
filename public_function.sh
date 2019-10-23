#!/bin/bash

###############################################
# Filename:    public_function.sh
# Version:     2.0
# Date:        2019-10-23
# Author:      LiuBaoWen
# Email:       bwliush@cn.ibm.com
# Description: 常用的公共方法
# Notes:       
###############################################

workspaces=$(dirname "$0")

. ${workspaces}/common-constants

#配置文件
#geodeConfig="/opt/app/geode.properties"
echo "[info] 配置文件为:${geodeConfig}"

#读取文件关键字
cfm_prop(){
	arg1=$1
	echo `sed -n "/$arg1=/"p ${geodeConfig} | sed "s/${arg1}=//"`
}

#检查配置文件
check_conf()
{
echo -e '\n[info]====================校验配置文件开始===================='

	if [ -f ${geodeConfig} ] ; then
		echo "[success] 配置文件: ${geodeConfig} 存在"
	else
		echo "[error]   配置文件: ${geodeConfig} 未找到"
		exit 1
	fi
	
	if [ -s ${geodeConfig} ] ; then
		echo "[success] 配置文件: ${geodeConfig} 正常"
	else
		echo "[error]   配置文件: ${geodeConfig} 为空"
		exit 2
	fi
	
	echo -e '[info]====================校验配置文件结束====================\n'
}

#加载配置文件
load_profile(){
	check_conf
	cfm_locator_name="`cfm_prop gemfire-locator-name`"
	echo "[info] gemfire locator name  :$cfm_locator_name"
	cfm_server_name="`cfm_prop gemfire-server-name`"
	echo "[info] gemfire server name  :$cfm_server_name"
	host_master="`cfm_prop host_master`"
	echo "[info] host-master :$host_master"
	host_slave="`cfm_prop host_slave`"
	echo "[info] host-slave :$host_slave"
	local_host="`cfm_prop local_host`"
	echo "[info] localhost :$local_host"
}
