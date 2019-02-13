#!/bin/sh
baseDir="/opt/app/server"
VersionServerIP=172.255.112.7
VersionType=tomcat
BakDate="`date '+%Y%m%d'`-`date '+%H%M%S'`"
ScriptKeepPeriod=30

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
echo "    |--->备份到$baseDir/backup/script/$BakDate"
if [ ! -d "$baseDir/backup/script/$BakDate" ]; then 
  mkdir -p $baseDir/backup/script/$BakDate
fi 
mv $baseDir/$1.sh $baseDir/backup/script/$BakDate
echo "    |--->清理$ScriptKeepPeriod天前的脚本备份文件"
rm -rf `find $baseDir/backup/script -maxdepth 2 -mindepth 1 -mtime +$ScriptKeepPeriod | grep sh`
echo ""
echo "---->开始下载最新脚本[$1.sh]"
cd $baseDir/
wget -q http://$VersionServerIP/$VersionType/$VersionServer/$1.sh
if [ $? != 0 ]
then 
        echo "    |--->[×]更新失败，进行[$1.sh]脚本回滚"
        cp  $baseDir/backup/script/$BakDate/$1.sh $baseDir
        chmod 755 $baseDir/$1.sh
else
        echo "    |--->[√]更新[$1.sh]成功"
        chmod 755 $baseDir/$1.sh
        VersionClient=`grep VerSion $baseDir/$1.sh  | cut -d = -f 2`
        echo "    |--->当前脚本版本号为:$VersionClient"
fi
}

function VersionCheck()
{
VersionClient=`grep VerSion $baseDir/$1.sh  | cut -d = -f 2`
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
VersionClient=`grep VersionClient $baseDir/$1.sh  | cut -d = -f 2`
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
        $(ls -l  $baseDir/temp/ | grep "$1.war" > /dev/null) 
then 
        echo "    |--->[√]war包推送成功,准备发布工程..."
else 
        echo "    |--->[×]获取war包失败！！！本次发布被取消！无需回滚.............】"
        exit 1
fi
echo ""
}

echo "#############################################################################################################################################"
echo "======================>【0.发布初始化检测】<========================="
GetIP
CheckServer start1
CheckServer apimonitor1

echo "---->检测文件推送情况"
FilesExist $1

echo "======================>【1.开始发布工程】<========================="
echo "---------------------------------------"
echo "|    开始发布${1}工程      "
echo "---------------------------------------"
/opt/app/server/start1.sh ${1} ${1}
if [ $? != 0 ]
	then 
	exit 1
fi
echo ""
echo "======================>【2.开始检测工程】<========================="
	echo "---------------------------------------"
	echo "|    开始检测${1}工程      "
	echo "---------------------------------------"
/opt/app/server/apimonitor1.sh ${1} ${1}
echo "#############################################################################################################################################"