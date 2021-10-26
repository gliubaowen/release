#!/bin/sh
# by wangyuan
# v1.0 压缩日志文件
baseDir="/opt/app/server" 
logDir="/opt/logs/tomcat"
#sleep 58
tomcatPort=`grep $1\= /opt/app/appPorts.properties | cut -d = -f2`
serverName="apache-tomcat-$tomcatPort"
Today="`date '+%Y%m%d'`-`date '+%H%M%S'`"
echo $Today切割$serverName日志
if      
        [ ! $1  ]
      then     
                echo 获取${1}端口失败,请检查传参！【退出】       
        exit 0
fi
cp $baseDir/$serverName/logs/catalina.out $baseDir/$serverName/logs/catalina.out-$Today
echo > $baseDir/$serverName/logs/catalina.out
Today1="`date '+%Y%m%d'`-`date '+%H%M%S'`"
echo $Today1切割完成 

echo "删除7天前的catalina、manager、localost.、localhost_access_log文件"

echo "---清除catalina.out logs"
echo `find $baseDir/$serverName/logs/ -maxdepth 1 -mindepth 1 -mtime +7 | grep catalina`
rm -rf `find $baseDir/$serverName/logs/ -maxdepth 1 -mindepth 1 -mtime +7 | grep catalina`

echo "---清除manager logs"
echo `find $baseDir/$serverName/logs/ -maxdepth 1 -mindepth 1 -mtie +7 | grep manager`
rm -rf `find $baseDir/$serverName/logs/ -maxdepth 1 -mindepth 1 -mtime +7 | grep manager`

echo "---清除localhost_access_log logs"
echo `find $baseDir/$serverName/logs/ -maxdepth 1 -mindepth 1 -mtime +7 | grep localhost_access_log`
rm -rf `find $baseDir/$serverName/logs/ -maxdepth 1 -mindepth 1 -mtime +7 | grep localhost_access_log`

echo "---清除localhost logs"
echo `find $baseDir/$serverName/logs/ -maxdepth 1 -mindepth 1 -mtime +7 | grep localhost.`
rm -rf `find $baseDir/$serverName/logs/ -maxdepth 1 -mindepth 1 -mtime +7 | grep localhost.`

echo "---对$baseDir/$serverName/logs 1天前的下文件进行压缩"
echo `find  $baseDir/$serverName/logs/  -type f -mtime +1 | grep -v \.gz `
find  $baseDir/$serverName/logs/  -type f -mtime +1 | grep -v \.gz  | xargs gzip

echo "==============$logDir================="
echo "---删除$logDir 7天前的下文件"
echo `find $logDir -maxdepth 2 -mindepth 1 -mtime +7 | grep $1`
rm -rf `find $logDir -maxdepth 2 -mindepth 1 -mtime +7 | grep $1`

echo "---对$logDir 1天前的下文件进行压缩"
echo `find  $logDir  -maxdepth 2 -mindepth 1 -type f -mtime +1 | grep -v \.gz | grep $1`
find  $logDir  -maxdepth 2 -mindepth 1 -type f -mtime +1 | grep -v \.gz | grep $1 | xargs gzip

echo "--------------------------------------------------"