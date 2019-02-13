#!/bin/sh

#============version 0.9============
#函数化
#增加tomcat检测
#===========v1.3
#tomcat心跳
##################
#===========v1.4
#tomcat心跳判断兼容新老url

baseDir="/opt/app/server" 
VerSion=1.50




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

function PortStatus()
{
nc -v -w 10 -z 127.0.0.1 $tomcatPort > /dev/null
if
    [ $? != 0 ]
    then
        echo "    |--->[?]"$1"服务正在启动...."
        sleep 10
        nc -v -w 10 -z 127.0.0.1 $tomcatPort > /dev/null
            if [ $? != 0 ]
                then
                    echo "    |--->[×]"$1"服务端口离线...."
                else
                    echo "    |--->[√]"$1"服务端口在线"
            fi
    else
        echo "    |--->[√]"$1"服务端口在线"
fi
}

function ServiceStatus()
{
#http://127.0.0.1:28080/blgroup-osp-social/static/bootstrap/2.3.1/js/bootstrap.min.js
HTTP_CODE1=`curl -o /dev/null -s -w "%{http_code}" http://127.0.0.1:${tomcatPort}/${2}/static/bootstrap/2.3.1/js/bootstrap.min.js`
HTTP_CODE2=`curl -o /dev/null -s -w "%{http_code}" http://127.0.0.1:${tomcatPort}/${2}/static/heartBeat`
if [ x$HTTP_CODE1 = x200 -o x$HTTP_CODE2 = x200 ]
    then
        echo  "    |--->[√]"$1"应用访问正常"
	else
		echo  "    |--->[×]"$1"应用访问异常,请查看日志"
fi
echo ""
}

echo "---->2.1 获取端口...."
PortsCheck $1

echo "---->2.2 开始检测${1}服务端口状态"
sleep 10
PortStatus $1

echo "---->2.3 开始检测${1}应用访问状态"
ServiceStatus $1 $2
