#!/bin/bash

# -------------------------------------------------------------------------------
# Filename:     
# Version:     1.0
# Date:        2018-11-07
# Author:      LiuBaoWen
# Email:       bwliush@cn.ibm.com
# Description: 
# Notes:       
# -------------------------------------------------------------------------------

export LANG="en_US.UTF-8"
source /etc/profile
getPortConfig(){
  args=($@)
  echo `sed -n "/${arg1}=/"p ${portConfig} | sed "s/${arg1}=//"`
}
baseDir="/opt/app/netty"
portConfig="/opt/app/appPorts.properties"
arg1=${2}-start 
export portStart="`getPortConfig`"
arg1=${2}-stop
export portStop="`getPortConfig`"
Version=1.00

function PortsCheck()
{
echo "    |--->[√]启动端口号是:$portStart"
echo "    |--->[√]关闭端口号是:$portStop"
if      
    [ ! $portStart  ]
      then     
        echo "[×]发布脚本获取${2}端口失败,请检查传参！本次发布被取消！无需回滚"
        exit 1
fi
echo ""
}


function ShutdownProject()
{
kill -9 `cat ${baseDir}/running/$1/main.pid`
echo "    |--->[√]关闭${2}系统成功..."
echo ""
}

function StartProject()
{
echo "    |--->后台启动进程"
nohup java -DLOG_HOME=${2} -Xms4096m -Xmx4096m -Xss512K -XX:PermSize=512m -XX:MaxPermSize=1024m -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/home/netty/jvmdump -jar ${baseDir}/running/$1/*.jar start ${portStart} ${portStop} >/dev/null  & 
echo $! >  ${baseDir}/running/$1/main.pid
sleep 5
echo "        |--->[√]启动完成"
echo ""
}




echo "---->1.1 获取端口号..."
PortsCheck $1 $2
echo "---->1.2 关闭$2系统"
ShutdownProject $1 $2
echo "---->1.3 开始运行服务"
StartProject  $1 $2
