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

echo ${1}和${2}

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
LocalIP=`ifconfig |grep "inet addr" |awk '{print $2}' |awk -F : '{print $2}' | grep -v '127.0.0.1'`
echo "======================>【0.初始化检测】<========================="
echo "---->本机IP为：$LocalIP"
echo ""
}

function CheckPromotion()
{
#应文明任务调度脚本段
echo "---->正在调用http://$LocalIP:7210/promotion/job，by应文明"
echo "    |--->"
curl  -H "Content-Type: application/json" -X POST -d '{"coupon_template_id":710,"pageSize":10,"pageNum":1}'  http://$LocalIP:7210/promotion/job/test.htm
echo ""
}

function ReleaseProject()
{
for((i=1;i<=2;i++))
        do 
		echo "---------------------------------------"
		echo "|    开始重启${2}$i工程      "
		echo "---------------------------------------"
		/opt/app/netty/nettystart.sh ${1}$i ${2}$i
		sleep 20
done

echo ""
}


GetIP
ReleaseProject $1 $2


if [ $promotionstatus = y ]
then
        CheckPromotion
fi
