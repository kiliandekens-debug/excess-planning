# Planning Excess

Application web privée pour planifier et suivre les publications TikTok du projet hardstyle **Excess** (@excess.ofc).

- **Adresse** : https://excess.kadeon.be
- **Accès** : réservé à Kilian (connexion e-mail + mot de passe)
- **Code** : un seul fichier, `index.html`, sans étape de build

---

## Sommaire

1. [Ce que fait l'app](#1-ce-que-fait-lapp)
2. [Se connecter](#2-se-connecter)
3. [Utiliser l'app au quotidien](#3-utiliser-lapp-au-quotidien)
4. [Règles de publication](#4-règles-de-publication)
5. [Architecture](#5-architecture)
6. [Base de données Supabase](#6-base-de-données-supabase)
7. [Mettre à jour les stats Metricool](#7-mettre-à-jour-les-stats-metricool)
8. [Hébergement Vercel et domaine](#8-hébergement-vercel-et-domaine)
9. [Modifier l'app](#9-modifier-lapp)
10. [Dépannage](#10-dépannage)
11. [Historique](#11-historique)

---

## 1. Ce que fait l'app

L'app a deux onglets.

**Planning**
- **Prochain drop** : le prochain créneau de publication, avec un compte à rebours en direct et la vidéo prévue. Si le créneau est vide, un bouton permet de le remplir.
- **Bande des 14 jours** : un repère par créneau. Magenta = vidéo prévue, contour rouge = créneau vide. Un clic sur un jour ouvre la semaine correspondante.
- **Semaine** : les 7 jours avec les créneaux. Un créneau vide (hachuré rouge) se remplit d'un clic, depuis la réserve ou avec une nouvelle vidéo.
- **Réserve** : les vidéos prêtes mais sans date. Le bouton « Placer » prend le prochain créneau libre et évite deux vidéos du même type à la suite.
- **Fiche post** : titre, type, statut, durée, date, heure, vues, caption TikTok, hashtags (compteur sur 5), titre et description YouTube Shorts, caption Instagram. Chaque texte a un bouton « Copier ».

**Stats**
- Jauge : part des vidéos publiées qui atteignent **1 000 vues**.
- Vues médianes, meilleure vidéo, nombre de vidéos suivies.
- Graphique en colonnes de chaque vidéo, de la plus ancienne à la plus récente, avec la ligne des 1 000 vues.
- Vues médianes **par type de contenu** et **par créneau**. Une comparaison n'est tirée que s'il y a au moins 2 vidéos dans le groupe.

L'app ne publie rien sur TikTok. Elle sert à préparer, planifier et suivre.

## 2. Se connecter

- Ouvrir https://excess.kadeon.be
- Se connecter avec **le même e-mail et mot de passe que l'app App sport** (les deux apps partagent le même projet Supabase, donc le même compte).
- La session reste ouverte sur l'appareil. Bouton « Déconnexion » en haut à droite.
- Sur téléphone : ouvrir l'adresse dans le navigateur, puis « Ajouter à l'écran d'accueil ». L'app s'ouvre alors comme une app native.

Mot de passe oublié : le réinitialiser depuis App sport ou depuis le tableau de bord Supabase (Authentication → Users).

## 3. Utiliser l'app au quotidien

| Je veux… | Je fais… |
|---|---|
| Ajouter une vidéo prête | « + Nouvelle vidéo », statut « Prête », sans date → elle va dans la réserve |
| La programmer | « Placer » dans la réserve, ou clic sur un créneau vide rouge |
| Préparer les textes | Ouvrir la fiche, remplir caption, hashtags, YouTube, Instagram |
| Publier | Copier les textes depuis la fiche et publier dans TikTok (ou via Metricool, toujours après validation) |
| Marquer comme publiée | Fiche → statut « Publiée » (fait automatiquement lors de la mise à jour des stats) |
| Annuler une programmation | Fiche → « Remettre en réserve » |
| Supprimer | Fiche → « Supprimer », puis « Confirmer la suppression » |
| Voir les stats à jour | Demander à Claude : « mets à jour mes stats Excess » (voir section 7) |

Statuts : **Idée** → **Prête** → **Programmée** → **Publiée**.
Une vidéo avec une date future passe automatiquement en « Programmée ». Une vidéo sans date ne peut pas être « Programmée ».

## 4. Règles de publication

Issues de l'audit du 19 novembre 2026 (13 vidéos, données Metricool). À réévaluer toutes les 2 semaines.

**Créneaux** (heure belge), définis dans `index.html` (`SLOTS`) :
- Mardi 18:00
- Jeudi 18:00
- Dimanche 20:00

**Répartition** : 2 créneaux sur 3 pour des souvenirs de festival (le format qui dépasse les 1 000 vues), 1 créneau pour tester un format qui ne fonctionne pas encore (enchaînements, classement, Continuum, guess the track).

**Format vidéo** : 15 à 25 secondes, accroche dès la 1re seconde. Pour un enchaînement, la transition arrive dans les 3 à 5 premières secondes.

**Textes** : texte à l'écran en anglais, en haut dans la zone de sécurité, trois lignes maximum, fondus simples sans rebond. Caption en minuscules, émotion d'abord, une seule question, 🖤. **5 hashtags maximum.**

**Règle d'arrêt d'un format testé** : 4 vidéos avec les ajustements. Si la médiane reste sous 500 vues, on change de format ; si elle monte, il gagne des créneaux.

**Validation** : rien n'est publié ni programmé sur un réseau social sans validation explicite de Kilian.

## 5. Architecture

```
Navigateur (excess.kadeon.be)
   │  index.html : HTML + CSS + JS, aucune dépendance à compiler
   │  supabase-js 2.45.4 chargé depuis cdn.jsdelivr.net
   ▼
Supabase (projet « App sport », eu-west-1)
   ├─ Auth : e-mail + mot de passe
   ├─ Tables : excess_posts, excess_meta (RLS : chacun ne voit que ses lignes)
   └─ Realtime : l'app se recharge quand excess_posts change
          ▲
          │  mise à jour des vues (SQL)
Claude ── Metricool (connecteur claude.ai, marque excess.ofc)
```

- **Hébergement** : Vercel, projet `excess-planning` (équipe `kiliandekens-2863's projects`), site statique.
- **Déploiement** : chaque push sur `main` de ce dépôt met le site à jour automatiquement.
- **Clé Supabase** : la clé *publishable* est écrite dans `index.html`. C'est normal et sans risque : elle est faite pour être publique, la sécurité vient des règles RLS. Ne **jamais** mettre la clé `service_role` dans le code.

### Pourquoi Excess est dans le projet Supabase « App sport »

Le compte Supabase est en offre gratuite (2 projets actifs maximum, déjà utilisés par Whist et App sport). Les tables Excess ont donc été ajoutées à App sport, avec le préfixe `excess_` et leurs propres règles d'accès. Elles ne touchent à aucune table d'App sport.

Conséquence : si App sport est mis en pause ou supprimé, Excess l'est aussi. Pour passer sur un projet dédié plus tard (offre Pro), voir [docs/migration-projet-dedie.md](docs/migration-projet-dedie.md).

## 6. Base de données Supabase

Le schéma complet est dans [docs/schema.sql](docs/schema.sql).

**`excess_posts`** : une ligne par vidéo.

| Colonne | Type | Contenu |
|---|---|---|
| `id` | text, clé | Identifiant. Vidéos publiées : `pAAAAMMJJ` |
| `owner` | uuid | Compte Supabase propriétaire (rempli automatiquement) |
| `title` | text | Titre interne |
| `type` | text | `souvenir`, `enchainement`, `classement`, `continuum`, `autre` |
| `status` | text | `idee`, `pret`, `programme`, `publie` |
| `date` | date | Date de publication (vide = en réserve) |
| `time` | text | Heure `HH:MM`, heure belge |
| `duration` | integer | Durée en secondes |
| `views` | integer | Vues TikTok (source Metricool) |
| `tiktok`, `hashtags` | text | Caption et hashtags TikTok |
| `yt_title`, `yt_desc` | text | Titre et description YouTube Shorts |
| `insta` | text | Caption Instagram (vide = même texte que TikTok) |
| `updated_at` | timestamptz | Mis à jour automatiquement |

**`excess_meta`** : une ligne par compte, `last_sync` = date de la dernière mise à jour des vues (affichée dans l'onglet Stats).

**Sécurité** : RLS activé sur les deux tables. Seul le compte propriétaire (`owner = auth.uid()`) peut lire et écrire. Le rôle `anon` n'a aucun droit.

## 7. Mettre à jour les stats Metricool

Sur Vercel, l'app ne peut pas lire Metricool elle-même. La mise à jour se fait en demandant à Claude :

> « mets à jour mes stats Excess »

Procédure suivie (détaillée dans [docs/metricool.md](docs/metricool.md)) :
1. Lire dans Metricool (marque `excess.ofc`, id 8053461) les vidéos TikTok : date et heure, description, durée, vues.
2. Pour chaque vidéo, retrouver la ligne `excess_posts` du même jour (heure à 45 minutes près) et mettre à jour `views`, `status = 'publie'`, l'heure et la durée si elles manquent.
3. Créer une ligne pour toute vidéo publiée absente du planning.
4. Mettre à jour `excess_meta.last_sync`.

L'app affiche les nouveaux chiffres immédiatement (Realtime).

## 8. Hébergement Vercel et domaine

- Projet Vercel : `excess-planning`, relié à ce dépôt GitHub (branche `main`).
- Framework : aucun (site statique). Pas de commande de build.
- Domaine : `excess.kadeon.be`, rattaché au projet.
- Le DNS de `kadeon.be` est géré chez **Combell** (`ns1.combell.eu`, `ns3/ns4.combell.net`). Enregistrement nécessaire dans la zone DNS Combell :

| Type | Nom | Valeur |
|---|---|---|
| CNAME | `excess` | `cname.vercel-dns.com` |

Vercel génère le certificat HTTPS automatiquement une fois le CNAME en place.

## 9. Modifier l'app

Tout est dans `index.html` :
- `<style>` : design (tokens de couleur et polices en haut, `:root`).
- `SLOTS` : les créneaux de publication (`dow` : 0 = dimanche … 6 = samedi).
- `TYPES` : les types de contenu (à garder alignés avec la contrainte `type` de la table).
- `GOAL` : l'objectif de vues (1 000).
- `SB_URL`, `SB_KEY` : connexion Supabase.

Pour tester en local : ouvrir `index.html` dans un navigateur (la connexion Supabase fonctionne aussi en local).
Pour publier : commit + push sur `main`, Vercel déploie en moins d'une minute.

## 10. Dépannage

| Problème | Cause probable | Solution |
|---|---|---|
| « E-mail ou mot de passe incorrect » | Mauvais identifiants | Ceux d'App sport ; réinitialiser dans Supabase si besoin |
| « Impossible de charger le planning » | Projet Supabase App sport en pause | Le relancer depuis le tableau de bord Supabase |
| excess.kadeon.be ne répond pas | CNAME absent ou pas encore propagé chez Combell | Vérifier l'enregistrement (section 8), attendre jusqu'à 1 h |
| Les vues ne bougent pas | Pas de mise à jour récente | Demander à Claude de mettre à jour les stats |
| Créneau « déjà pris » | Une autre vidéo a déjà ce jour et cette heure | Changer l'heure ou remettre l'autre vidéo en réserve |

## 11. Historique

- **19 nov. 2026** : audit TikTok (horaires, hashtags, stats), définition des 3 créneaux.
- **20 nov. 2026** : première version de l'app sur claude.ai (stockage claude.ai, synchro Metricool intégrée).
- **21 nov. 2026** : nouveau design « scène » ; passage sur Supabase + Vercel + GitHub, domaine `excess.kadeon.be`. Import des 15 vidéos publiées (25 oct. → 20 nov. 2026).
