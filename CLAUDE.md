# Instructions pour Claude — Planning Excess

- App statique : tout est dans `index.html`. Pas de build, pas de dépendances à installer.
- Données : Supabase projet App sport (`mrqxkncxksncidkpwlib`), tables `excess_posts` et `excess_meta` uniquement. Ne jamais toucher aux autres tables de ce projet (elles appartiennent à l'app sport).
- Mise à jour des stats : suivre `docs/metricool.md`.
- Déploiement : push sur `main` → Vercel (projet `excess-planning`, équipe `team_IkSw92kYJ3PG4sSYcXs5iRWE`) déploie automatiquement.
- Ne jamais committer la clé `service_role` ni aucun secret. La clé publishable dans `index.html` est prévue pour être publique.
- Ne jamais publier ni programmer sur TikTok, Instagram ou YouTube sans validation explicite de Kilian.
- Textes de l'interface en français ; textes à l'écran et captions des vidéos en anglais.
- Toute modification du schéma : mettre à jour `docs/schema.sql` et la section 6 du README.
