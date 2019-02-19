#!/bin/sh

#============v0.5============
# 2015-06-25
#新增发布工程判断，不是本机工程，退出
#新增日期及MD5判断

#============v0.6============
# 2015-08-31
#增加backupall目录，用于保存历史版本
#新增备份时间，可自定义
#============v0.7============
# 2015-09-02
#新增war包推送成功判断
#============v0.8============
#自定义保留天数
#============v0.9============
#函数化
#增加软连接检测
#增加查看mount目录
#增加软连接重新挂载
#============v1.3============
#增加pre环境mount的判断
#============v1.4============
#隐藏配置文件，普通用户不可读。
#============v1.5============
#对归档的备份删除进行判断，至少保留一个归档。


#生效当前会话的环境变量
source /etc/profile
VerSion=1.50
function GetIP()
{
#环境判断
LocalIP=`/sbin/ifconfig |grep "inet addr" |awk '{print $2}' |awk -F : '{print $2}' | grep -v '127.0.0.1'`
echo "---->本机IP为：$LocalIP"
echo $LocalIP | grep 10.201.64.
if [ $? = 0 ]
	then VersionServerIP=10.201.64.39
	else
	VersionServerIP=172.255.112.7
fi
echo "配置服务器地址:$VersionServerIP"
}
GetIP

KeepPeriod=30
baseDir="/opt/app/server" 

function VarCheck()
{
if [ ! $1  ]
then 
	echo "    |--->[×]传参1异常"
	exit 1
else
	echo "    |--->[√]参数1:$1"
	if [ ! $2 ]
		then 
			echo "    |--->[×]传参2异常"
			exit 1
	else
			echo "    |--->[√]参数2:$2"
	fi
fi
echo ""
}



function PortsCheck()
{
tomcatPort=`grep $1\= /opt/app/appPorts.properties | cut -d = -f2`
if	[ ! $tomcatPort  ]
	then     
		echo "    |--->[×]获取${1}端口失败,请检查传参！本次发布被取消！无需回滚 "
		exit 1
	else				
		echo "    |--->[√]启动端口号是:${tomcatPort}"
		serverName="apache-tomcat-$tomcatPort"
		echo "    |--->[√]tomcat目录:${serverName}"
fi
echo ""
}


function CreateFolders()
{
#echo "-->备份当前的运行文件"
if [ ! -d "$baseDir/backup/$1" ]; then 
  mkdir -p $baseDir/backup/$1
fi 
#echo "保存历史版本"
if [ ! -d "${baseDir}/backupall/$1" ]; then 
 mkdir -p ${baseDir}/backupall/$1
fi 
}

function DeployProject()
{

echo "    |--->正在拷贝新包{"$baseDir/temp/$1.war"}到运行目录{"$baseDir/$serverName/webapps/"}..."
cp -f $baseDir/temp/$1.war $baseDir/$serverName/webapps/
if [ $1 != $2 ]
	then
	mv $baseDir/$serverName/webapps/$1.war $baseDir/$serverName/webapps/$2.war
fi
echo ""
}


function CompareProjectMd5()
{
#MD5值校验
SourceJarMd5=`/usr/bin/md5sum $baseDir/temp/$1.war  | awk '{print $1}'`
DestJarMd5=`/usr/bin/md5sum $baseDir/$serverName/webapps/$2.war  | awk '{print $1}'`
echo "    |--->编译完的包的MD5值是:$SourceJarMd5"
echo "    |--->计划发布包的MD5值是:$DestJarMd5"
if
         [ "$SourceJarMd5" = "$DestJarMd5" ]
         then
                echo "        |--->[√]计划发布的war包和本次编译的war包一样"
        else
                echo "        |--->[×]计划发布的war包和本次编译的war包不一样，请注意！！"
                echo "        |--->[×]$1退出发布!!!本次发布被取消！需回滚!!!!!!!!!"
                exit 1
fi
echo ""
}



function CompareProjectDate()
{
SourceJarDate=`stat $baseDir/temp/$1.war | grep Change | awk '{print $2}'|sed s/-//g`
#war包日期校验
TodayDate=`date '+%Y%m%d'`
echo "    |--->源包的时间是:$SourceJarDate"
echo "    |--->今天的时间是:$TodayDate"
if
        [ "$SourceJarDate" -eq "$TodayDate" ]
         then
                echo "        |--->[√]war包是今天生成的"
        else
                echo "        |--->[×]war包不是今天生成的，请注意！！！"
fi
echo ""
}

function ShutdownProject()
{
echo "    |--->判断软连接情况-1ST[发布前]"
ls -l  $baseDir/$serverName/webapps/$2 | grep ^l > /dev/null
if [ $? = 0 ]
	then
		echo "        |--->发现${2}工程存在软连接:"
		echo "---------------------------------------------------------------------"	
		ls -l  $baseDir/$serverName/webapps/$2 | grep ^l 
		echo "---------------------------------------------------------------------"
		SourceLinkServer=$( /usr/bin/curl -s -m 2 http://$VersionServerIP/tomcat/SymbolicLinks/SymbolicLinks.txt | grep ${2} | cut -d : -f2)
		DestdirLinkServer=$( /usr/bin/curl -s -m 2 http://$VersionServerIP/tomcat/SymbolicLinks/SymbolicLinks.txt | grep ${2} | cut -d : -f3)
		DestdirLinkLocal=$( ls -l  $baseDir/$serverName/webapps/$2 | grep ^l | awk '{print $9}'  )
		SourceLinkLocal=$( ls -l  $baseDir/$serverName/webapps/$2 | grep ^l | awk '{print $11}'  )
		echo "        |--->SourceLinkServer=$SourceLinkServer"
		echo "        |--->DestdirLinkServer=$DestdirLinkServer"
		echo "        |--->DestdirLinkLocal=$DestdirLinkLocal"
		echo "        |--->SourceLinkLocal=$SourceLinkLocal"
		if [ "$DestdirLinkServer" = "$DestdirLinkLocal" -a "$SourceLinkServer" = "$SourceLinkLocal" ]
		then
			echo "        |--->本地软连接源目和服务器记载的一致"
			echo "        |--->开始卸载软连接"
			cd $baseDir/$serverName/webapps/$2
			rm -f $DestdirLinkServer
		echo "---------------------------------------------------------------------"	
		ls -l  $baseDir/$serverName/webapps/$2 | grep ^l 
		echo "---------------------------------------------------------------------"
		else
			echo "        |--->本地软连接目标路径和服务器记载的不一致....请检查远程服务器和本地配置"
			echo "        |--->移除刚刚编译的war包，本次发布退出【无需回滚】"
			rm -f $baseDir/$serverName/webapps/$2.war
			exit 1
		fi
		
	else
		echo "        |--->未发现该${2}项目本地的软连接"
		DestdirLinkServer=$( /usr/bin/curl -s -m 2 http://$VersionServerIP/tomcat/SymbolicLinks/SymbolicLinks.txt | grep ${2} | cut -d : -f3)
		SourceLinkServer=$( /usr/bin/curl -s -m 2 http://$VersionServerIP/tomcat/SymbolicLinks/SymbolicLinks.txt | grep ${2} | cut -d : -f2)		
		if  [ ! $DestdirLinkServer ]
		then 
			echo "        |--->服务器无该项目的软连接记载，该项目不存在软链接...."
		
		else	
			echo "        |--->服务器有该项目的软连接记载，本地没有---->软连接已丢失，发布完成后将重建"
		fi
fi

echo "    |--->尝试正常关闭tomcat： $serverName的$tomcatPort"
#正常关闭tomcat
$baseDir/$serverName/bin/catalina.sh stop
sleep 15
#判断tomcat是否正常关闭，否则强制关闭
processIds=`ps -ef  | grep $serverName |grep -v grep  | grep java | grep -v $0 | awk '{print $2}'`
if
	[ ! "$processIds"  ]
	then
		echo "    |--->[√]正常关闭${1}系统成功"
	else
		echo "    |--->[√]正常关闭${1}系统失败，正在强制关闭..."
		kill -9 $processIds
fi
echo ""
}


function MvProject()
{
#不移除userfile、uploadFile以及参数1的文件夹
if [ -d "$baseDir/$serverName/webapps/$2" ]; then 
 rm -rf  $baseDir/backup/$1/*
 echo "    |--->备份运行项目[$1]"
 #echo `find $baseDir/$serverName/webapps/$2 -maxdepth 1 ! -name "userfiles" ! -name "uploadFile" ! -name $1 -type d`
 find $baseDir/$serverName/webapps/$2 -maxdepth 1 ! -name "userfiles" ! -name "uploadFile" ! -name $1 -type d| xargs -i mv -f {} $baseDir/backup/$1/
fi 
echo ""
}


function StartProject()
{
echo "    |--->开始静默解压$2.war"
cd $baseDir/$serverName/webapps
#静默解压
unzip -o -q $2.war -d $2
if [ $? != 0 ]
then
	echo "    |--->[×]解压失败,发布失败！本次发布被取消！无需回滚 "
else
	echo "    |--->移除$2.war"
	rm -f $baseDir/$serverName/webapps/$2.war
	
	echo "    |--->开始启动$1服务..."
	nohup $baseDir/$serverName/bin/startup.sh &
	sleep 5
	
###########################################
if [ $DestdirLinkServer ]
	then
		if [ "$DestdirLinkServer" = "$DestdirLinkLocal" -a "$SourceLinkServer" = "$SourceLinkLocal" ]
		then
			echo "        |--->本地软连接源目和服务器记载的一致，创建软连接"
			cd $baseDir/$serverName/webapps/$2
			ln -s $SourceLinkServer $DestdirLinkServer
		else
			if [ $DestdirLinkServer ]
				then
					echo "    |--->本地无软连接，服务器记载有----->本地软连接丢失：新建软连接"
					cd $baseDir/$serverName/webapps/$2
					ln -s $SourceLinkServer $DestdirLinkServer
				else
					echo "    |--->该项目不存在软链接"
			fi
	fi
fi
###########################################
	echo "    |--->判断软连接情况-2ND[发布后]"
	ls -l  $baseDir/$serverName/webapps/$2 | grep ^l > /dev/null
		if [ $? = 0 ]
			then
				echo "    |--->发现${2}工程存在软连接:"
				echo "---------------------------------------------------------------------"
				ls -l  $baseDir/$serverName/webapps/$2 | grep ^l 
				echo "---------------------------------------------------------------------"
			else
				echo "    |--->未发现该${2}项目的软连接"
		fi
	echo "    |--->查看远程mount情况"
	echo "----------------------------------------------------------------------------------------------------------------------------"
	sudo mount | column -t | grep nfs | grep addr | awk '{print $1,$2,$3,$5,$6}'
	echo "----------------------------------------------------------------------------------------------------------------------------"
fi
echo ""
}

function ConfigHidden()
{
#隐藏配置文件
echo "    |--->隐藏配置文件"
	#find /opt/app/server/apache-tomcat-21080/webapps/blgroup-osp-mbr/WEB-INF/classes | grep properties | grep -v i18n | grep -v log4j | grep -v shiro
	echo `find $baseDir/$serverName/webapps/$1/WEB-INF/classes | grep properties | grep -v i18n | grep -v log4j | grep -v shiro`
	chmod 700 `find $baseDir/$serverName/webapps/$1/WEB-INF/classes | grep properties | grep -v i18n | grep -v log4j | grep -v shiro`
	echo "----------------------------------------------------------------------------------------------------------------------------"
	ls -lh `find $baseDir/$serverName/webapps/$1/WEB-INF/classes | grep properties | grep -v i18n | grep -v log4j | grep -v shiro`
	echo "----------------------------------------------------------------------------------------------------------------------------"
}


function Bakproject()
{
echo "    |--->开始备份$2.war 到$baseDir/backupall/$1"
wardate="`date '+%Y%m%d'`-`date '+%H%M%S'`"
mv $baseDir/temp/$1.war $baseDir/backupall/$1/$2-$wardate.war

for((i=$KeepPeriod;i<=365;i++));
do
Warnum1=`find  $baseDir/backupall/$1 -mtime +$i | grep $2 | grep war | wc -l`
Warnum2=`ls -l $baseDir/backupall/$1 | grep -v total | wc -l`
#字符串转为数字
War_num1_exp=`expr $Warnum1`
War_num2_exp=`expr $Warnum2`
#判断文件个数，不能全部删除备份。
	if [ $War_num1_exp -lt $War_num2_exp ]
		then 
		echo "    |--->开始清除$i天前的war包"
		echo `find $baseDir/backupall/$1 -maxdepth 1 -mindepth 1 -mtime +$i | grep war`
		rm -rf `find $baseDir/backupall/$1 -maxdepth 1 -mindepth 1 -mtime +$i | grep war`
		echo "    |--->[√]清理完成"
	fi

break
done
}

echo "---->1.1 检测传参...."
VarCheck $1 $2

echo "---->1.2 获取端口...."
PortsCheck $1 $2

#创建文件夹
CreateFolders $1  $2

echo "---->1.3 关闭$1系统"
ShutdownProject $1 $2

echo "---->1.4 部署新的war包"
DeployProject $1 $2

echo "---->1.5 判断jar包的md5值"
CompareProjectMd5 $1 $2

echo "---->1.6 判断war包的生成日期"
CompareProjectDate $1 $2

echo "---->1.7 备份$2系统"
MvProject $1 $2

echo "---->1.8 开始运行服务"
StartProject $1 $2

echo "---->1.9 开始运行服务"
ConfigHidden $1 $2

echo "---->2.0 备份、清理$2项目"
Bakproject $1 $2