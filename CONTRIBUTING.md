# Guide de contribution — IJEAF Backend

> Ce fichier est **obligatoire à lire** avant d'écrire la moindre ligne de code.  
> Il définit les règles de travail pour les 3 développeurs backend du projet.

---

## Table des matières

1. [Philosophie](#1-philosophie)
2. [Branches Git](#2-branches-git)
3. [Conventions de commits](#3-conventions-de-commits)
4. [Conventions de code Java](#4-conventions-de-code-java)
5. [Architecture — règles absolues](#5-architecture--règles-absolues)
6. [Nommage](#6-nommage)
7. [Format de réponse API](#7-format-de-réponse-api)
8. [Gestion des erreurs](#8-gestion-des-erreurs)
9. [Tests — obligatoires](#9-tests--obligatoires)
10. [Pull Request process](#10-pull-request-process)
11. [GitHub Issues & Project](#11-github-issues--project)
12. [Ce qu'il ne faut JAMAIS faire](#12-ce-quil-ne-faut-jamais-faire)

---

## 1. Philosophie

- **Chaque module est une île.** Aucune dépendance directe entre modules — on communique via des services exposés, jamais en appelant directement un repository d'un autre module.
- **Les controllers ne pensent pas.** Toute logique métier est dans les services.
- **Les entités JPA ne voyagent pas.** On n'expose jamais une entité dans une réponse HTTP — on utilise des DTOs.
- **Un test par comportement.** Les tests vérifient ce que le code fait, pas comment il le fait.

---

## 2. Branches Git

### Stratégie de branches

```
main        ← production uniquement. Jamais de push direct. Merge depuis develop via PR.
develop     ← intégration. C'est ici qu'on merge nos features. CI automatique.
feature/*   ← développement d'une fonctionnalité
fix/*       ← correction d'un bug
test/*      ← ajout de tests sans changement fonctionnel
docs/*      ← mise à jour de documentation uniquement
chore/*     ← tâches techniques (config, dépendances, CI)
```

### Règles de nommage des branches

Format : `type/module-description-courte`

```bash
# Exemples corrects
feature/auth-jwt-refresh-token
feature/product-image-upload
feature/order-status-workflow
fix/user-email-validation
test/product-service-unit
docs/api-endpoints-update
chore/flyway-v3-migration

# Exemples incorrects
feature/ma-feature        # trop vague
fix/bug                   # pas descriptif
Feature/Auth              # majuscule interdite
```

### Commandes de base

```bash
# Toujours synchroniser develop avant de créer une branche
git checkout develop
git pull origin develop
git checkout -b feature/mon-module-ma-feature

# Pousser la branche
git push origin feature/mon-module-ma-feature

# Mettre à jour sa branche depuis develop (évite les conflits)
git fetch origin
git rebase origin/develop
```

---

## 3. Conventions de commits

On suit le standard **Conventional Commits** : `type(scope): message`

### Types autorisés

| Type | Usage |
|------|-------|
| `feat` | Nouvelle fonctionnalité |
| `fix` | Correction de bug |
| `test` | Ajout ou modification de tests |
| `docs` | Documentation uniquement |
| `refactor` | Refactoring sans changement de comportement |
| `chore` | Tâche technique (dépendances, config, migration) |
| `perf` | Amélioration de performance |

### Scope = nom du module

`auth` · `user` · `product` · `order` · `payment` · `subscription` · `messaging` · `review` · `favorite` · `notification` · `analytics` · `admin` · `search` · `shared` · `config` · `ci`

### Format du message

```
type(scope): description courte en minuscules, présent, sans point final

Corps optionnel (après une ligne vide) :
Expliquer le POURQUOI si la décision n'est pas évidente.
Maximum 72 caractères par ligne.

Closes #42
```

### Exemples corrects

```bash
git commit -m "feat(auth): implement JWT access token with 15min expiration"
git commit -m "feat(auth): add refresh token endpoint with httpOnly cookie"
git commit -m "fix(product): correct stock decrement on order confirmation"
git commit -m "test(user): add unit tests for UserServiceImpl.suspendUser"
git commit -m "chore(config): add Flyway V3 migration for orders table"
git commit -m "docs(api): update Swagger description for /api/v1/products"
```

### Exemples incorrects

```bash
git commit -m "update"              # pas de type, pas de scope, trop vague
git commit -m "Fix bug"             # majuscule, pas de scope
git commit -m "feat: added things"  # passé composé, pas de scope
git commit -m "WIP"                 # ne jamais committer un WIP sur develop
```

---

## 4. Conventions de code Java

### Annotations de validation sur tous les DTOs de requête

```java
// Exemple CreateProductRequest
public record CreateProductRequest(
    @NotBlank(message = "Le titre est obligatoire")
    @Size(min = 3, max = 200)
    String title,

    @NotBlank
    @Size(max = 2000)
    String description,

    @NotNull
    @Positive(message = "Le prix doit être positif")
    BigDecimal price,

    @NotNull
    @Min(0)
    Integer stock,

    @NotNull
    Long categoryId
) {}
```

### Javadoc obligatoire sur toutes les méthodes publiques des services

```java
/**
 * Crée un nouveau produit pour le fournisseur authentifié.
 *
 * @param request  les données du produit à créer
 * @param supplierId  l'identifiant du fournisseur propriétaire
 * @return le produit créé sous forme de DTO
 * @throws ResourceNotFoundException si la catégorie n'existe pas
 * @throws ForbiddenException si le fournisseur n'a pas de plan actif
 */
ProductResponse createProduct(CreateProductRequest request, Long supplierId);
```

### Logger SLF4J — un par classe

```java
// Déclaration (toujours private static final)
private static final Logger log = LoggerFactory.getLogger(ProductServiceImpl.class);

// Usage
log.info("Product created: id={}, supplierId={}", product.getId(), supplierId);
log.warn("Stock low for product id={}, remaining={}", productId, stock);
log.error("Payment callback failed for orderId={}", orderId, e);

// INTERDIT
System.out.println("..."); // jamais
e.printStackTrace();        // jamais
```

### Transactions — uniquement dans les services

```java
@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

    // Lecture : readOnly=true pour optimisation Hibernate
    @Transactional(readOnly = true)
    public OrderResponse findById(Long id) { ... }

    // Écriture : @Transactional sans readOnly
    @Transactional
    public OrderResponse createOrder(CreateOrderRequest request) { ... }
}
```

### Pas de FetchType.EAGER sans justification

```java
// Par défaut — toujours LAZY
@OneToMany(mappedBy = "product", fetch = FetchType.LAZY)
private List<ProductImage> images;

// Si besoin de charger systématiquement — justifier en commentaire
@ManyToOne(fetch = FetchType.EAGER) // Toujours chargé : utilisé dans 100% des appels
private Category category;
```

---

## 5. Architecture — règles absolues

### Structure d'un module

```
modules/{module}/
├── controller/     # @RestController — délègue au service, zero logique
├── service/        # Interface + Impl — toute la logique métier ici
├── repository/     # JpaRepository — requêtes uniquement
├── domain/         # @Entity JPA — ne sort JAMAIS du repository
├── dto/            # Records ou classes simples — entrée/sortie API
├── mapper/         # @Mapper MapStruct — entité ↔ DTO
└── exception/      # Exceptions spécifiques au module (optionnel)
```

### Règles de dépendance entre modules

```
✅ Autorisé
ProductService      → (inject) CategoryService    # via l'interface
NotificationService → (inject) OrderService       # via l'interface

❌ Interdit
ProductServiceImpl  → (inject) CategoryRepository # jamais le repo d'un autre module
OrderController     → (inject) UserRepository     # jamais
```

### Controller — délégation pure

```java
@RestController
@RequestMapping("/api/v1/products")
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<ProductResponse>> getById(@PathVariable Long id) {
        // Un seul appel au service, rien d'autre
        return ResponseEntity.ok(ApiResponse.success(productService.findById(id)));
    }

    @PostMapping
    @PreAuthorize("hasRole('SUPPLIER')")
    public ResponseEntity<ApiResponse<ProductResponse>> create(
            @Valid @RequestBody CreateProductRequest request,
            @AuthenticationPrincipal UserDetails userDetails) {
        Long supplierId = ((CustomUserDetails) userDetails).getId();
        ProductResponse response = productService.createProduct(request, supplierId);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(response));
    }
}
```

---

## 6. Nommage

### Classes Java

| Élément | Convention | Exemple |
|---------|-----------|---------|
| Entités JPA | PascalCase | `User`, `Product`, `Order` |
| DTOs requête | `{Nom}Request` | `CreateProductRequest` |
| DTOs réponse | `{Nom}Response` | `ProductResponse` |
| Interface service | `{Nom}Service` | `ProductService` |
| Implémentation | `{Nom}ServiceImpl` | `ProductServiceImpl` |
| Repository | `{Nom}Repository` | `ProductRepository` |
| Mapper | `{Nom}Mapper` | `ProductMapper` |
| Constantes | UPPER_SNAKE_CASE | `MAX_STOCK_QUANTITY` |

### Endpoints REST

```
GET    /api/v1/products              # Liste paginée
GET    /api/v1/products/{id}         # Détail
POST   /api/v1/products              # Création
PUT    /api/v1/products/{id}         # Mise à jour complète
PATCH  /api/v1/products/{id}         # Mise à jour partielle
DELETE /api/v1/products/{id}         # Suppression

GET    /api/v1/products/{id}/reviews # Ressources imbriquées
POST   /api/v1/orders/{id}/cancel    # Action exceptionnelle avec verbe
```

### Base de données

```sql
-- Tables : snake_case, pluriel
CREATE TABLE users (...);
CREATE TABLE order_items (...);
CREATE TABLE product_images (...);

-- Colonnes : snake_case
created_at, updated_at, is_active, supplier_id

-- Index : idx_{table}_{colonne}
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_users_email ON users(email);

-- Contraintes unique : uk_{table}_{colonne}
ALTER TABLE users ADD CONSTRAINT uk_users_email UNIQUE (email);

-- Clés étrangères : fk_{table}_{ref}
ALTER TABLE products ADD CONSTRAINT fk_products_supplier
  FOREIGN KEY (supplier_id) REFERENCES users(id);
```

### Migrations Flyway

```
V1__init_extensions.sql
V2__create_users_table.sql
V3__create_categories_products.sql
V4__create_orders.sql
V5__create_subscriptions.sql
V6__create_messaging.sql
V7__create_search_vectors.sql

# Règle absolue : jamais modifier une migration existante.
# Si correction nécessaire → créer une nouvelle migration Vn+1.
```

---

## 7. Format de réponse API

**Toutes** les réponses utilisent `ApiResponse<T>` défini dans `shared/response/`.

### Succès

```json
{
  "success": true,
  "message": "Produit créé avec succès",
  "data": {
    "id": 42,
    "title": "Tissu wax premium"
  },
  "timestamp": "2026-04-23T10:00:00Z"
}
```

### Erreur

```json
{
  "success": false,
  "message": "Ressource introuvable",
  "errorCode": "PRODUCT_NOT_FOUND",
  "details": ["Le produit avec l'ID 99 n'existe pas."],
  "timestamp": "2026-04-23T10:00:00Z"
}
```

### Règles

- Codes d'erreur en `UPPER_SNAKE_CASE` : `USER_NOT_FOUND`, `EMAIL_ALREADY_EXISTS`, `INSUFFICIENT_STOCK`
- Messages en français pour les erreurs métier visibles par l'utilisateur
- Ne jamais exposer de stack trace dans la réponse
- Listes paginées : envelopper dans `ApiResponse<Page<T>>`

---

## 8. Gestion des erreurs

### Hiérarchie des exceptions

```java
BaseException (abstract, RuntimeException)
├── ResourceNotFoundException  → HTTP 404
├── BusinessRuleException      → HTTP 422
├── ConflictException          → HTTP 409
├── UnauthorizedException      → HTTP 401
└── ForbiddenException         → HTTP 403
```

### Usage

```java
// Dans un service
public ProductResponse findById(Long id) {
    return productRepository.findById(id)
        .map(productMapper::toResponse)
        .orElseThrow(() -> new ResourceNotFoundException("PRODUCT_NOT_FOUND",
            "Le produit avec l'ID " + id + " n'existe pas."));
}

// Règle métier
if (supplier.getSubscription().isExpired()) {
    throw new BusinessRuleException("SUBSCRIPTION_EXPIRED",
        "Votre abonnement a expiré. Veuillez le renouveler pour publier des produits.");
}
```

### Ce que gère GlobalExceptionHandler

- `ResourceNotFoundException` → 404
- `BusinessRuleException` → 422
- `ConflictException` → 409
- `UnauthorizedException` → 401
- `ForbiddenException` → 403
- `MethodArgumentNotValidException` (@Valid) → 400 avec liste des champs invalides
- `Exception` générique → 500 (log ERROR avec stack trace, réponse sans détails techniques)

---

## 9. Tests — obligatoires

### Toute PR doit inclure les tests de ce qu'elle ajoute ou modifie.

### Tests unitaires (service layer)

```java
@ExtendWith(MockitoExtension.class)
class ProductServiceImplTest {

    @Mock private ProductRepository productRepository;
    @Mock private ProductMapper productMapper;
    @InjectMocks private ProductServiceImpl productService;

    @Test
    void shouldReturnProductWhenExists() {
        // Given
        Product product = new Product();
        product.setId(1L);
        given(productRepository.findById(1L)).willReturn(Optional.of(product));
        given(productMapper.toResponse(product)).willReturn(new ProductResponse(1L, "Test", ...));

        // When
        ProductResponse result = productService.findById(1L);

        // Then
        assertThat(result.id()).isEqualTo(1L);
    }

    @Test
    void shouldThrowResourceNotFoundWhenProductDoesNotExist() {
        given(productRepository.findById(99L)).willReturn(Optional.empty());

        assertThatThrownBy(() -> productService.findById(99L))
            .isInstanceOf(ResourceNotFoundException.class)
            .hasMessageContaining("PRODUCT_NOT_FOUND");
    }
}
```

### Nommage des tests

```
should{Comportement}When{Condition}

shouldReturnProductWhenExists
shouldThrowResourceNotFoundWhenProductDoesNotExist
shouldCalculateAverageRatingWhenReviewsExist
shouldDecrementStockWhenOrderConfirmed
```

### Coverage minimum

- Services : **80%** minimum (vérifié par JaCoCo dans le CI)
- Controllers : tester avec MockMvc les cas nominaux et les cas d'erreur
- Pas de test sur les mappers MapStruct (générés automatiquement)

---

## 10. Pull Request process

### Avant d'ouvrir une PR

```bash
# S'assurer que develop est intégré
git fetch origin
git rebase origin/develop

# Vérifier que les tests passent en local
mvn clean test

# Vérifier le build
mvn clean package -DskipTests
```

### Titre de la PR

```
[MODULE] Description courte en français

Exemples :
[AUTH] Implement JWT access token and refresh token
[PRODUCT] Add product creation with image upload
[ORDER] Add order status workflow and notifications
[REVIEW] Add product review and rating system
```

### Description (template automatique)

Le template `.github/PULL_REQUEST_TEMPLATE.md` sera pré-rempli. À compléter :

- **Quoi** : ce que fait cette PR
- **Pourquoi** : contexte / issue liée (`Closes #42`)
- **Comment tester** : étapes pour vérifier manuellement
- **Checklist** : tests inclus, Javadoc, Flyway si modif DB

### Reviews

| Auteur PR | Reviewer requis |
|-----------|-----------------|
| Junior | Middle ou Senior |
| Middle | Senior |
| Senior | Middle (auto-approuvé si CI vert pour les features isolées) |

Les modules `auth`, `shared/security`, `config` → **toujours reviewés par le Senior**.

### Merge

- **Squash and merge** sur `develop` (un commit propre par feature)
- Le titre du commit de merge = titre de la PR
- Supprimer la branche après merge

---

## 11. GitHub Issues & Project

### Créer une issue avant de coder

Chaque tâche doit avoir une issue GitHub avant de créer une branche.

### Labels à utiliser

**Type :**
`feat` · `bug` · `test` · `docs` · `chore` · `question`

**Module :**
`auth` · `user` · `product` · `order` · `payment` · `subscription` · `messaging` · `review` · `favorite` · `notification` · `analytics` · `admin` · `search` · `shared` · `infra` · `ci`

**Priorité :**
`priority:critical` · `priority:high` · `priority:medium` · `priority:low`

**Owner :**
`owner:senior` · `owner:middle` · `owner:junior`

### Colonnes du GitHub Project

```
📋 Backlog        ← toutes les issues futures
🎯 Sprint actuel  ← issues de la semaine en cours
🔄 In Progress    ← en cours de développement (assignée + branche créée)
👀 In Review      ← PR ouverte, en attente de review
✅ Done           ← mergée sur develop
```

### Règle : déplacer soi-même ses cartes

- Quand tu commences → **In Progress**
- Quand tu ouvres la PR → **In Review**
- Quand la PR est mergée → **Done** (automatique via GitHub Actions)

---

## 12. Ce qu'il ne faut JAMAIS faire

```java
// ❌ Logique métier dans un controller
if (product.getStock() == 0) return ResponseEntity.badRequest()... // NON

// ❌ Retourner une entité JPA dans un controller
return ResponseEntity.ok(userRepository.findById(id)); // NON — utiliser un DTO

// ❌ System.out.println
System.out.println("Product created: " + product.getId()); // NON — utiliser log.info(...)

// ❌ Valeurs hardcodées
String apiKey = "sk_live_xxxxxxxx"; // NON — variable d'environnement

// ❌ @Transactional dans un controller ou un repository
@Transactional // NON — uniquement dans les services
public ResponseEntity<...> create(...) { ... }

// ❌ Appeler un repository d'un autre module
@Autowired
private UserRepository userRepository; // NON dans ProductServiceImpl — passer par UserService

// ❌ FetchType.EAGER sans justification
@OneToMany(fetch = FetchType.EAGER) // NON par défaut

// ❌ Modifier une migration Flyway existante
// V2__create_users_table.sql → NE JAMAIS MODIFIER après le premier run

// ❌ Committer des secrets
JWT_SECRET=monsecret123 // NON dans le code ou dans .env commité

// ❌ Push direct sur main ou develop
git push origin main // BLOQUÉ par GitHub — toujours passer par une PR
```

---

*Document maintenu par le Senior Backend. Toute suggestion d'amélioration → ouvrir une issue avec le label `docs`.*
