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

# by wangyuan
#v0.4 更改分发机制
#v0.5 使用for循环
#v0.6 增加子脚本执行的判断，增加分发前的判断


ctx="/opt/app/netty/temp"
bakdir="/opt/app/netty/backup"
baseDir="/opt/app/netty"
LocalDir="/opt/app"
VersionServerIP=10.100.200.135
VersionType=netty
ReleaseDate="`date '+%Y%m%d'`_`date '+%H%M%S'`"
BakDate="`date '+%Y%m%d'`-`date '+%H%M%S'`"
ScriptKeepPeriod=30
echo ""


function GetIP()
{
LocalIP=`/sbin/ifconfig |grep "inet addr" |awk '{print $2}' |awk -F : '{print $2}' | grep -v '127.0.0.1'`
echo "======================>【0.发布初始化检测】<========================="
echo "---->本机IP为：$LocalIP"
echo ""
}



function UpdateScripts()
{
echo "---->开始备份当前脚本[$1.sh]"
echo "    |--->备份到$LocalDir/$VersionType/backup/script/$BakDate"
if [ ! -d "$LocalDir/$VersionType/backup/script/$BakDate" ]; then 
  mkdir -p $LocalDir/$VersionType/backup/script/$BakDate
fi 
mv $LocalDir/$VersionType/$1.sh $LocalDir/$VersionType/backup/script/$BakDate
echo "    |--->清理$ScriptKeepPeriod天前的脚本备份文件"
rm -rf `find $LocalDir/$VersionType/backup/script -maxdepth 2 -mindepth 1 -mtime +$ScriptKeepPeriod | grep sh`
echo ""
echo "---->开始下载最新脚本[$1.sh]"
cd $LocalDir/$VersionType/
wget -q http://$VersionServerIP/$VersionType/$VersionServer/$1.sh
if [ $? != 0 ]
then 
        echo "    |--->[×]更新失败，进行[$1.sh]脚本回滚"
        cp  $LocalDir/$VersionType/backup/script/$BakDate/$1.sh $LocalDir/$VersionType
        chmod 755 $LocalDir/$VersionType/$1.sh
else
        echo "    |--->[√]更新[$1.sh]成功"
        chmod 755 $LocalDir/$VersionType/$1.sh
        VersionClient=`grep VerSion $LocalDir/$VersionType/$1.sh  | cut -d = -f 2`
        echo "    |--->当前脚本版本号为:$VersionClient"
fi
}

function VersionCheck()
{
VersionClient=`grep VerSion $LocalDir/$VersionType/$1.sh  | cut -d = -f 2`
if [ $? = 0  ]
then 
	echo "    |--->[√]获取本地脚本的版本号成功，判断版本号合法性"
	LengthV=`echo $VersionClient | wc -L`
    if [ $LengthV -lt 4 ]; then
		echo "        |--->[×]版本号长度异常,开始强制更新"
		echo ""
		UpdateScripts $1
	else
		if [[ $VersionClient =~ ^[0-9]*.?[0-9]*$ ]] 
			then 
			echo "        |--->[√]版本号格式正确"
			VersionClient1=`echo $VersionClient | sed "s \.  "`
			VersionServer1=`echo $VersionServer | sed "s \.  "`
			if [ $VersionClient1 -eq $VersionServer1  ]
				then 
					echo "    |--->[√]当前脚本为最新版！均为$VersionClient"
			elif
				 [ $VersionClient1 -lt $VersionServer1  ]
				then
				ccc=`expr $VersionServer1 - $VersionClient1`
				
				if [ $ccc -gt 1 -a $ccc -lt 10 ] 
					then 
					echo "    |--->服务器版本为:$VersionServer"
					echo "    |--->本地版本为:$VersionClient"
					echo "    |--->[!]$1版本在兼容范围内,可用。但建议更新！"
					echo ""
				else 
					echo "    |--->服务器版本为:$VersionServer"
					echo "    |--->本地版本为:$VersionClient"
					echo "    |--->[×]当前$1版本和服务器版本差距太大，开始更新。。。。。"
					echo ""
					UpdateScripts $1	 
				fi
			else

				 echo "    |--->[×]当前版本比服务器还新！怎么可能！！！！"
				 echo ""
				 UpdateScripts $1	 
			fi			
		else
			echo "    |--->[×]版本号格式异常，开始强制更新"
			echo ""
			UpdateScripts $1
		fi
    fi
else
	echo "    |--->[×]获取本地脚本版本号失败，开始强制更新。。"
	echo ""
	UpdateScripts $1
fi

}


function CheckServer()
{
#echo "=========================================================================="
echo "---->开始检测$1版本...."
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



function replace()
{
wget -q http://$VersionServerIP/$VersionType/1.00/$1.sh
if [ $? = 0 ]
	then
		echo 下载成功
		chmod +x $1.sh
		mv  $1.sh $LocalDir/$VersionType
        chmod 755 $LocalDir/$VersionType/$1.sh
else 
	echo error
fi
}

rm -f   $LocalDir/$VersionType/nettyshard.sh
rm -f   $LocalDir/$VersionType/shard-monitor1.sh
rm -f   $LocalDir/$VersionType/shard-monitor2.sh*
rm -f   $LocalDir/$VersionType/shard-monitor5.sh*
rm -f   $LocalDir/$VersionType/portmonitor.sh*
rm -f   $LocalDir/$VersionType/nettyshard5.sh*
rm -f   $LocalDir/$VersionType/nettyshard2.sh*
rm -f   $LocalDir/$VersionType/portmonitor.sh*
rm -f   $LocalDir/$VersionType/nettystart.sh*
rm -f   $LocalDir/$VersionType/start-monitor1.sh*


GetIP
CheckServer start1
sleep 1
CheckServer apimonitor1


replace nettyshard5
replace nettyshard2
replace shard-monitor2
replace shard-monitor5
replace portmonitor
replace nettystart
replace start-monitor1


ls -ll $LocalDir/$VersionType/*.sh*




