# ⛸️ Dossier de Conception : Caisse "Jetons Synchro"
**Projet :** Gestion de caisse centrale pour la Coupe de France de Patinage Synchronisé.
**Objectif :** Remplacer le cash par des jetons bois/papier pour fluidifier les ventes (buvette, boutique).

---

## 1. Contexte du Projet
Le club organise un événement national dans 15 jours. Pour simplifier la gestion, une **Caisse Centrale** vend des jetons à **1,00 € l'unité**. 
* **Utilisateurs :** Bénévoles (besoin d'une interface ultra-simple).
* **Support :** Tablettes (iPad) via navigateur web.
* **Contraintes :** Pas de serveur (données locales), gestion de la consigne des verres, risque de rupture de stock de jetons physiques.

---

## 2. Recensement des Exigences (Product Backlog)

### A. Flux Monétaires
* **Paiement :** Gestion des espèces (avec calcul de rendu) et de la CB (volume total).
* **Remboursement :** Rachat de jetons clients (max 5) pour limiter les sorties de cash.
* **Fond de caisse :** Saisie initiale et contrôle en cours de journée (écart de caisse).

### B. Flux Logistiques (Jetons)
* **Inventaire :** Suivi du stock en caisse centrale, dans les stands et en circulation.
* **Alerte :** Seuil critique à 200 jetons pour anticiper la production de jetons "papier".
* **Transferts :** Enregistrement des sacs de jetons récupérés des stands ou donnés pour les consignes.

### C. Technique & Sécurité
* **Offline First :** Fonctionnement sans internet après chargement initial.
* **Persistance :** Sauvegarde automatique dans le `localStorage` du navigateur.
* **Mirroring :** Export/Import de l'état via QR Code pour consultation sur smartphone.

---

## 3. Backlog détaillé (User Stories)

### US #1 : Initialisation de l'événement
**En tant que** Trésorier  
**Je veux** configurer le montant en espèces au démarrage et le stock de jetons bois  
**Afin de** définir la base de calcul pour la journée.
* **Description :** Écran de blocage à l'ouverture demandant : "Fond de caisse (€)" et "Nombre de jetons initial".
* **Critères d'acceptation :**
    * L'application calcule $Stock_{Total} = Stock_{Caisse}$.
    * Le bouton "Ouvrir la caisse" débloque l'interface de vente.

### US #2 : Vente au comptant (Espèces)
**En tant que** Bénévole  
**Je veux** sélectionner le nombre de jetons et les billets reçus  
**Afin de** rendre la monnaie sans erreur de calcul.
* **Description :** Pavé tactile avec boutons +1, +5, +10 jetons. Section "Paiement" avec boutons de billets/pièces (2, 5, 10, 20, 50).
* **Critères d'acceptation :**
    * Exemple : Vente 12 jetons (12 €). Clic sur "20€". Affiche "Rendre : 8€".
    * La validation décrémente le stock caisse et incrémente le liquide.

### US #3 : Vente par Carte Bancaire (CB)
**En tant que** Bénévole  
**Je veux** valider une vente en un clic via le mode CB  
**Afin de** séparer les flux numériques du liquide.
* **Description :** Bouton "Payer par CB" qui valide directement la transaction pour le montant total.
* **Critères d'acceptation :**
    * Pas de rendu de monnaie calculé.
    * Le montant est ajouté à la ligne "Cumul CB" du rapport final.

### US #4 : Rachat de jetons (Remboursement client)
**En tant que** Bénévole  
**Je veux** enregistrer le retour de maximum 5 jetons contre du liquide  
**Afin de** gérer les fins de journée des clients ou les consignes.
* **Description :** Bouton "Rembourser Client". Saisie limitée à 5 unités.
* **Critères d'acceptation :**
    * Bloque la validation si $> 5$.
    * Retire l'argent de la caisse et réintègre les jetons dans le stock caisse.

### US #5 : Gestion des flux logistiques (Stands)
**En tant que** Bénévole  
**Je veux** noter quand je donne des jetons aux stands ou quand ils m'en rapportent  
**Afin de** connaître le stock "En circulation".
* **Description :** Interface de transfert avec boutons "Donner au Stand" / "Récupérer du Stand".
* **Critères d'acceptation :**
    * Met à jour $Stock_{Caisse}$ et $Stock_{Stands}$.
    * Affiche en rouge si $Stock_{Caisse} < 200$.
    * Option "Ajouter Jetons Papier" pour augmenter manuellement le $Stock_{Total}$.

### US #6 : Audit et Contrôle Express
**En tant que** Trésorier  
**Je veux** comparer le liquide théorique et le liquide réel  
**Afin de** détecter les erreurs de caisse pendant les pauses.
* **Description :** Formulaire de comptage de billets/pièces.
* **Critères d'acceptation :**
    * L'appli affiche l'écart : $Liquide_{Réel} - (FondInitial + VentesEspèces - Remboursements)$.

### US #7 : Backup et Synchronisation (QR Code)
**En tant que** Trésorier  
**Je veux** générer un QR Code de l'état actuel  
**Afin de** le scanner avec mon téléphone pour suivre les ventes à distance.
* **Description :** Encode l'intégralité de la base de données locale dans un QR Code.
* **Critères d'acceptation :**
    * Le scan sur un autre appareil doit ouvrir l'application avec les mêmes chiffres exacts (lecture seule).
    * Bouton "Export CSV" pour la clôture comptable finale.

