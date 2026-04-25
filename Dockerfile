# ─── Stage 1 : Build ───────────────────────────────────────────────────────
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app

# Copier pom.xml séparément pour profiter du cache Docker sur les dépendances
COPY pom.xml .
RUN mvn dependency:go-offline -B -q

# Copier les sources et builder
COPY src ./src
RUN mvn clean package -DskipTests -B -q

# ─── Stage 2 : Runtime ─────────────────────────────────────────────────────
FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

# Utilisateur non-root pour la sécurité
RUN groupadd -r ijeaf && useradd -r -g ijeaf ijeaf
USER ijeaf

# Copier le JAR depuis le stage de build
COPY --from=build /app/target/*.jar app.jar

# Port exposé
EXPOSE 8080

# Options JVM pour un container (limite mémoire, GC adapté)
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+UseG1GC"

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
