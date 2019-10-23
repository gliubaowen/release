version:0.0.1

javaEE 项目发布步骤
一，编译项目源码

二，停止旧的应用

三，备份旧的应用

四，移动新应用，启动新应用

五，检查是否启动成功

六，启动成功则结束，启动失败则回滚


依赖: jdk, maven or gradle, nexus

构建命令示例
clean install -P pre -U

发布netty项目脚本 示例
/opt/app/netty/start-monitor1.sh member/member-admin member-admin

发布tomcat项目脚本 示例
/opt/app/server/start-monitor1.sh osp-campaign-web

后续需要集成 docker k8s oc 
