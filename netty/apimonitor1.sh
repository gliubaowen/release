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

#v0.7 增加ip地址提示，改写函数方式
#v1.00 支持版本更新
#v1.01 增加netty心跳检测
#v1.20 修改端口检测机制
#v1.50 

export LANG="en_US.UTF-8"
source /etc/profile
VerSion=1.50
VersionServerIP=172.255.112.7
VersionType=netty
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

function GetIP()
{
LocalIP=`/sbin/ifconfig |grep "inet addr" |awk '{print $2}' |awk -F : '{print $2}' | grep -v '127.0.0.1'`
}

function PortsCheck()
{
echo "---->2.1 获取端口号..."
echo "    |--->[√]启动端口号是:$portStart"
echo "    |--->[√]关闭端口号是:$portStop"
if      
    [ ! $portStart  ]
      then     
        echo "    |--->[×]发布脚本获取${2}端口失败,请检查传参！本次发布被取消！无需回滚"
        exit 1
fi
echo ""
}

function PortStatus()
{
sleep 10
nc -v -w 10 -z 127.0.0.1 $portStart > /dev/null
if
	[ $? != 0 ]
        then
            echo "    |--->[×]$2服务异常"
	    else
            echo "    |--->[√]$2服务启动正常"
fi
echo ""
}

function CheckHearbt()
{
#/usr/bin/curl  -H "Content-Type: application/json" -X POST   http://10.201.128.104:6080/app/heartBeat
ContentPath=`/usr/bin/curl -s -m 2 http://$VersionServerIP/$VersionType/content-path/content-path.txt | grep $2 | cut -d  = -f2`
#echo $ContentPath
HearbtStatus=`/usr/bin/curl -s -m 2 -H "Content-Type: application/json" -X POST   http://$LocalIP:$portStart/$ContentPath/heartBeat`
#echo $HearbtStatus
echo $HearbtStatus  | grep active  > /dev/null
if [ $? = 0 ]
then
	echo "    |--->[√]检测到$2心跳,状态如下:"
	echo "    ----------------------------------------------------------------------------------------------------------------"
	echo "    $HearbtStatus"
	echo "    ----------------------------------------------------------------------------------------------------------------"
else
	echo "    |--->[×]未检测到$2心跳，请检测进程或者上下文是否正确"
fi
}


echo "======================>【2.开始检测${2}服务状态】<========================="
sleep 1
PortsCheck $1 $2
echo "---->2.2 正在检测${2}:$portStart端口状态"
PortStatus $1 $2

echo "---->2.3 检测$2心跳状态"
GetIP 
#echo $LocalIP
CheckHearbt $1 $2


