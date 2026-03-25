# ⛸️ Caisse "Jetons Synchro"

Ce dépôt contient le code source de l'application de Caisse Centrale pour la Coupe de France de Patinage Synchronisé. L'objectif de cette PWA (Progressive Web App) "Offline-First" est de remplacer les encaissements en liquide distribués en facilitant la vente de jetons aux visiteurs.

---

## 🏗️ La Stack Technique

Cette application est pensée pour la robustesse, la maintenabilité et l'ergonomie développeur, en utilisant des standards modernes de l'industrie :

- **[Elm (0.19.1)](https://elm-lang.org/)** : Le cœur de l'application. Un langage purement fonctionnel typé statiquement qui garantit **zéro exception à l'exécution** (_No Runtime Exceptions_). Elm est idéal ici car sa gestion d'état immuable (The Elm Architecture) garantit que les calculs de la caisse (rendre la monnaie, comptage des jetons) sont déterministes et infaillibles.
- **[Vite](https://vitejs.dev/)** : Notre _bundler_ et serveur de développement ultra-rapide. Il offre un temps de démarrage instantané et un rechargement à chaud (HMR) performant. Couplé au plugin `vite-plugin-elm`, il optimise également les builds Elm pour la production.
- **[Tailwind CSS](https://tailwindcss.com/)** : Un framework CSS _utility-first_ qui permet d'élaborer une interface fluide et _responsive_ directement avec le balisage, sans aucun effet de bord lié à la cascade CSS. Parfait pour itérer rapidement sur l'IHM des terminaux tactiles.
- **[Mise-en-place (`mise`)](https://mise.jdx.dev/)** : Utilisé pour la gestion des environnements de développement. Il garantit que chaque contributeur utilise les mêmes versions exactes des dépendances binaires (Node.js et Elm) sans configurer son système globalement.
- **Tests (Elm-test)** : L'application suit une discipline **TDD stricte**. Aucun code métier n'est écrit sans être précédé d'un test qui échoue.

---

## 🚀 Démarrage Rapide

Voici comment compiler et développer l'application sur votre machine en quelques étapes simples.

### 1. Prérequis

Assurez-vous d'avoir [`mise`](https://mise.jdx.dev/) d'installé sur votre système. `mise` va installer automatiquement les bonnes versions de Node et d'Elm.

```bash
# Installe les outils définis dans .mise.toml (Node & Elm)
mise install
```

### 2. Installation des dépendances

Installez les dépendances du projet (Vite, Tailwind, etc.) :

```bash
npm install
```

### 3. Lancer le serveur de développement

Pour lancer l'application en mode développement avec rechargement à chaud :

```bash
npm run dev
```

Une fois le serveur démarré, ouvrez l'URL fournie (ex: `http://localhost:5173/coupe-de-france/`) dans votre navigateur.

---

## 🧪 Tests et TDD

Le projet adhère à des principes TDD (*Test-Driven Development*) stricts. Avant toute implémentation, écrivez votre test.

- **Pour exécuter les suites de tests une fois :**
  ```bash
  npm test
  ```
- **Pour lancer les tests en mode veille (Watch mode) durant le développement :**
  ```bash
  npm run test:watch
  ```

---

## 📦 Build pour la Production

Pour compiler l'application de façon optimisée pour le déploiement (génère les fichiers statiques dans le dossier `dist/`) :

```bash
npm run build
```

Le projet est configuré avec un workflow GitHub Actions (`.github/workflows/deploy.yml`) afin de se déployer automatiquement via GitHub Pages lors d'un _push_ sur la branche `main`.
