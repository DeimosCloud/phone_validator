# FROM openjdk:8-jdk-alpine
# COPY target/validator-0.0.1.jar backend-validator-0.0.1.jar
# ENTRYPOINT ["java","-jar","/backend-validator-0.0.1.jar"]

FROM openjdk:8-jdk-alpine
VOLUME /tmp
ARG JAVA_OPTS
ENV JAVA_OPTS=$JAVA_OPTS
COPY target/validator-0.0.1.jar phonevalidator-0.0.1.jar
EXPOSE 8080
# ENTRYPOINT exec java $JAVA_OPTS -jar phonevalidator1.jar
# For Spring-Boot project, use the entrypoint below to reduce Tomcat startup time.
ENTRYPOINT exec java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar phonevalidator1.jar
