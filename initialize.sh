#!/bin/bash

# -------------------------------------------------------------------------------
# Filename:    initialize.sh 
# Version:     1.0.0
# Date:        2019-05-31
# Author:      LiuBaoWen
# Email:       bwliush@cn.ibm.com
# Description: 初始化项目 创建发布环境
# Notes:       
# -------------------------------------------------------------------------------

#工作空间
workspaces=$(dirname "$0")

. ${workspaces}/common-constants

:<<'COMMENT'
sed -i '$a 67.219.148.138 mirrorlist.centos.org' /etc/hosts
sed -i '$a 115.28.122.210 mirrors.aliyun.com' /etc/hosts
sed -i '$a 202.141.176.110 centos.ustc.edu.cn' /etc/hosts
sed -i '$a 193.219.28.2 ftp.icm.edu.pl' /etc/hosts
sed -i '$a 119.188.36.70 mirrors.sohu.com' /etc/hosts
sed -i '$a 218.104.71.170 mirrors.sohu.com' /etc/hosts
COMMENT

#创建发布使用的用户
#netty
#sudo useradd netty && echo 'netty@text' | passwd --stdin netty
#tomcat
#sudo useradd tomcat && echo 'tomcat@text' | passwd --stdin tomcat

#创建发布使用的目录结构
#netty
#mkdir -p $netty_app_dir
#mkdir -p $netty_app_dir/$script_dir
#mkdir -p $netty_app_dir/$run_dir
#mkdir -p $netty_app_dir/$backup_dir
#mkdir -p $netty_app_dir/$temp_dir
#chown -R netty:netty $netty_app_dir && chmod -R 755 $netty_app_dir
#tomcat
#mkdir -p $tomcat_app_dir
#mkdir -p $tomcat_app_dir/$script_dir
#mkdir -p $tomcat_app_dir/$run_dir
#mkdir -p $tomcat_app_dir/$backup_dir
#mkdir -p $tomcat_app_dir/$temp_dir
#chown -R tomcat:tomcat $tomcat_app_dir && chmod -R 755 $tomcat_app_dir

#创建日志目录
#netty
#mkdir -p $netty_log_dir && chown -R netty:netty $netty_log_dir && chmod -R 755 $netty_log_dir
#tomcat
#mkdir -p $tomcat_log_dir && chown -R tomcat:tomcat $tomcat_log_dir && chmod -R 755 $tomcat_log_dir

#创建发布使用的目录结构
mkdir -p $app_dir
mkdir -p $log_dir/$release_log
mkdir -p $app_dir/$temp_dir
mkdir -p $app_dir/$run_dir
mkdir -p $app_dir/$backup_dir

#使用yum安装使用的软件
yum install --nogpgcheck wget
yum install --nogpgcheck curl
yum install --nogpgcheck nc
yum install --nogpgcheck python
yum install --nogpgcheck lsof
yum install --nogpgcheck telnet

