#step 1: BUILD
FROM            docker.io/library/openjdk:21-ea AS builder
WORKDIR         /app
COPY            . /app/
RUN             chmod +x gradlew && ./gradlew bootJar --no-daemon -x test

#step 2 RUN
From            docker.io/redhat/ubi9
COPY            --from=builder /app/build/libs/*.jar /app/portfolio-service.jar
ENTRYPOINT      ["java", "-jar", "portfolio-service.jar"]