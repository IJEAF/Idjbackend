# IJEAF Backend — API REST Spring Boot

Plateforme e-commerce spécialisée dans les produits africains authentiques.

**Stack** : Java 17 · Spring Boot 3.x · PostgreSQL + pgvector · JWT · FCM · Fedapay  
**Équipe Backend** : 3 développeurs (Senior · Middle · Junior)

---

## Table des matières

1. [Prérequis](#prérequis)
2. [Installation locale](#installation-locale)
3. [Structure du projet](#structure-du-projet)
4. [Conventions — lire absolument](#conventions--lire-absolument)
5. [Workflow Git](#workflow-git)
6. [Pull Requests](#pull-requests)
7. [CI / CD](#ci--cd)
8. [Variables d'environnement](#variables-denvironnement)
9. [Contact & ownership des modules](#contact--ownership-des-modules)

---

## Prérequis

| Outil | Version minimale |
|-------|-----------------|
| Java (JDK) | 17+ |
| Maven | 3.9+ |
| Docker & Docker Compose | 24+ |
| Git | 2.40+ |

---

## Installation locale

```bash
# 1. Cloner le repo
git clone https://github.com/ijeaf/ijeaf-backend.git
cd ijeaf-backend

# 2. Démarrer PostgreSQL + pgvector en local
docker-compose up -d

# 3. Copier le fichier d'environnement
cp .env.example .env
# Remplir les valeurs dans .env (voir section Variables d'environnement)

# 4. Build et lancement
mvn clean spring-boot:run -Dspring-boot.run.profiles=dev

# 5. Vérifier que l'API répond
curl http://localhost:8080/actuator/health

# 6. Swagger UI
open http://localhost:8080/swagger-ui.html
```

> **Docker doit être démarré** avant de lancer l'application.  
> Flyway applique automatiquement les migrations au démarrage.

---

## Structure du projet

```
src/main/java/com/ijeaf/platform/
├── config/          # Configuration globale (Security, DB, Async, Swagger)
├── modules/
│   ├── auth/        # JWT, OAuth2, OTP — OWNER: Senior
│   ├── user/        # Profils CLIENT/SUPPLIER/ADMIN — OWNER: Senior
│   ├── product/     # Catalogue, images, stock — OWNER: Middle
│   ├── category/    # CRUD catégories — OWNER: Middle
│   ├── order/       # Panier, commandes, statuts — OWNER: Middle
│   ├── payment/     # Fedapay, Mobile Money — OWNER: Middle
│   ├── subscription/# Plans, abonnements, parrainage — OWNER: Middle
│   ├── messaging/   # WebSocket temps réel — OWNER: Middle
│   ├── review/      # Avis et notation — OWNER: Junior
│   ├── favorite/    # Favoris client — OWNER: Junior
│   ├── notification/# FCM push notifications — OWNER: Junior
│   ├── analytics/   # Dashboards fournisseur + admin — OWNER: Junior
│   ├── admin/       # Gestion plateforme — OWNER: Junior
│   ├── search/      # Texte + vectoriel pgvector — OWNER: Senior
│   └── geolocation/ # GPS, géocodage inverse — OWNER: Senior
├── shared/
│   ├── exception/   # GlobalExceptionHandler + hiérarchie exceptions
│   ├── response/    # ApiResponse<T>
│   ├── security/    # JwtService, JwtAuthenticationFilter
│   └── util/        # Classes utilitaires sans état
└── infrastructure/  # FCM, S3, SMS, Email, Fedapay clients
```

---

## Conventions — lire absolument

> Voir **[CONTRIBUTING.md](./CONTRIBUTING.md)** pour le détail complet.

**Résumé rapide :**
- Une feature = une branche = une issue GitHub
- Nommage branche : `feature/NOM-MODULE-description` ou `fix/description`
- Commits : format Conventional Commits (`feat:`, `fix:`, `test:`, `docs:`, `chore:`)
- Toute PR doit passer le CI avant d'être mergée
- Code review obligatoire : 1 reviewer minimum (Senior review les PRs critiques)
- Jamais de push direct sur `main` ou `develop`

---

## Workflow Git

```
main          ← production uniquement, protégée
develop       ← branche d'intégration principale
feature/*     ← nouvelles fonctionnalités
fix/*         ← corrections de bugs
test/*        ← ajout de tests uniquement
docs/*        ← documentation uniquement
```

**Cycle de travail quotidien :**

```bash
# 1. Toujours partir de develop à jour
git checkout develop
git pull origin develop

# 2. Créer ta branche depuis develop
git checkout -b feature/auth-jwt-access-token

# 3. Coder, committer régulièrement
git add .
git commit -m "feat(auth): implement JWT access token generation"

# 4. Pousser ta branche
git push origin feature/auth-jwt-access-token

# 5. Ouvrir une Pull Request sur GitHub vers develop
```

---

## Pull Requests

- **Titre** : `[MODULE] Description courte` → ex: `[AUTH] Implement JWT access token`
- **Template** : remplir le template automatique (voir `.github/PULL_REQUEST_TEMPLATE.md`)
- **Lier l'issue** : mentionner `Closes #42` dans la description
- **Taille** : max ~400 lignes de diff — découper si plus grand
- **Tests** : toute PR doit inclure ses tests unitaires
- **Reviewer** : assigner le Senior pour les modules `auth`, `security`, `shared`

---

## CI / CD

À chaque Pull Request vers `develop` :

1. **Build** : `mvn clean compile`
2. **Tests** : `mvn test` (JUnit 5 + Mockito)
3. **Qualité** : Checkstyle (conventions Java)
4. **Coverage** : JaCoCo — minimum 70% sur les services

La PR ne peut pas être mergée si le CI est rouge.

---

## Variables d'environnement

Copier `.env.example` → `.env` (ne jamais committer `.env`).

| Variable | Description |
|----------|-------------|
| `DB_URL` | URL JDBC PostgreSQL |
| `DB_USERNAME` | Utilisateur base de données |
| `DB_PASSWORD` | Mot de passe base de données |
| `JWT_SECRET` | Clé secrète JWT (min 256 bits) |
| `JWT_ACCESS_EXPIRATION` | Durée access token en ms (défaut: 900000) |
| `JWT_REFRESH_EXPIRATION` | Durée refresh token en ms (défaut: 604800000) |
| `FEDAPAY_API_KEY` | Clé API Fedapay |
| `FIREBASE_CREDENTIALS_PATH` | Chemin vers le JSON credentials Firebase |
| `AWS_ACCESS_KEY` | Clé accès S3 (stockage images) |
| `AWS_SECRET_KEY` | Secret S3 |
| `AWS_BUCKET_NAME` | Nom du bucket S3 |
| `AFRIKSMS_API_KEY` | Clé API AfrikSMS (OTP) |
| `MAIL_USERNAME` | Email transactionnel (SMTP) |
| `MAIL_PASSWORD` | Mot de passe SMTP |

---

## Contact & ownership des modules

| Module | Owner | GitHub Handle |
|--------|-------|---------------|
| auth, user, search, geolocation, config, shared | **Senior** | @senior-handle |
| product, category, order, payment, subscription, messaging | **Middle** | @middle-handle |
| review, favorite, notification, analytics, admin | **Junior** | @junior-handle |

> En cas de doute sur un module, ouvrir une issue avec le label `question` et tagger le owner.
