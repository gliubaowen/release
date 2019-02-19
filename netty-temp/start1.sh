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

#v0.4 增加端口检测
#v0.5 修改jvm参数 
#v0.6 1）增加backupall目录，用于保存历史版本
#     2）增加jar推送的判断
#v0.7 增加ip地址提示，改写函数方式
#v1.00 增加脚本判断及更新机制
#v1.50 本地保存30天。
#v1.60 增加jmx监听

export LANG="en_US.UTF-8"
source /etc/profile
baseDir="/opt/app/netty"
VerSion=1.60
KeepPeriod=30
portConfig="/opt/app/appPorts.properties"

getPortConfig(){
  args=($@)
  echo `sed -n "/${arg1}=/"p ${portConfig} | sed "s/${arg1}=//"`
}


arg1=${2}-start 
export portStart="`getPortConfig`"
arg1=${2}-stop
export portStop="`getPortConfig`"
arg1=${2}-jmx
export portJmx="`getPortConfig`"




function PortsCheck()
{
echo "    |--->[√]启动端口号是:$portStart"
echo "    |--->[√]关闭端口号是:$portStop"
echo "    |--->[√]JMX端口号是:$portJmx"
if      
    [ ! $portStart  ]
      then     
        echo "[×]发布脚本获取${2}端口失败,请检查传参！本次发布被取消！无需回滚"
        exit 1
fi
echo ""
}

function CreateFolders()
{
if [ ! -d "${baseDir}/running/$1/lib" ]
        then 
                mkdir -p ${baseDir}/running/$1/lib
fi 

if [ ! -d "${baseDir}/temp/$1/lib" ]
        then 
                mkdir -p ${baseDir}/temp/$1/lib
fi 

#保存上次运行的版本
if [ ! -d "${baseDir}/backup/$1/lib" ]
        then 
                mkdir -p ${baseDir}/backup/$1/lib
fi 

#保存历史版本
if [ ! -d "${baseDir}/backupall/$1" ]
        then 
                mkdir -p ${baseDir}/backupall/$1
fi 
}

function ShutdownProject()
{
kill -9 `cat ${baseDir}/running/$1/main.pid`
echo "    |--->[√]关闭${2}系统成功..."
echo ""
}

function MvProject()
{
echo "    |--->备份运行项目[$2]"
rm -rf ${baseDir}/backup/$1/*
mv ${baseDir}/running/$1/* ${baseDir}/backup/$1/
rm -f  ${baseDir}/backup/$1/main.pid
echo ""
}

function DeployProject()
{
echo "    |--->开始部署新的代码到running目录"
cp -f ${baseDir}/temp/$1/*.jar ${baseDir}/running/$1/
cp -rf ${baseDir}/temp/$1/lib ${baseDir}/running/$1
echo "        |--->[√]部署完成"
echo ""
}

function CompareProjectDate()
{
SourceJarDate=`stat $baseDir/temp/${1}/*.jar | grep Change | awk '{print $2}'|sed s/-//g`
TodayDate=`date '+%Y%m%d'`
echo "    |--->源包的时间是:$SourceJarDate"
echo "    |--->今天的时间是:$TodayDate"
if
        [ "$SourceJarDate" -eq "$TodayDate" ]
         then
                echo "        |--->[√]Jar包是今天生成的"
        else
                echo "        |--->[×]Jar包不是今天生成的，请注意！！！"
fi
echo ""
}



function CompareProjectMd5()
{
SourceJarMd5=`/usr/bin/md5sum $baseDir/temp/${1}/*.jar  | awk '{print $1}'`
DestJarMd5=`/usr/bin/md5sum ${baseDir}/running/$1/*.jar  | awk '{print $1}'`
echo "    |--->编译完的包的MD5值是:$SourceJarMd5"
echo "    |--->计划发布包的MD5值是:$DestJarMd5"
if
    [ "$SourceJarMd5" = "$DestJarMd5" ]
  then
    echo "        |--->[√]计划发布的Jar包和本次编译的Jar包一样"
  else
    echo "        |--->[×]计划发布的Jar包和本次编译的Jar包不一样，请注意！！"
    echo "        |--->[×]$2退出发布!!!本次发布被取消！需回滚!!!!!!!!!"
    exit 1
fi
echo ""
}

function StartProject()
{
echo "    |--->后台启动进程"
nohup java -DLOG_HOME=${2} -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=${portJmx} -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false  -Duser.timezone=GMT+08 -Xms4096m -Xmx4096m -Xss512K -XX:PermSize=512m -XX:MaxPermSize=1024m -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/home/netty/jvmdump -jar ${baseDir}/running/$1/*.jar start ${portStart} ${portStop} >/dev/null  & 
echo $! >  ${baseDir}/running/$1/main.pid
sleep 5
echo "        |--->[√]启动完成"
echo ""
}


function CheckProjectStatus()
{
sleep 5
nettyPid=`cat ${baseDir}/running/$1/main.pid`
processIds=`ps -ef | grep $2\/ | grep -v grep  | grep java | grep -v $0 | awk '{print $2}'`
echo "    |--->当前[文件]中的PID是$nettyPid"
echo "    |--->当前[进程]中的PID是$processIds"
if
        [ "$nettyPid" -eq "$processIds" ]
         then
                echo "        |--->[√]$2服务已重启成功"
        else
                echo "        |--->[×]$2服务重启异常，需手工重启....."
fi
echo ""
}

function Bakproject()
{
JarDate="`date '+%Y%m%d'`-`date '+%H%M%S'`"
echo "    |--->正在清除缓存目录..."
mv ${baseDir}/temp/$1 ${baseDir}/backupall/$1/$JarDate
echo "        |--->[√]缓存目录已移动至${baseDir}/backupall/$1/$JarDate"
for((i=$KeepPeriod;i<=365;i++));
	do
		Warnum1=`find  ${baseDir}/backupall/$1 -maxdepth 1 -mindepth 1 -mtime +$i | grep $2 | wc -l`
		Warnum2=`ls -l ${baseDir}/backupall/$1 | grep -v total | wc -l`
		#字符串转为数字
		War_num1_exp=`expr $Warnum1`
		War_num2_exp=`expr $Warnum2`
		#判断文件个数，不能全部删除备份。
		if [ $War_num1_exp -lt $War_num2_exp ]
		then 
			echo "    |--->开始清除$i天前目录..."
			echo   `find  ${baseDir}/backupall/$1 -maxdepth 1 -mindepth 1 -mtime +$i`
			rm -rf `find  ${baseDir}/backupall/$1 -maxdepth 1 -mindepth 1 -mtime +$i`
			echo "    |--->[√]清理完成"
		fi
	break
done

echo ""
}




echo "---->1.1 获取端口号..."
PortsCheck $1 $2
CreateFolders $1 $2

echo "---->1.2 关闭$2系统"
ShutdownProject $1 $2

echo "---->1.3 备份$2系统"
MvProject $1 $2

echo "---->1.4 部署新的代码"
DeployProject $1 $2

echo "---->1.5 判断jar包的生成日期"
CompareProjectDate $1 $2

echo "---->1.6 判断jar包的md5值"
CompareProjectMd5 $1 $2

echo "---->1.7 开始运行服务"
StartProject $1 $2

echo "---->1.8 检测$2进程状态"
CheckProjectStatus $1 $2

echo "---->1.9 备份、清理$2项目代码"
Bakproject $1 $2
sleep 1
