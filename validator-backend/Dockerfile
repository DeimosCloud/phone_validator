FROM maven:3.6.3 AS maven
WORKDIR /usr/src/app
COPY . /usr/src/app

RUN mvn clean install

# For Java 11, 
FROM openjdk:8-jdk-alpine

ARG JAR_FILE=validator-0.0.1.jar 

WORKDIR /opt/app/

COPY --from=maven /usr/src/app/target/${JAR_FILE} /opt/app/

ENTRYPOINT ["java","-jar","validator-0.0.1.jar"]
