# Mise à jour des stats depuis Metricool

Les vues affichées dans l'app viennent de Metricool. L'app hébergée sur Vercel ne lit pas Metricool elle-même : Claude fait la mise à jour quand Kilian le demande (« mets à jour mes stats Excess »).

## Source

- Connecteur claude.ai : **Metricool Social Media Management**
- Marque : `excess.ofc`, `brandId` **8053461**, fuseau `Europe/Brussels`
- Outil : `getAnalyticsDataByMetrics`, réseau TikTok, connecteur `posts`
- Métriques demandées, dans cet ordre :

| Code | Contenu | Format renvoyé |
|---|---|---|
| `TKPO02` | Date et heure de publication | `AAAAMMJJhhmmss` |
| `TKPO05` | Description (caption + hashtags) | texte |
| `TKPO06` | Durée | secondes, en texte |
| `TKPO07` | Vues | nombre, en texte |

Réponse : `{"rows": [[TKPO02, TKPO05, TKPO06, TKPO07], ...]}`, une ligne par vidéo.

Autres métriques disponibles si besoin : likes `TKPO08`, commentaires `TKPO09`, partages `TKPO10`, portée `TKPO11`, taux de visionnage complet `TKPO13`, temps moyen `TKPO15`, sources de trafic `TKPO16`-`TKPO21` (ces derniers étaient vides lors de l'audit de novembre 2026).

## Procédure

1. Lire Metricool sur les 120 derniers jours.
2. Pour chaque ligne :
   - `date` = AAAA-MM-JJ, `time` = hh:mm.
   - Chercher dans `excess_posts` une ligne du même jour dont l'heure est à 45 minutes près (ou sans heure).
   - Trouvée : mettre à jour `views`, `status = 'publie'`, et `time` / `duration` / `tiktok` / `hashtags` seulement s'ils sont vides.
   - Pas trouvée : créer une ligne `id = 'p' || AAAAMMJJ` (ajouter `hhmm` si l'id existe déjà), `status = 'publie'`, titre court en minuscules tiré de la caption, type déduit du contenu (`souvenir` pour un moment de festival, `enchainement` pour « X into Y », `classement` pour un top, `continuum` pour la série de mixes, sinon `autre`).
3. `update public.excess_meta set last_sync = now();`

Les écritures se font avec l'outil SQL Supabase (projet `mrqxkncxksncidkpwlib`). Le compte de Kilian a l'id `664067c2-0118-4e75-b9d8-666d0f5ed42f` : le préciser dans `owner` pour toute nouvelle ligne écrite hors de l'app.

## Exemple SQL

```sql
update public.excess_posts set views = 2917 where id = 'p20261105';

insert into public.excess_posts (id, owner, title, type, status, date, time, duration, views, tiktok, hashtags)
values ('p20261124', '664067c2-0118-4e75-b9d8-666d0f5ed42f', 'titre court', 'souvenir', 'publie',
        '2026-11-24', '18:00', 18, 0, 'caption…', '#hardstyle …')
on conflict (id) do update set views = excluded.views;

update public.excess_meta set last_sync = now();
```

## Règle

Lire Metricool ne publie rien. Ne jamais programmer ou publier un post via Metricool sans validation explicite de Kilian.
