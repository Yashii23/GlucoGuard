# 🚀 Step-by-Step Integration Guide

## STEP 0 — Install Packages

Run this command in your project root:
```
flutter pub add flutter_local_notifications timezone fl_chart pdf printing path_provider intl shared_preferences provider url_launcher permission_handler
```
OR update pubspec.yaml (use the provided pubspec.yaml) and run:
```
flutter pub get
```

---

## STEP 1 — 🔔 Reminder System

### Files to create:
- `lib/services/notification_service.dart` ← NEW FILE
- `lib/screens/reminder_screen.dart` ← NEW FILE

### main.dart changes:
1. Add: `import 'services/notification_service.dart';`
2. Add in main(): `await NotificationService().init();`

### Add permissions to AndroidManifest.xml (see ANDROID_IOS_PERMISSIONS.txt)

### Navigate to reminder screen (from your home/menu):
```dart
Navigator.pushNamed(context, '/reminders');
// OR
Navigator.push(context, MaterialPageRoute(builder: (_) => const ReminderScreen()));
```

### How it works:
- User taps "Add Reminder" → picks time → daily notification scheduled
- Notification shows every day at that time
- User can delete reminders (also cancels notification)

---

## STEP 2 — 🕒 Add Previous Entry

### Files to create:
- `lib/models/sugar_entry.dart` ← REPLACE existing or add toJson/fromJson
- `lib/services/sugar_service.dart` ← NEW FILE
- `lib/screens/add_previous_entry_screen.dart` ← NEW FILE

### Navigate:
```dart
Navigator.push(context, MaterialPageRoute(
  builder: (_) => const AddPreviousEntryScreen(),
)).then((result) {
  if (result == true) {
    // Refresh your sugar list
    setState(() {});
  }
});
```

### ⚠️ If you already save sugar entries differently:
You need to migrate your storage to use SugarService (SharedPreferences + JSON).
If you use Firebase/Hive, adapt SugarService accordingly.

---

## STEP 3 — 📊 Sugar Graph

### Files to create:
- `lib/screens/sugar_graph_screen.dart` ← NEW FILE

### Depends on:
- `SugarService.getRecentEntries()` from sugar_service.dart
- `fl_chart` package

### Navigate:
```dart
Navigator.pushNamed(context, '/graph');
```

---

## STEP 4 — 📄 Doctor Report (PDF)

### Files to create:
- `lib/services/pdf_service.dart` ← NEW FILE
- `lib/screens/doctor_report_screen.dart` ← NEW FILE

### Depends on: `pdf`, `printing`, `path_provider` packages

---

## STEP 5 — 💉 Insulin Log

### Files to create:
- `lib/models/insulin_entry.dart` ← NEW FILE
- `lib/screens/insulin_log_screen.dart` ← NEW FILE

---

## STEP 6 — 🧠 Sugar Prediction

### Files to create:
- `lib/services/prediction_service.dart` ← NEW FILE
- `lib/screens/sugar_prediction_screen.dart` ← NEW FILE

---

## STEP 7 — 🍽️ Food Warning

### Files to create:
- `lib/screens/food_warning_screen.dart` ← NEW FILE

---

## STEP 8 — 📈 Stability Score

### Files to create:
- `lib/screens/stability_score_screen.dart` ← NEW FILE

---

## STEP 9 — 🎥 Talk to Doctor

### Files to create:
- `lib/screens/talk_to_doctor_screen.dart` ← NEW FILE

### Depends on: `url_launcher` package
Update phone number and email in talk_to_doctor_screen.dart:
```dart
_launchPhone(context, '+91XXXXXXXXXX'); // ← put real doctor number
_launchEmail(context, 'doctor@example.com'); // ← put real email
```

---

## STEP 10 — 🌗 Dark / Light Mode

### Files to create:
- `lib/services/theme_service.dart` ← NEW FILE
- `lib/screens/settings_screen.dart` ← NEW FILE

### main.dart changes:
1. Add `import 'package:provider/provider.dart';`
2. Wrap app with `ChangeNotifierProvider<ThemeService>`
3. Use `themeMode: context.watch<ThemeService>().themeMode`
4. Define both `theme:` and `darkTheme:` in MaterialApp

---

## 🔔 Auto-reminder when no entry logged today

Add this check to your home screen's `initState`:

```dart
import '../services/sugar_service.dart';
import '../services/notification_service.dart';

@override
void initState() {
  super.initState();
  _checkMissedEntry();
}

Future<void> _checkMissedEntry() async {
  final hasEntry = await SugarService.hasEntryToday();
  if (!hasEntry) {
    await NotificationService().showInstantNotification(
      title: '⚠️ Don\'t forget!',
      body: 'You haven\'t logged your blood sugar today. Tap to record.',
    );
  }
}
```

---

## ✅ Quick Navigation — Add to your Home Screen

Add these buttons/list items to navigate to new features:

```dart
ListTile(
  leading: const Icon(Icons.alarm),
  title: const Text('Reminders'),
  onTap: () => Navigator.pushNamed(context, '/reminders'),
),
ListTile(
  leading: const Icon(Icons.history),
  title: const Text('Add Previous Entry'),
  onTap: () => Navigator.pushNamed(context, '/add-previous'),
),
ListTile(
  leading: const Icon(Icons.show_chart),
  title: const Text('Sugar Graph'),
  onTap: () => Navigator.pushNamed(context, '/graph'),
),
// ... and so on for all 10 routes
```

---

## 🛑 Common Errors & Fixes

| Error | Fix |
|-------|-----|
| `MissingPluginException` for notifications | Run `flutter clean && flutter pub get` |
| Notifications not showing on Android 13+ | Request POST_NOTIFICATIONS permission at runtime |
| `PlatformException` for url_launcher | Add `<queries>` block in AndroidManifest for Android 11+ |
| PDF not opening | Make sure `printing` package is added correctly |
| Dark mode not persisting | Confirm `shared_preferences` is added and `ThemeService` is initialized in main() |

---

## 📦 All Files Summary

| File | Feature |
|------|---------|
| `services/notification_service.dart` | Step 1 |
| `screens/reminder_screen.dart` | Step 1 |
| `models/sugar_entry.dart` | Step 2 (updated) |
| `services/sugar_service.dart` | Step 2, 3, 4, 6, 7, 8 |
| `screens/add_previous_entry_screen.dart` | Step 2 |
| `screens/sugar_graph_screen.dart` | Step 3 |
| `services/pdf_service.dart` | Step 4 |
| `screens/doctor_report_screen.dart` | Step 4 |
| `models/insulin_entry.dart` | Step 5 |
| `screens/insulin_log_screen.dart` | Step 5 |
| `services/prediction_service.dart` | Step 6 |
| `screens/sugar_prediction_screen.dart` | Step 6 |
| `screens/food_warning_screen.dart` | Step 7 |
| `screens/stability_score_screen.dart` | Step 8 |
| `screens/talk_to_doctor_screen.dart` | Step 9 |
| `services/theme_service.dart` | Step 10 |
| `screens/settings_screen.dart` | Step 10 |
| `main.dart` | Integration hub |
