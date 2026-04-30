# ─── Stage 1 : Build ───────────────────────────────────────────────────────
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app

# Copier pom.xml séparément pour profiter du cache Docker sur les dépendances
COPY pom.xml .
RUN mvn dependency:go-offline -B -q

# Copier les sources et builder
COPY src ./src
RUN mvn package -DskipTests -B -q

# Vérifier que le JAR a été créé
RUN ls -lh /app/target/*.jar || (echo "JAR not found!" && exit 1)

# ─── Stage 2 : Runtime ─────────────────────────────────────────────────────
FROM eclipse-temurin:17-jre-jammy

# Métadonnées
LABEL maintainer="IJEAF Team"
LABEL description="IJEAF Backend - Spring Boot REST API"
LABEL version="1.0"

WORKDIR /app

# Installer curl pour le HEALTHCHECK
RUN apt-get update && apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# Créer l'utilisateur non-root et le répertoire d'app avec les bonnes permissions
RUN groupadd -r ijeaf && useradd -r -g ijeaf ijeaf && \
    chown -R ijeaf:ijeaf /app

# Copier le JAR depuis le stage de build avec permissions correctes
COPY --chown=ijeaf:ijeaf --from=build /app/target/*.jar app.jar

# Vérifier que le JAR a été copié
RUN ls -lh /app/app.jar

# Port exposé
EXPOSE 9090

# Options JVM pour un container (limite mémoire, GC adapté)
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+UseG1GC -Dserver.port=9090"

# Health check (dépend de Spring Boot Actuator activé)
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:9090/actuator/health || exit 1

# Switch to non-root user
USER ijeaf

# EntryPoint avec array form (signal handling correct)
ENTRYPOINT ["java", "-jar", "app.jar"]
