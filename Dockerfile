# stage build
# 使用as为多阶段构建中的某一阶段命名
FROM maven:3.6.3-jdk-8 as build
RUN sed -i '/<mirrors>/a\ \
<mirror> \n\
     <id>nexus-aliyun</id> \n\
     <mirrorOf>central</mirrorOf> \n\
     <name>Nexus aliyun</name> \n\
     <url>http://maven.aliyun.com/nexus/content/groups/public</url>\n\
</mirror>' /usr/share/maven/conf/settings.xml
COPY . /tomcat-java-demo
WORKDIR /tomcat-java-demo
RUN mvn clean package -Dmaven.test.skip=true
# stage prod
FROM tomcat:8.5.47 as prod
RUN rm -rf /usr/local/tomcat/webapps/*
# 从构建的某一阶段复制文件
COPY --from=build /tomcat-java-demo/target/*.war /usr/local/tomcat/webapps/ROOT.war
WORKDIR /usr/local/tomcat/bin
EXPOSE 8080
CMD ["catalina.sh", "run"]
