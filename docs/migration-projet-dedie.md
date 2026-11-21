# Passer Excess sur un projet Supabase dédié

Aujourd'hui, les tables Excess vivent dans le projet Supabase **App sport**, parce que l'offre gratuite limite le compte à 2 projets actifs. Si un projet dédié devient possible (offre Pro, ou un projet libéré), voici la marche à suivre.

1. Créer le projet Supabase « Excess » (région `eu-west-1` ou `eu-central-1`).
2. Y appliquer [schema.sql](schema.sql).
3. Créer le compte de Kilian dans Authentication → Users (même e-mail). Noter son nouvel id.
4. Exporter les données depuis App sport :
   ```sql
   select * from public.excess_posts;
   select * from public.excess_meta;
   ```
   puis les insérer dans le nouveau projet en remplaçant `owner` par le nouvel id.
5. Dans `index.html`, remplacer `SB_URL` et `SB_KEY` par l'URL et la clé *publishable* du nouveau projet. Commit + push : Vercel redéploie.
6. Vérifier l'app sur https://excess.kadeon.be, puis supprimer les tables `excess_posts`, `excess_meta` et la fonction `excess_touch` du projet App sport.
7. Mettre à jour le README (sections 5, 6 et 7) et `docs/metricool.md` (id du projet et du compte).
