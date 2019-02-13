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
VersionServerIP=172.255.112.7
VersionType=netty
ReleaseDate="`date '+%Y%m%d'`_`date '+%H%M%S'`"
BakDate="`date '+%Y%m%d'`-`date '+%H%M%S'`"
ScriptKeepPeriod=30
echo ""
echo 当前时间为：$ReleaseDate
echo 备份目录是：$bakdir/${1}/$ReleaseDate
echo 参数1是：${1}，
echo 参数2是：${2}
echo 当前临时目录是：${ctx}


promotionstatus="$3"
case "$promotionstatus" in
        y|Y|Yes|YES|yes|yES|yEs|YeS|yeS)
    echo ""
    promotionstatus="y"
    ;;
        n|N|No|NO|no|nO)
    echo ""
    promotionstatus="n"
    ;;
        *)
    echo ""
    promotionstatus="n"
esac

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

function FilesExist()
{
if 
        $(ls -l  $baseDir/temp/$1 | grep jar > /dev/null) && $(ls -l  $baseDir/temp/$1/lib | grep jar > /dev/null) 
then 
        echo "    |--->[√]jar包推送成功,准备发布工程..."
else 
        echo "    |--->[×]获取jar包失败！！！本次发布被取消！无需回滚"
        exit 1
fi
echo ""
}



function  distribute()
{
for((i=1;i<=5;i++))        
    do 
		echo "    |--->[√]正在操作${2}$i"
        echo "        |--->[√]删除${ctx}/${1}$i中旧的jar包和lib库"
        rm -rf ${ctx}/${1}$i
        echo "        |--->[√]正在分发新jar包及lib库到${ctx}/${1}$i"
        cp -r ${ctx}/${1} ${ctx}/${1}$i
        echo ""
		sleep 1
done
echo ""
}

function ReleaseProject()
{
for((i=1;i<=5;i++))
        do
		echo "---------------------------------------"
		echo "|    开始发布${2}$i工程      "
		echo "---------------------------------------"
		echo "---->检测文件分发情况"
		FilesExist ${1}$i ${2}$i
		/opt/app/netty/start1.sh ${1}$i ${2}$i
		if [ $? != 0 ]
			then 
				exit 1
		fi
done
}

function MonitorProject()
{
for((i=1;i<=5;i++))
        do /opt/app/netty/apimonitor1.sh ${1}$i ${2}$i
done

echo ""
}

function DeleteSourceDir()
{
echo "--------->3.删除分发源目录<---------------------------"
echo ${ctx}/${1}
rm -rf ${ctx}/${1}
}


function CheckPromotion()
{
#应文明任务调度脚本段
echo "---->正在调用http://$LocalIP:7210/promotion/job，by应文明"
echo "    |--->"
/usr/bin/curl  -H "Content-Type: application/json" -X POST -d '{"coupon_template_id":710,"pageSize":10,"pageNum":1}'  http://$LocalIP:7210/promotion/job/test.htm
echo ""
}


GetIP
CheckServer start1
sleep 2
CheckServer apimonitor1
sleep 2
echo "---->检测源文件推送情况"
FilesExist $1 $2
sleep 1

echo "---->开始分发新的包到临时目录"
distribute $1 $2
sleep 1
echo "======================>【1.开始发布${2}工程】<========================="
echo ""
ReleaseProject $1 $2
sleep 1
if [ $promotionstatus = y ]
then
        CheckPromotion
fi

MonitorProject $1 $2
DeleteSourceDir $1 $2


