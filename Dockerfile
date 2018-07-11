FROM openjdk:8-jdk-alpine

RUN mkdir /app

COPY *.jar /app

WORKDIR /app

VOLUME ["/config"]

ENTRYPOINT ["java", "-jar", "berserker-runner-0.0.12-SNAPSHOT.jar"]