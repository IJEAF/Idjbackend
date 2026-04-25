# 🚀 IJEAF Backend — Guide de Setup Complet A-Z

> **À qui s'adresse ce guide ?**  
> À tous les membres de l'équipe backend (Senior, Middle, Junior).  
> Suivre chaque étape dans l'ordre. Ne rien sauter.

---

## Table des matières

1. [Prérequis à installer](#étape-1--prérequis-à-installer)
2. [Cloner le projet](#étape-2--cloner-le-projet)
3. [Configurer les variables d'environnement](#étape-3--configurer-les-variables-denvironnement)
4. [Démarrer la base de données](#étape-4--démarrer-la-base-de-données)
5. [Ouvrir dans l'IDE](#étape-5--ouvrir-dans-lide)
6. [Lancer l'application](#étape-6--lancer-lapplication)
7. [Vérifier que tout fonctionne](#étape-7--vérifier-que-tout-fonctionne)
8. [Configurer Git correctement](#étape-8--configurer-git-correctement)
9. [Workflow quotidien](#étape-9--workflow-quotidien)
10. [GitHub Project — Kanban](#étape-10--github-project--kanban)

---

## Étape 1 — Prérequis à installer

Installer ces outils **dans cet ordre** avant toute chose.

### 1.1 Java 17 (JDK Temurin)

```bash
# Vérifier si Java est déjà installé
java -version
# Résultat attendu : openjdk version "17.x.x"
```

Si Java n'est pas installé ou pas en version 17 :

**Windows / macOS / Linux** → Télécharger sur :  
https://adoptium.net/temurin/releases/?version=17

Après installation, vérifier :
```bash
java -version
javac -version
# Les deux doivent afficher 17.x.x
```

### 1.2 Maven

```bash
# Vérifier si Maven est installé
mvn -version
# Résultat attendu : Apache Maven 3.9.x
```

Si Maven n'est pas installé :

**macOS** :
```bash
brew install maven
```

**Ubuntu/Debian** :
```bash
sudo apt-get install maven
```

**Windows** → Télécharger sur https://maven.apache.org/download.cgi  
Ajouter `MAVEN_HOME/bin` dans la variable d'environnement `PATH`.

### 1.3 Docker Desktop

Télécharger et installer Docker Desktop :  
https://www.docker.com/products/docker-desktop/

Après installation, **démarrer Docker Desktop** puis vérifier :
```bash
docker -version
docker compose version
# Docker version 24.x.x ou plus
```

> ⚠️ **Docker doit être démarré** à chaque fois que tu travailles sur le projet.

### 1.4 Git

```bash
git --version
# Résultat attendu : git version 2.40.x ou plus
```

Si Git n'est pas installé :  
https://git-scm.com/downloads

### 1.5 IntelliJ IDEA (recommandé)

Télécharger IntelliJ IDEA Community (gratuit) ou Ultimate :  
https://www.jetbrains.com/idea/download/

> VS Code avec l'extension Java fonctionne aussi, mais IntelliJ est fortement recommandé pour Spring Boot.

---

## Étape 2 — Cloner le projet

### 2.1 Configurer ton identité Git (une seule fois)

```bash
git config --global user.name "Ton Prénom Nom"
git config --global user.email "ton.email@example.com"
git config --global core.autocrlf input  # Linux/macOS
# ou
git config --global core.autocrlf true   # Windows uniquement
```

Vérifier :
```bash
git config --global --list
```

### 2.2 Configurer l'accès GitHub (SSH recommandé)

```bash
# Générer une clé SSH si tu n'en as pas
ssh-keygen -t ed25519 -C "ton.email@example.com"
# Appuyer sur Entrée pour tout accepter (passphrase optionnelle)

# Afficher la clé publique à copier
cat ~/.ssh/id_ed25519.pub
```

Aller sur GitHub → **Settings → SSH and GPG keys → New SSH key**  
Coller le contenu affiché par la commande précédente.

Tester la connexion :
```bash
ssh -T git@github.com
# Résultat attendu : Hi ton-username! You've successfully authenticated...
```

### 2.3 Cloner le repository

```bash
# Se placer dans le dossier où tu veux mettre le projet
cd ~/Documents/projets    # ou ton dossier préféré

# Cloner via SSH (recommandé)
git clone git@github.com:ijeaf/ijeaf-backend.git

# Entrer dans le dossier
cd ijeaf-backend

# Vérifier les branches disponibles
git branch -a
```

Tu dois voir :
```
* main
  remotes/origin/main
  remotes/origin/develop
```

### 2.4 Basculer sur develop

```bash
# Toujours travailler depuis develop, jamais depuis main
git checkout develop
git pull origin develop

# Vérifier que tu es bien sur develop
git branch
# Résultat : * develop
```

---

## Étape 3 — Configurer les variables d'environnement

### 3.1 Créer le fichier .env

```bash
# Copier le fichier exemple
cp .env.example .env
```

> ⚠️ **Ne jamais committer le fichier `.env`** — il est dans `.gitignore`.

### 3.2 Remplir le fichier .env

Ouvrir `.env` avec ton éditeur et remplir les valeurs.  
Pour le développement local, utiliser ces valeurs minimales :

```env
# Base de données (correspond au docker-compose.yml)
DB_URL=jdbc:postgresql://localhost:5432/ijeaf_dev
DB_USERNAME=ijeaf
DB_PASSWORD=ijeaf_dev_password

# JWT — générer un secret fort
JWT_SECRET=dev_secret_change_me_in_production_minimum_256_bits_long
JWT_ACCESS_EXPIRATION=900000
JWT_REFRESH_EXPIRATION=604800000

# Les autres variables (FCM, Fedapay, S3...) peuvent rester vides en local.
# Spring Boot utilisera des mocks en profil dev.
SPRING_PROFILES_ACTIVE=dev
```

> 📌 **Le Senior partagera les vraies valeurs de dev** via un canal sécurisé (pas par email, pas dans Slack public).

---

## Étape 4 — Démarrer la base de données

### 4.1 Lancer PostgreSQL + pgvector avec Docker

```bash
# S'assurer que Docker Desktop est démarré, puis :
docker compose up -d

# Vérifier que les containers sont bien lancés
docker compose ps
```

Tu dois voir :
```
NAME                STATUS
ijeaf-postgres      running
```

### 4.2 Vérifier la connexion à la base de données

```bash
# Se connecter à PostgreSQL pour vérifier
docker exec -it ijeaf-postgres psql -U ijeaf -d ijeaf_dev

# Dans le prompt PostgreSQL, vérifier que pgvector est installé
\dx
# Tu dois voir "vector" dans la liste des extensions

# Quitter
\q
```

### 4.3 Commandes Docker utiles

```bash
# Démarrer les containers
docker compose up -d

# Arrêter les containers (sans supprimer les données)
docker compose stop

# Voir les logs PostgreSQL
docker compose logs postgres

# Réinitialiser complètement la DB (supprime toutes les données)
docker compose down -v
docker compose up -d
```

> 💡 Les données PostgreSQL sont persistées dans un volume Docker.  
> `docker compose stop` ne supprime pas tes données.  
> `docker compose down -v` supprime tout — à utiliser si tu veux repartir de zéro.

---

## Étape 5 — Ouvrir dans l'IDE

### IntelliJ IDEA

1. Ouvrir IntelliJ IDEA
2. **File → Open** → Sélectionner le dossier `ijeaf-backend`
3. Attendre que l'indexation et le chargement Maven soient terminés (barre de progression en bas)
4. Aller dans **File → Project Structure → SDK** → Sélectionner Java 17
5. IntelliJ va télécharger toutes les dépendances Maven automatiquement

### Configuration du profil Spring dans IntelliJ

1. En haut à droite, cliquer sur la configuration de lancement → **Edit Configurations**
2. Sélectionner la configuration Spring Boot existante (ou en créer une)
3. Dans **Active profiles** : taper `dev`
4. Dans **Environment variables** : pointer vers ton fichier `.env`  
   (ou copier les valeurs directement dans le champ Environment variables)

---

## Étape 6 — Lancer l'application

### 6.1 Via la ligne de commande

```bash
# S'assurer que Docker est démarré et PostgreSQL tourne
docker compose ps

# Lancer Spring Boot en profil dev
mvn spring-boot:run -Dspring-boot.run.profiles=dev

# Ou avec le fichier .env chargé automatiquement (si spring-dotenv est configuré)
mvn spring-boot:run
```

### 6.2 Via IntelliJ

Cliquer sur le bouton ▶️ vert à côté de `IjeafApplication.java`

### 6.3 Ce que tu dois voir au démarrage

```
  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::                (v3.x.x)

...
Flyway: Successfully applied X migrations to schema "public"
...
Started IjeafApplication in X.XXX seconds
```

> ✅ Si tu vois `Started IjeafApplication` sans erreur rouge → l'application fonctionne.  
> ❌ Si tu vois une erreur de connexion DB → vérifier que Docker tourne bien.

---

## Étape 7 — Vérifier que tout fonctionne

### 7.1 Health check

```bash
curl http://localhost:8080/actuator/health
# Résultat attendu :
# {"status":"UP"}
```

### 7.2 Swagger UI

Ouvrir dans le navigateur :  
http://localhost:8080/swagger-ui.html

Tu dois voir la documentation API interactive.

### 7.3 Lancer les tests

```bash
# Lancer tous les tests unitaires
mvn test

# Résultat attendu :
# Tests run: XX, Failures: 0, Errors: 0, Skipped: 0
# BUILD SUCCESS
```

### 7.4 Vérifier Flyway (migrations appliquées)

```bash
docker exec -it ijeaf-postgres psql -U ijeaf -d ijeaf_dev -c "\dt"
# Tu dois voir les tables créées par Flyway
# (dont flyway_schema_history)
```

---

## Étape 8 — Configurer Git correctement

### 8.1 Vérifier les branches distantes

```bash
git fetch --all
git branch -a
# Tu dois voir develop, main, et les branches feature des autres
```

### 8.2 Convention de commits — configurer un alias utile

```bash
# Alias pour voir un log propre
git config --global alias.lg "log --oneline --graph --decorate --all"

# Utilisation :
git lg
```

### 8.3 Créer ta première branche de travail

```bash
# Toujours partir de develop à jour
git checkout develop
git pull origin develop

# Créer ta branche pour ta première tâche
# Format : type/module-description
git checkout -b feature/auth-jwt-access-token    # exemple Senior
git checkout -b feature/product-crud             # exemple Middle
git checkout -b feature/review-model             # exemple Junior
```

### 8.4 Convention de commits à respecter

```bash
# Format : type(scope): description en minuscules
git commit -m "feat(auth): implement JWT access token generation"
git commit -m "feat(product): add product creation endpoint"
git commit -m "test(review): add unit tests for ReviewServiceImpl"
git commit -m "chore(config): add Flyway V2 migration for users table"
git commit -m "fix(order): correct stock decrement on order confirmation"
git commit -m "docs(api): update Swagger annotations on ProductController"
```

Types autorisés : `feat` · `fix` · `test` · `docs` · `refactor` · `chore` · `perf`

### 8.5 Pousser sa branche et ouvrir une PR

```bash
# Pousser la branche
git push origin feature/auth-jwt-access-token

# Aller sur GitHub → l'interface te proposera automatiquement d'ouvrir une PR
# Titre de la PR : [AUTH] Implement JWT access token
# Description : remplir le template automatique
# Lier l'issue : "Closes #NUM_ISSUE"
# Assigner un reviewer
```

---

## Étape 9 — Workflow quotidien

Chaque jour de travail, suivre ce cycle :

```bash
# 1. Mettre à jour develop au démarrage de la journée
git checkout develop
git pull origin develop

# 2. Rebaser sa branche en cours sur develop (évite les conflits)
git checkout feature/ma-branche
git rebase origin/develop

# 3. Coder, tester, committer
mvn test                           # vérifier que les tests passent
git add .
git commit -m "feat(module): description"

# 4. Pousser
git push origin feature/ma-branche

# 5. En fin de journée / quand la feature est prête → ouvrir la PR sur GitHub
```

### Règles absolues

| ✅ Toujours | ❌ Jamais |
|------------|---------|
| Partir de `develop` à jour | Push direct sur `main` |
| Créer une branche par tâche | Push direct sur `develop` |
| Lier chaque branche à une issue | Committer sur la branche d'un collègue |
| Inclure les tests dans la PR | Merger sans review |
| Faire `rebase` avant de pusher | Modifier une migration Flyway existante |

---

## Étape 10 — GitHub Project — Kanban

### 10.1 Accéder au tableau

Aller sur : **github.com/ijeaf/ijeaf-backend → Projects → IJEAF Backend**

### 10.2 Structure du Kanban

| Colonne | Signification | Action requise |
|---------|--------------|---------------|
| 📋 **Backlog** | Tâches futures non démarrées | Rien à faire |
| 🎯 **Sprint actuel** | Tâches de la semaine en cours | Te les assigner |
| 🔄 **In Progress** | En cours de développement | Déplacer quand tu commences |
| 👀 **In Review** | PR ouverte en attente de review | Déplacer quand tu ouvres la PR |
| ✅ **Done** | Mergée sur develop | Automatique via GitHub Actions |

### 10.3 Règles du Kanban

1. **Chaque tâche = une issue GitHub** avec les bons labels
2. **Déplacer soi-même** sa carte dans le bon statut — ne pas attendre
3. **Maximum 2 cartes "In Progress"** par développeur en même temps
4. **Une carte bloquée** → la tagger `blocked` et notifier le Senior
5. **Le chef de projet voit en temps réel** l'état de chaque tâche

### 10.4 Labels à utiliser sur chaque issue

Toujours mettre **4 labels** sur chaque issue que tu crées ou prends :

```
type:     feat / bug / test / docs / chore
module:   auth / product / order / payment / review / ...
priority: priority:high / priority:medium / priority:low
owner:    owner:senior / owner:middle / owner:junior
```

### 10.5 Cycle de vie d'une issue

```
Issue créée (Backlog)
    ↓ tu te l'assignes + crées la branche
In Progress
    ↓ tu ouvres la PR sur GitHub
In Review
    ↓ reviewer approuve + CI vert → merge
Done  ✅
```

---

## Récapitulatif rapide — Checklist de démarrage

Cocher chaque étape une fois faite :

- [ ] Java 17 installé (`java -version`)
- [ ] Maven installé (`mvn -version`)
- [ ] Docker Desktop installé et démarré
- [ ] Git configuré avec ton nom et email
- [ ] Clé SSH ajoutée sur GitHub
- [ ] Repo cloné en SSH
- [ ] Basculé sur la branche `develop`
- [ ] Fichier `.env` créé depuis `.env.example` et rempli
- [ ] `docker compose up -d` lancé sans erreur
- [ ] Application démarrée (`mvn spring-boot:run`)
- [ ] Health check OK (`curl http://localhost:8080/actuator/health`)
- [ ] Swagger UI accessible sur `http://localhost:8080/swagger-ui.html`
- [ ] Tests passent (`mvn test`)
- [ ] Accès au GitHub Project (Kanban) vérifié
- [ ] Première branche de travail créée depuis `develop`

---

## Problèmes fréquents & solutions

### "Connection refused" au démarrage

```bash
# Docker n'est pas démarré ou PostgreSQL ne tourne pas
docker compose ps
docker compose up -d
```

### "Port 5432 already in use"

```bash
# Un autre PostgreSQL tourne déjà sur ta machine
# Option 1 : arrêter le service local
sudo service postgresql stop  # Linux
brew services stop postgresql # macOS

# Option 2 : changer le port dans docker-compose.yml
ports:
  - "5433:5432"  # utiliser le port 5433 en local
# Et mettre à jour DB_URL dans .env :
DB_URL=jdbc:postgresql://localhost:5433/ijeaf_dev
```

### "BUILD FAILURE" lors de mvn test

```bash
# Voir le détail de l'erreur
mvn test -B 2>&1 | grep -A 5 "ERROR\|FAILURE"

# Si c'est une erreur de DB → vérifier que Docker tourne
# Si c'est une erreur de compilation → voir le message exact et contacter le Senior
```

### Conflits Git après rebase

```bash
# Voir les fichiers en conflit
git status

# Résoudre chaque conflit dans l'IDE (IntelliJ a un outil de merge visuel)
# Puis :
git add .
git rebase --continue

# Si tu veux annuler le rebase
git rebase --abort
```

---

*Problème non listé ici ? Ouvrir une issue avec le label `question` sur GitHub.*  
*Ne jamais hésiter à demander — mieux vaut poser la question que de bloquer en silence.*
