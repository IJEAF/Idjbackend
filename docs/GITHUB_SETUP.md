# ⚙️ IJEAF Backend — Configuration GitHub complète (Guide Senior)

> Ce guide est destiné au **Senior Backend**.  
> À exécuter **une seule fois** avant que Middle et Junior rejoignent le projet.  
> Durée estimée : 45 minutes.

---

## Table des matières

1. [Créer le repository GitHub](#1-créer-le-repository-github)
2. [Configurer les branches et protections](#2-configurer-les-branches-et-protections)
3. [Créer les labels](#3-créer-les-labels)
4. [Créer les Milestones](#4-créer-les-milestones)
5. [Configurer GitHub Project (Kanban)](#5-configurer-github-project-kanban)
6. [Créer toutes les issues](#6-créer-toutes-les-issues)
7. [Configurer les GitHub Secrets (CI/CD)](#7-configurer-les-github-secrets-cicd)
8. [Inviter les collaborateurs](#8-inviter-les-collaborateurs)
9. [Pusher le code de base](#9-pusher-le-code-de-base)
10. [Vérification finale](#10-vérification-finale)

---

## 1. Créer le repository GitHub

### 1.1 Créer le repo

1. Aller sur **github.com → New repository**
2. Remplir :
   - **Repository name** : `ijeaf-backend`
   - **Description** : `API REST Spring Boot — Plateforme e-commerce africaine IJEAF`
   - **Visibility** : `Private`
   - ☑️ **Add a README file** : NON (on pushera le nôtre)
   - **Add .gitignore** : NON (on a le nôtre)
   - **Choose a license** : NON
3. Cliquer **Create repository**

### 1.2 Initialiser le repo local et pusher

```bash
# Dans le dossier du projet
git init
git add .
git commit -m "chore(init): initial project bootstrap"
git branch -M main
git remote add origin git@github.com:ijeaf/ijeaf-backend.git
git push -u origin main

# Créer et pusher la branche develop
git checkout -b develop
git push -u origin develop
```

---

## 2. Configurer les branches et protections

### 2.1 Créer les branches nécessaires

Les branches `main` et `develop` existent déjà depuis l'étape 1.  
Créer `staging` :

```bash
git checkout -b staging
git push -u origin staging
git checkout develop  # revenir sur develop
```

### 2.2 Protéger la branche `main`

Aller sur : **GitHub → Settings → Branches → Add branch ruleset**

**Ruleset pour `main` :**

| Paramètre | Valeur |
|-----------|--------|
| Ruleset name | `Protect main` |
| Target branches | `main` |
| Require a pull request before merging | ✅ |
| Required approvals | `1` |
| Dismiss stale pull request approvals | ✅ |
| Require status checks to pass | ✅ |
| Status checks required | `test` (le job CI) |
| Block force pushes | ✅ |
| Restrict deletions | ✅ |

Cliquer **Save changes**.

**Répéter pour `develop` :**

| Paramètre | Valeur |
|-----------|--------|
| Ruleset name | `Protect develop` |
| Target branches | `develop` |
| Require a pull request before merging | ✅ |
| Required approvals | `1` |
| Require status checks to pass | ✅ |
| Status checks required | `test` |
| Block force pushes | ✅ |

**Répéter pour `staging` avec les mêmes paramètres.**

---

## 3. Créer les labels

Aller sur : **GitHub → Issues → Labels → Edit labels**

Supprimer tous les labels par défaut, puis créer les suivants :

### Labels de type

| Nom | Couleur | Description |
|-----|---------|-------------|
| `feat` | `#0075CA` | Nouvelle fonctionnalité |
| `bug` | `#D73A4A` | Quelque chose ne fonctionne pas |
| `test` | `#E4E669` | Ajout ou modification de tests |
| `docs` | `#0075CA` | Documentation uniquement |
| `chore` | `#E4E669` | Tâche technique (config, migration) |
| `question` | `#D876E3` | Besoin de clarification |
| `blocked` | `#B60205` | Bloquée — nécessite une action |

### Labels de module

| Nom | Couleur |
|-----|---------|
| `module:auth` | `#C2E0C6` |
| `module:user` | `#C2E0C6` |
| `module:product` | `#BFD4F2` |
| `module:category` | `#BFD4F2` |
| `module:order` | `#BFD4F2` |
| `module:payment` | `#BFD4F2` |
| `module:subscription` | `#BFD4F2` |
| `module:messaging` | `#BFD4F2` |
| `module:review` | `#F9D0C4` |
| `module:favorite` | `#F9D0C4` |
| `module:notification` | `#F9D0C4` |
| `module:analytics` | `#F9D0C4` |
| `module:admin` | `#F9D0C4` |
| `module:search` | `#C2E0C6` |
| `module:shared` | `#EDEDED` |
| `module:infra` | `#EDEDED` |
| `module:ci` | `#EDEDED` |

### Labels de priorité

| Nom | Couleur |
|-----|---------|
| `priority:critical` | `#B60205` |
| `priority:high` | `#E4772B` |
| `priority:medium` | `#FBCA04` |
| `priority:low` | `#0E8A16` |

### Labels d'owner

| Nom | Couleur |
|-----|---------|
| `owner:senior` | `#5319E7` |
| `owner:middle` | `#0052CC` |
| `owner:junior` | `#006B75` |

---

## 4. Créer les Milestones

Aller sur : **GitHub → Issues → Milestones → New milestone**

Créer les 6 milestones suivantes :

| Titre | Description | Due date |
|-------|-------------|----------|
| `Phase 0 — Bootstrap` | Structure projet, config, CI | Fin semaine 1 |
| `Phase 1 — Auth & Core` | JWT, OAuth2, User, Product, Category | Fin semaine 3 |
| `Phase 2 — Commerce & Paiement` | Cart, Order, Fedapay, Review, Favorites | Fin semaine 5 |
| `Phase 3 — Avancé & Temps réel` | WebSocket, FCM, Subscription, Search, Géoloc | Fin semaine 7 |
| `Phase 4 — Admin & Analytics` | Dashboard, Admin, Analytics | Fin semaine 8 |
| `Phase 5 — Tests & Déploiement` | Coverage, CI/CD, VPS | Fin semaine 10 |

---

## 5. Configurer GitHub Project (Kanban)

### 5.1 Créer le Project

Aller sur : **github.com/ijeaf → Projects → New project**

1. Choisir **Board** (vue Kanban)
2. **Project name** : `IJEAF Backend — Sprint Board`
3. Cliquer **Create project**

### 5.2 Configurer les colonnes

Supprimer les colonnes par défaut et créer dans cet ordre :

| Colonne | Emoji | Description |
|---------|-------|-------------|
| Backlog | 📋 | Toutes les issues créées mais non démarrées |
| Sprint actuel | 🎯 | Issues assignées pour cette semaine |
| In Progress | 🔄 | En cours de développement |
| In Review | 👀 | PR ouverte, en attente de review |
| Done | ✅ | Mergée sur develop |

### 5.3 Configurer l'automatisation

Dans le Project → **Workflows** :

| Événement | Action automatique |
|-----------|-------------------|
| Issue opened | → Backlog |
| Pull request opened | → In Review |
| Pull request merged | → Done |
| Issue closed | → Done |

### 5.4 Configurer les vues

Créer ces vues additionnelles :

**Vue "Par développeur"** :
- Type : Board
- Grouper par : `Assignees`
- Utile pour le chef de projet pour voir qui fait quoi

**Vue "Par module"** :
- Type : Table
- Colonnes : Title · Assignees · Status · Priority · Milestone
- Grouper par : label `module:*`

**Vue "Roadmap"** :
- Type : Roadmap
- Grouper par : Milestone
- Permet au chef de projet de voir l'avancement global

### 5.5 Lier le Project au repository

Dans le Project → **Settings → Linked repositories** → Ajouter `ijeaf/ijeaf-backend`

---

## 6. Créer toutes les issues

### Instructions

Pour chaque issue ci-dessous :
1. Aller sur **GitHub → Issues → New issue**
2. Remplir le titre exact
3. Ajouter les labels indiqués
4. Assigner à la bonne personne
5. Lier à la bonne Milestone
6. Ajouter au Project (elle ira automatiquement en Backlog)

---

### Phase 0 — Bootstrap (Milestone: Phase 0 — Bootstrap)

#### Senior

**Issue #1**
- **Titre** : `[SETUP] Initialiser le projet Spring Boot 3.x avec structure modulaire complète`
- **Labels** : `chore` · `module:infra` · `priority:critical` · `owner:senior`
- **Description** :
  ```
  Générer le projet via Spring Initializr.
  Créer la structure de packages : config/, modules/, shared/, infrastructure/
  Configurer application.yml avec profils dev/staging/prod.
  Créer BaseEntity @MappedSuperclass.
  Créer ApiResponse<T> dans shared/response/.
  ```

**Issue #2**
- **Titre** : `[SETUP] Configurer PostgreSQL local avec Docker Compose + pgvector`
- **Labels** : `chore` · `module:infra` · `priority:critical` · `owner:senior`
- **Description** :
  ```
  docker-compose.yml avec pgvector/pgvector:pg16.
  Script init.sql : CREATE EXTENSION IF NOT EXISTS vector.
  Flyway V1__init_extensions.sql.
  Vérifier que Flyway tourne au démarrage.
  ```

**Issue #3**
- **Titre** : `[SETUP] Configurer GlobalExceptionHandler et hiérarchie des exceptions`
- **Labels** : `chore` · `module:shared` · `priority:critical` · `owner:senior`
- **Description** :
  ```
  BaseException (abstract) + 5 sous-classes :
  ResourceNotFoundException (404)
  BusinessRuleException (422)
  ConflictException (409)
  UnauthorizedException (401)
  ForbiddenException (403)
  GlobalExceptionHandler @RestControllerAdvice.
  ```

**Issue #4**
- **Titre** : `[SETUP] Configurer Spring Security skeleton + JWT service`
- **Labels** : `chore` · `module:auth` · `priority:critical` · `owner:senior`
- **Description** :
  ```
  SecurityConfig : routes publiques déclarées, tout le reste protégé.
  JwtService : génération + validation access token (15min) + refresh (7j).
  JwtAuthenticationFilter skeleton.
  ```

**Issue #5**
- **Titre** : `[SETUP] Configurer Swagger / OpenAPI 3.0`
- **Labels** : `chore` · `module:infra` · `priority:high` · `owner:senior`

**Issue #6**
- **Titre** : `[SETUP] Configurer GitHub Actions CI (build + tests + checkstyle)`
- **Labels** : `chore` · `module:ci` · `priority:critical` · `owner:senior`

**Issue #7**
- **Titre** : `[SETUP] Configurer pom.xml avec toutes les dépendances`
- **Labels** : `chore` · `module:infra` · `priority:critical` · `owner:senior`
- **Description** :
  ```
  Spring Boot Web, Security, OAuth2, JPA, Validation, WebSocket, Cache
  PostgreSQL driver, Flyway, MapStruct, JJWT, Firebase Admin
  AWS SDK S3, SpringDoc OpenAPI, Testcontainers, Lombok, Actuator
  JaCoCo plugin (seuil 70%), Checkstyle plugin
  ```

---

### Phase 1 — Auth & Core (Milestone: Phase 1 — Auth & Core)

#### Senior

**Issue #8**
- **Titre** : `[AUTH] Implémenter l'authentification email + mot de passe avec JWT`
- **Labels** : `feat` · `module:auth` · `priority:critical` · `owner:senior`

**Issue #9**
- **Titre** : `[AUTH] Implémenter le refresh token (httpOnly cookie)`
- **Labels** : `feat` · `module:auth` · `priority:critical` · `owner:senior`

**Issue #10**
- **Titre** : `[AUTH] Implémenter OTP SMS via AfrikSMS`
- **Labels** : `feat` · `module:auth` · `priority:high` · `owner:senior`

**Issue #11**
- **Titre** : `[AUTH] Implémenter OAuth2 Google`
- **Labels** : `feat` · `module:auth` · `priority:high` · `owner:senior`

**Issue #12**
- **Titre** : `[AUTH] Implémenter OAuth2 Apple`
- **Labels** : `feat` · `module:auth` · `priority:high` · `owner:senior`

**Issue #13**
- **Titre** : `[USER] CRUD profil utilisateur (CLIENT / SUPPLIER / ADMIN)`
- **Labels** : `feat` · `module:user` · `priority:high` · `owner:senior`

**Issue #14**
- **Titre** : `[USER] Workflow de validation fournisseur par l'admin`
- **Labels** : `feat` · `module:user` · `priority:high` · `owner:senior`

**Issue #15**
- **Titre** : `[INFRA] Configurer le service de stockage images (S3)`
- **Labels** : `feat` · `module:infra` · `priority:high` · `owner:senior`

#### Middle

**Issue #16**
- **Titre** : `[CATEGORY] CRUD catégories (admin uniquement)`
- **Labels** : `feat` · `module:category` · `priority:high` · `owner:middle`

**Issue #17**
- **Titre** : `[PRODUCT] CRUD produits avec images multiples et gestion du stock`
- **Labels** : `feat` · `module:product` · `priority:critical` · `owner:middle`

**Issue #18**
- **Titre** : `[PRODUCT] Endpoint upload image produit vers S3`
- **Labels** : `feat` · `module:product` · `priority:high` · `owner:middle`

**Issue #19**
- **Titre** : `[PRODUCT] Promotions et ventes flash avec countdown`
- **Labels** : `feat` · `module:product` · `priority:medium` · `owner:middle`

**Issue #20**
- **Titre** : `[DB] Migration Flyway V2 — table users`
- **Labels** : `chore` · `module:shared` · `priority:critical` · `owner:middle`

**Issue #21**
- **Titre** : `[DB] Migration Flyway V3 — tables categories et products`
- **Labels** : `chore` · `module:shared` · `priority:critical` · `owner:middle`

#### Junior

**Issue #22**
- **Titre** : `[TEST] Tests unitaires modules auth et user (coverage 80%+)`
- **Labels** : `test` · `module:auth` · `priority:high` · `owner:junior`

---

### Phase 2 — Commerce & Paiement (Milestone: Phase 2 — Commerce & Paiement)

#### Middle

**Issue #23**
- **Titre** : `[ORDER] Module panier multi-vendeur`
- **Labels** : `feat` · `module:order` · `priority:critical` · `owner:middle`

**Issue #24**
- **Titre** : `[ORDER] Workflow de commande avec statuts complets`
- **Labels** : `feat` · `module:order` · `priority:critical` · `owner:middle`
- **Description** :
  ```
  Statuts : pending → accepted → in_progress → delivered → cancelled
  Notifications à chaque changement de statut
  ```

**Issue #25**
- **Titre** : `[PAYMENT] Intégration Fedapay — paiement commandes`
- **Labels** : `feat` · `module:payment` · `priority:critical` · `owner:middle`

**Issue #26**
- **Titre** : `[PAYMENT] Mobile Money MTN et Orange Money`
- **Labels** : `feat` · `module:payment` · `priority:critical` · `owner:middle`

**Issue #27**
- **Titre** : `[PAYMENT] Système de commissions admin (taux paramétrable)`
- **Labels** : `feat` · `module:payment` · `priority:high` · `owner:middle`

**Issue #28**
- **Titre** : `[DB] Migration Flyway V4 — tables orders et payments`
- **Labels** : `chore` · `module:shared` · `priority:critical` · `owner:middle`

#### Junior

**Issue #29**
- **Titre** : `[REVIEW] Module avis et notation produits (1-5 étoiles)`
- **Labels** : `feat` · `module:review` · `priority:high` · `owner:junior`

**Issue #30**
- **Titre** : `[REVIEW] Calcul automatique de la note moyenne fournisseur`
- **Labels** : `feat` · `module:review` · `priority:medium` · `owner:junior`

**Issue #31**
- **Titre** : `[FAVORITE] Module favoris client`
- **Labels** : `feat` · `module:favorite` · `priority:medium` · `owner:junior`

**Issue #32**
- **Titre** : `[TEST] Tests unitaires modules order, payment, review`
- **Labels** : `test` · `module:order` · `priority:high` · `owner:junior`

---

### Phase 3 — Avancé & Temps réel (Milestone: Phase 3 — Avancé & Temps réel)

#### Senior

**Issue #33**
- **Titre** : `[SEARCH] Intégration pgvector — recherche par image (CLIP embeddings)`
- **Labels** : `feat` · `module:search` · `priority:high` · `owner:senior`

**Issue #34**
- **Titre** : `[SEARCH] Endpoint de recherche unifiée texte + vectorielle`
- **Labels** : `feat` · `module:search` · `priority:high` · `owner:senior`

**Issue #35**
- **Titre** : `[GEO] Géolocalisation — produits à proximité`
- **Labels** : `feat` · `module:infra` · `priority:medium` · `owner:senior`

**Issue #36**
- **Titre** : `[DB] Migration Flyway V7 — colonnes embeddings pgvector`
- **Labels** : `chore` · `module:search` · `priority:high` · `owner:senior`

#### Middle

**Issue #37**
- **Titre** : `[MESSAGING] Chat temps réel WebSocket (STOMP) client ↔ fournisseur`
- **Labels** : `feat` · `module:messaging` · `priority:high` · `owner:middle`

**Issue #38**
- **Titre** : `[SUBSCRIPTION] 4 plans d'abonnement fournisseur (0/1999/4999/9999 FCFA)`
- **Labels** : `feat` · `module:subscription` · `priority:critical` · `owner:middle`

**Issue #39**
- **Titre** : `[SUBSCRIPTION] Paiement abonnements via Fedapay`
- **Labels** : `feat` · `module:subscription` · `priority:critical` · `owner:middle`

**Issue #40**
- **Titre** : `[SUBSCRIPTION] Système de parrainage (referral codes)`
- **Labels** : `feat` · `module:subscription` · `priority:medium` · `owner:middle`

**Issue #41**
- **Titre** : `[SUBSCRIPTION] Vouchers et coupons promotionnels`
- **Labels** : `feat` · `module:subscription` · `priority:medium` · `owner:middle`

**Issue #42**
- **Titre** : `[DB] Migration Flyway V5 — tables subscriptions et referrals`
- **Labels** : `chore` · `module:shared` · `priority:high` · `owner:middle`

**Issue #43**
- **Titre** : `[DB] Migration Flyway V6 — tables messaging`
- **Labels** : `chore` · `module:shared` · `priority:high` · `owner:middle`

#### Junior

**Issue #44**
- **Titre** : `[NOTIFICATION] Intégration FCM — notifications push Android (4 canaux)`
- **Labels** : `feat` · `module:notification` · `priority:high` · `owner:junior`

**Issue #45**
- **Titre** : `[NOTIFICATION] Triggers automatiques (nouvelle commande, message, livraison)`
- **Labels** : `feat` · `module:notification` · `priority:high` · `owner:junior`

**Issue #46**
- **Titre** : `[NOTIFICATION] Préférences de notification par utilisateur`
- **Labels** : `feat` · `module:notification` · `priority:medium` · `owner:junior`

---

### Phase 4 — Admin & Analytics (Milestone: Phase 4 — Admin & Analytics)

#### Junior

**Issue #47**
- **Titre** : `[ANALYTICS] Dashboard fournisseur (CA, commandes, notes, top produits)`
- **Labels** : `feat` · `module:analytics` · `priority:high` · `owner:junior`

**Issue #48**
- **Titre** : `[ANALYTICS] Filtres temporels (semaine / mois / trimestre / année)`
- **Labels** : `feat` · `module:analytics` · `priority:medium` · `owner:junior`

**Issue #49**
- **Titre** : `[ANALYTICS] Dashboard admin global`
- **Labels** : `feat` · `module:analytics` · `priority:high` · `owner:junior`

**Issue #50**
- **Titre** : `[ADMIN] Gestion utilisateurs et suspension de comptes`
- **Labels** : `feat` · `module:admin` · `priority:high` · `owner:junior`

**Issue #51**
- **Titre** : `[ADMIN] Gestion financière admin (commissions, moyens de paiement)`
- **Labels** : `feat` · `module:admin` · `priority:high` · `owner:junior`

**Issue #52**
- **Titre** : `[ADMIN] Journal de modération`
- **Labels** : `feat` · `module:admin` · `priority:medium` · `owner:junior`

#### Middle

**Issue #53**
- **Titre** : `[PAYMENT] Campagnes promotionnelles admin`
- **Labels** : `feat` · `module:payment` · `priority:medium` · `owner:middle`

---

### Phase 5 — Tests & Déploiement (Milestone: Phase 5 — Tests & Déploiement)

**Issue #54**
- **Titre** : `[TEST] Tests d'intégration avec Testcontainers PostgreSQL`
- **Labels** : `test` · `module:shared` · `priority:high` · `owner:senior`

**Issue #55**
- **Titre** : `[TEST] Tests API avec MockMvc — controllers critiques`
- **Labels** : `test` · `module:shared` · `priority:high` · `owner:middle`

**Issue #56**
- **Titre** : `[TEST] Compléter coverage à 80%+ sur tous les services`
- **Labels** : `test` · `module:shared` · `priority:high` · `owner:junior`

**Issue #57**
- **Titre** : `[DEPLOY] Configuration VPS Linux — déploiement Spring Boot`
- **Labels** : `chore` · `module:infra` · `priority:critical` · `owner:senior`

**Issue #58**
- **Titre** : `[DEPLOY] Configurer monitoring (Actuator + Logback structuré)`
- **Labels** : `chore` · `module:infra` · `priority:medium` · `owner:senior`

---

## 7. Configurer les GitHub Secrets (CI/CD)

Aller sur : **GitHub → Settings → Secrets and variables → Actions → New repository secret**

Créer ces secrets :

| Secret | Description | Qui fournit |
|--------|-------------|-------------|
| `JWT_SECRET_TEST` | Secret JWT pour les tests CI (peut être n'importe quelle valeur longue) | Senior |
| `DB_PASSWORD_TEST` | Mot de passe DB pour les tests CI | Senior |
| `STAGING_VPS_HOST` | IP ou domaine du VPS staging | DevOps |
| `STAGING_VPS_USER` | Utilisateur SSH du VPS | DevOps |
| `STAGING_VPS_SSH_KEY` | Clé privée SSH pour le déploiement | DevOps |
| `PROD_VPS_HOST` | IP ou domaine du VPS production | DevOps (plus tard) |
| `PROD_VPS_USER` | Utilisateur SSH VPS prod | DevOps (plus tard) |
| `PROD_VPS_SSH_KEY` | Clé privée SSH prod | DevOps (plus tard) |

> ⚠️ Les secrets VPS sont gérés par le DevOps. Le Senior fournit uniquement `JWT_SECRET_TEST`.

---

## 8. Inviter les collaborateurs

Aller sur : **GitHub → Settings → Collaborators → Add people**

| Collaborateur | Rôle GitHub | Niveau d'accès |
|--------------|-------------|----------------|
| Middle dev | Collaborator | Write |
| Junior dev | Collaborator | Write |
| Chef de projet | Collaborator | Read (pour voir le Kanban) |
| DevOps | Collaborator | Write (pour configurer CI/CD) |

---

## 9. Pusher le code de base

Une fois les étapes 1 à 8 terminées :

```bash
# Sur la branche develop
git checkout develop

# Ajouter tous les fichiers de base
git add .

# Committer
git commit -m "chore(init): add project base structure, docker-compose, CI config and documentation"

# Pusher
git push origin develop
```

Envoyer un message à l'équipe :
> ✅ Le repo est configuré. Vous pouvez cloner et suivre le SETUP_GUIDE.md.  
> Lien du repo : github.com/ijeaf/ijeaf-backend  
> Kanban : github.com/ijeaf/ijeaf-backend/projects/1

---

## 10. Vérification finale

Cocher chaque point avant de prévenir l'équipe :

**Repository**
- [ ] Repo `ijeaf-backend` créé et privé
- [ ] Branches `main`, `develop`, `staging` existent
- [ ] Branch protection rules configurées sur les 3 branches
- [ ] `.gitignore` commité (`.env` ignoré)

**Labels & Organisation**
- [ ] Tous les labels créés (type, module, priorité, owner)
- [ ] 6 Milestones créées avec les bonnes dates
- [ ] 58 issues créées, assignées et liées aux milestones

**GitHub Project**
- [ ] Project "IJEAF Backend — Sprint Board" créé
- [ ] 5 colonnes configurées (Backlog → Done)
- [ ] Automatisations activées (issue opened → Backlog, PR merged → Done)
- [ ] Vues additionnelles créées (Par développeur, Par module, Roadmap)
- [ ] Toutes les issues visibles dans le Kanban (colonne Backlog)

**CI/CD**
- [ ] Fichier `.github/workflows/ci.yml` présent et poussé
- [ ] Secrets GitHub configurés (au minimum `JWT_SECRET_TEST`)
- [ ] Premier push sur develop → CI s'est déclenché sans erreur

**Collaboration**
- [ ] Middle et Junior invités comme collaborateurs
- [ ] Chef de projet invité en lecture
- [ ] `SETUP_GUIDE.md` et `CONTRIBUTING.md` poussés et accessibles

---

*Une fois cette checklist complète → l'équipe peut commencer. Durée totale estimée : 45 min.*
