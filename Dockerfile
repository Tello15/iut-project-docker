FROM eclipse-temurin:25-jdk AS builder

WORKDIR /app
COPY . .
RUN chmod +x gradlew && ./gradlew build -x test --no-daemon

FROM eclipse-temurin:25-jdk AS jre-builder
RUN $JAVA_HOME/bin/jlink \
    --add-modules java.base,java.naming,java.logging,java.management,java.security.jgss,java.desktop,java.xml,java.instrument \
    --strip-debug \
    --no-man-pages \
    --no-header-files \
    --compress=2 \
    --output /jre

FROM ubuntu:24.04

WORKDIR /app
COPY --from=jre-builder /jre /opt/jre
COPY --from=builder /app/build/libs/app.jar /app/app.jar

ENV PATH="/opt/jre/bin:$PATH"

EXPOSE 8080
CMD ["java", "-jar", "/app/app.jar"]


