# FixTrail

A campus incident reporting app for ALU, built with Flutter and Firebase. Students report issues (broken facilities, water or electricity outages, damaged furniture, sanitation and safety problems) and follow them from **Submitted** to **In progress** to **Resolved**. Authorised staff review reports and update their status.

Built for Mobile Application Development, Individual Assignment 2.
Author: Cedric Bigwi Hindura

## Features

- Register and sign in with an ALU email (`@alustudent.com` or `@alueducation.com`), with email verification
- Submit a report with category, title, description, campus location and an optional photo
- Browse all reports or only your own, with search and status and category filters
- Report details with a status timeline, staff notes and a "Me too" button
- Edit your report until it is resolved, or delete it
- Staff desk: update a report's status and add a note (staff accounts only)
- Hide your name from other students (staff can still see it)
- Light and dark mode, remembered on the device

## Tech stack

| Area | Choice |
|---|---|
| UI | Flutter (Material 3) |
| State management | Provider (`ChangeNotifier`, `ProxyProvider`) |
| Authentication | Firebase Authentication (email and password) |
| Database | Cloud Firestore (`users`, `incidents`) |
| Photo storage | Supabase Storage (approved alternative to Firebase Storage) |
| Local settings | SharedPreferences (theme) |

## Project structure

```
lib/
  core/        theme, constants, validators, campus locations
  models/      Incident, AppUser
  providers/   AuthProvider, IncidentProvider, ThemeProvider
  services/    AuthService, IncidentService, PhotoStorageService, demo data
  screens/     auth, home, reports, staff, profile
  widgets/     reusable cards, filters, badges, photo viewer
firebase/      Firestore security rules
supabase/      storage policies (SQL)
test/          unit tests
```

## Getting started

1. Install [Flutter](https://docs.flutter.dev/get-started/install), then run `flutter pub get`.
2. **Firebase:** create a project, enable Email/Password sign-in, create a Firestore database, and publish `firebase/firestore.rules`.
3. Run `flutterfire configure` to generate `lib/firebase_options.dart`.
4. **Photos (Supabase):** create a public bucket named `incident-photos`, run `supabase/storage_policies.sql` in the SQL editor, then put your project URL and **publishable** key in `lib/core/constants.dart`. Never put the secret key in the app.
5. Run the app: `flutter run` (phone, emulator, or Chrome with DevTools device mode).

## Staff account and demo data

Staff cannot be created from inside the app. Register an account, then in the Firebase console open `users/<uid>` and change `role` from `student` to `staff`. Staff users get a **Staff** tab and a **Developer tools** card in Profile to load or remove demo reports.

## Settings worth knowing

- `AppConstants.requireEmailVerification` turns the verification step on or off. If you change it, change `requireVerified()` in `firebase/firestore.rules` too, and republish.
- `AppConstants.useSupabaseStorage` switches photo storage between Supabase and Firebase Storage.

## Tests

```
flutter test
```

Covers the validators and the search and filter logic.

## Known limitations

- The Supabase photo bucket accepts uploads from anyone holding the app's public key (limited by a 5 MB cap, image-only files and random file names).
- Staff promotion is manual, and there are no push notifications yet.
