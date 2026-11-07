# FixTrail - Campus Incident Reporting (Flutter + Firebase)

## 1. Create the Flutter project, then drop these files in
```bash
flutter create --org com.yourname --platforms=android,ios fixtrail
cd fixtrail
# delete the generated lib/ and test/, then copy from this zip:
#   lib/  test/  pubspec.yaml  firebase/  README.md
flutter pub get
```
Android: in `android/app/build.gradle(.kts)` set `minSdk = 23`.
iOS: add `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` to `ios/Runner/Info.plist`.

## 2. Firebase console
1. Create a project.
2. Authentication > enable **Email/Password**.
3. Firestore Database > Create (production mode) > Rules > paste `firebase/firestore.rules` > Publish.
4. Photos: pick ONE
   - **Supabase (free, default)** - follow "Supabase photo storage" below. Skip Firebase Storage.
   - **Firebase Storage** (needs the Blaze plan) - Storage > Get started > Rules > paste `firebase/storage.rules`, then set `AppConstants.useSupabaseStorage = false`.

## 3. Generate `lib/firebase_options.dart` (REQUIRED - main.dart imports it)
```bash
dart pub global activate flutterfire_cli
firebase login
flutterfire configure      # choose your project + android/ios
```
Fallback if the CLI fails: copy `firebase/firebase_options.template.dart` to
`lib/firebase_options.dart` and fill in your values.

## Supabase photo storage
1. Supabase dashboard > Storage > **New bucket** > name `incident-photos`, **Public bucket ON**, file size limit 5 MB, allowed MIME types `image/jpeg, image/png, image/webp`.
2. SQL Editor > paste `supabase/storage_policies.sql` > Run.
3. Settings > General (or the **Connect** button) > copy the **Project URL**. Settings > API Keys > copy the full **Publishable key** (`sb_publishable_...`).
4. Put both in `lib/core/constants.dart` (`supabaseUrl`, `supabasePublishableKey`). Never use the secret key in the app.

## 4. Run
`flutter run`

## Email verification switch
`AppConstants.requireEmailVerification` (lib/core/constants.dart), default **false**:
- false -> only the ALU-domain check (@alustudent.com / @alueducation.com); no inbox needed.
- true  -> users must click the emailed link first.
If you change it, also set `requireVerified()` to the same value in BOTH rules files and re-publish them.
(The grading rubric mentions email verification: turn it ON for the final demo with your own real ALU email.)

## Staff account + demo data
1. Register an `@alueducation.com` (or any allowed-domain) account.
2. Firestore > `users` > that user's doc > change `role` to `staff`. Sign out and in.
3. Profile tab > **Developer tools** > **Load demo data** (12 sample reports in all statuses). **Remove** deletes only the demo reports.

## Dark / light theme
Profile > Dark mode. Saved with shared_preferences; first launch follows the phone setting.

## Testing with a non-ALU email
Add its domain to `AppConstants.allowedDomains` and to the regex in `firestore.rules`. Revert afterwards.

## Tests
`flutter test`
