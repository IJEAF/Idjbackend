#!/usr/bin/env bash
# =============================================================================
# IJEAF Backend — Script de setup automatique
# Usage : bash scripts/setup.sh
# =============================================================================

set -e  # Arrêter le script en cas d'erreur

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step()  { echo -e "\n${BLUE}[SETUP]${NC} $1"; }
print_ok()    { echo -e "${GREEN}  ✓${NC} $1"; }
print_warn()  { echo -e "${YELLOW}  ⚠${NC} $1"; }
print_error() { echo -e "${RED}  ✗${NC} $1"; }

echo ""
echo "======================================"
echo "   IJEAF Backend — Setup automatique  "
echo "======================================"

# ─── 1. Vérification Java 17 ───────────────────────────────────────────────
print_step "Vérification Java 17..."
if java -version 2>&1 | grep -q "17"; then
  print_ok "Java 17 détecté"
else
  print_error "Java 17 non trouvé. Installer JDK 17 Temurin : https://adoptium.net"
  exit 1
fi

# ─── 2. Vérification Maven ────────────────────────────────────────────────
print_step "Vérification Maven..."
if command -v mvn &> /dev/null; then
  MVN_VERSION=$(mvn -version 2>&1 | head -1)
  print_ok "$MVN_VERSION"
else
  print_error "Maven non trouvé. Installer Maven 3.9+ : https://maven.apache.org"
  exit 1
fi

# ─── 3. Vérification Docker ───────────────────────────────────────────────
print_step "Vérification Docker..."
if command -v docker &> /dev/null && docker info &> /dev/null; then
  print_ok "Docker est démarré"
else
  print_error "Docker n'est pas démarré. Lancer Docker Desktop puis relancer ce script."
  exit 1
fi

# ─── 4. Fichier .env ──────────────────────────────────────────────────────
print_step "Configuration du fichier .env..."
if [ ! -f ".env" ]; then
  cp .env.example .env
  print_warn "Fichier .env créé depuis .env.example"
  print_warn "→ Remplir les valeurs dans .env avant de continuer !"
  echo ""
  echo "  Ouvrir .env et remplir au minimum :"
  echo "  - DB_URL, DB_USERNAME, DB_PASSWORD"
  echo "  - JWT_SECRET"
  echo ""
  read -p "  Appuyer sur Entrée une fois le fichier .env rempli..."
else
  print_ok "Fichier .env déjà présent"
fi

# ─── 5. Démarrage PostgreSQL ──────────────────────────────────────────────
print_step "Démarrage de PostgreSQL + pgvector..."
docker compose up -d

echo -n "  Attente que PostgreSQL soit prêt"
for i in {1..15}; do
  if docker compose exec -T postgres pg_isready -U ijeaf -d ijeaf_dev &> /dev/null; then
    echo ""
    print_ok "PostgreSQL est prêt"
    break
  fi
  echo -n "."
  sleep 2
done

# ─── 6. Build Maven ───────────────────────────────────────────────────────
print_step "Téléchargement des dépendances Maven..."
mvn dependency:go-offline -q
print_ok "Dépendances téléchargées"

print_step "Compilation du projet..."
mvn clean compile -q
print_ok "Compilation réussie"

# ─── 7. Tests ─────────────────────────────────────────────────────────────
print_step "Lancement des tests..."
if mvn test -q; then
  print_ok "Tous les tests passent"
else
  print_warn "Certains tests échouent — normal si le code est incomplet"
fi

# ─── 8. Vérification Git ──────────────────────────────────────────────────
print_step "Vérification de la configuration Git..."
GIT_NAME=$(git config --global user.name || echo "")
GIT_EMAIL=$(git config --global user.email || echo "")

if [ -z "$GIT_NAME" ] || [ -z "$GIT_EMAIL" ]; then
  print_warn "Git non configuré."
  read -p "  Ton prénom et nom : " NAME
  read -p "  Ton email GitHub : " EMAIL
  git config --global user.name "$NAME"
  git config --global user.email "$EMAIL"
  print_ok "Git configuré : $NAME <$EMAIL>"
else
  print_ok "Git configuré : $GIT_NAME <$GIT_EMAIL>"
fi

# ─── 9. Résumé ────────────────────────────────────────────────────────────
echo ""
echo "======================================"
echo -e "   ${GREEN}Setup terminé avec succès !${NC}"
echo "======================================"
echo ""
echo "  Lancer l'application :"
echo "  → mvn spring-boot:run"
echo ""
echo "  Health check :"
echo "  → curl http://localhost:9090/actuator/health"
echo ""
echo "  Swagger UI :"
echo "  → http://localhost:9090/swagger-ui.html"
echo ""
echo "  Lire la documentation :"
echo "  → docs/SETUP_GUIDE.md"
echo "  → CONTRIBUTING.md"
echo ""
