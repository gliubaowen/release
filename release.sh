#!/bin/bash

# -------------------------------------------------------------------------------
# Filename:    release.sh
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

function GetIP()
{
LocalIP=`/sbin/ifconfig |grep "inet addr" |awk '{print $2}' |awk -F : '{print $2}' | grep -v '127.0.0.1'`
echo "======================>【0.发布初始化检测】<========================="
echo "---->本机IP为：$LocalIP"
echo ""
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

function FilesExist()
{
if 
        $(ls -l  $baseDir/temp/$1 | grep jar > /dev/null)
then 
        echo "    |--->[√]jar包推送成功,准备发布工程..."
else 
        echo "    |--->[×]获取jar包失败！！！本次发布被取消！无需回滚"
        exit 1
fi
echo ""
}

function CheckServer()
{
#echo "=========================================================================="
echo "---->开始检测$1版本...."
VersionClient=`grep VersionClient $LocalDir/$VersionType/$1.sh  | cut -d = -f 2`
VersionServer=`/usr/bin/curl -s -m 2 http://$VersionServerIP/$VersionType/version/$1.version`
if [ $? = 0 ]
    then
                echo  $VersionServer | grep nginx > /dev/null
                        if [ $? != 0 ] 
                                then 
                                VersionCheck $1
                        else
                                echo "    |--->[×]服务器上无[$1.sh]版本号,请检测服务器配置"
                                echo "    |--->[!]跳过版本校验，继续发布...."
                        fi

else
                echo "    |--->[×]版本服务器无响应,请检测服务器配置"
                echo "    |--->[!]跳过版本校验，继续发布...."
fi
echo ""
}


cd $app_dir



