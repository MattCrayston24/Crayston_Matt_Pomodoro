# Pomodoro Timer Flutter App

Cette application Flutter est un minuteur Pomodoro complet avec support des sessions personnalisées, pauses courtes et longues, gestion du thème clair/sombre, et sauvegarde des sessions dans une base Supabase.

---

## Fonctionnalités principales

- Minuteur Pomodoro avec trois types de sessions :
  - **Pomodoro** (par défaut 25 minutes)
  - **Pause courte** (par défaut 5 minutes)
  - **Pause longue** (par défaut 15 minutes)
- Durée personnalisable pour chaque type de session via un slider.
- Contrôle du minuteur avec les boutons **Démarrer**, **Pause**, **Reprendre** et **Reset**.
- Animation circulaire de la progression du temps.
- Thème clair / sombre avec un switch dans la barre d'applications.
- Sauvegarde automatique des sessions terminées dans une base Supabase (avec utilisateur connecté).
- Notifications locales à la fin d'une session.
- Navigation vers une page d'historique des sessions.
- Déconnexion utilisateur via Supabase Auth.

---

## Structure du code

- **HomePage** : widget principal gérant l'interface du minuteur et l'état de la session.
- **SessionType** : énumération des types de session possibles.
- **AnimationController** : anime la progression circulaire du temps.
- **Timer** : décompte en secondes de la session.
- **SupabaseService** : service pour enregistrer les sessions en base de données.
- **NotificationService** : service pour afficher une notification lorsque la session est terminée.
- **LoginScreen** : écran de connexion affiché lors de la déconnexion.

---

## Utilisation

### Démarrage et contrôle du minuteur

- Sélectionnez un type de session (Pomodoro, Pause courte, Pause longue) via les boutons en bas.
- Réglez la durée personnalisée avec le slider (si aucune session n’est en cours).
- Appuyez sur **Démarrer** pour lancer le minuteur.
- Utilisez **Pause** pour suspendre la session, puis **Reprendre** pour continuer.
- Le bouton **Reset** stoppe la session en cours et enregistre si elle était active.

### Thème

- Utilisez le switch dans la barre d'applications pour basculer entre thème clair et sombre.

### Historique

- Le bouton **Historique** ouvre la page listant les sessions précédentes enregistrées.

### Déconnexion

- Le bouton de déconnexion déconnecte l'utilisateur et renvoie à l'écran de login.

---

## Dépendances

- Flutter SDK
- [supabase_flutter](https://pub.dev/packages/supabase_flutter) pour l'authentification et la base de données.
- Services personnalisés pour la gestion des sessions et notifications (`SupabaseService`, `NotificationService`).

---

## Configuration

- Initialiser Supabase dans l'application avec votre URL et clé.
- Implémenter les services `SupabaseService` (pour la sauvegarde des sessions) et `NotificationService` (pour gérer les notifications).
- Assurez-vous que l'utilisateur est connecté avant d'utiliser l'app.

---

## Format du timer

- La durée est affichée au format `mm:ss`.
- La progression est animée avec un `CircularProgressIndicator`.
- Le timer se met à jour chaque seconde via un `Timer.periodic`.

---

## Notes techniques

- Le minuteur utilise un `AnimationController` pour l'animation du cercle, qui est synchronisé avec le timer en secondes.
- Le slider n’est actif que lorsque la session est arrêtée.
- Lorsqu'une session se termine, elle est automatiquement sauvegardée en base avec :
  - Type de session (Pomodoro, Pause courte ou longue)
  - Durée effective en secondes
  - Timestamp de début
  - ID utilisateur Supabase
- Les sessions terminées déclenchent une notification locale.

---

## Suggestions d'amélioration

- Ajouter une gestion des sessions en arrière-plan (notifications programmées).
- Synchroniser les préférences utilisateur avec Supabase.
- Ajouter des sons ou alertes personnalisables.
- Support multi-langue.

---

Merci d'utiliser cette application Pomodoro Flutter !  
Pour toute question ou amélioration, n'hésitez pas à me contacter.

---

Pour le fichier exécutable :

Built build\windows\x64\runner\Release\pomodoro_app.exe

Le fichier exécutable est situé ici : build\windows\x64\runner\Release\pomodoro_app.exe
Ce fichier .exe peut être lancé sur un système Windows 64 bits pour démarrer l'application Pomodoro.
