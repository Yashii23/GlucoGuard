// lib/main.dart
// ✅ UPDATED main.dart — integrate all features
// ONLY modify the parts marked with ← UPDATE
// Keep your existing screens (Login, Signup, RecordSugar, etc.)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/hba1c_calculator_screen.dart';

// ← UPDATE: Import the new theme service
import 'package:diabetes_health_app/services/theme_service.dart';
import 'services/notification_service.dart';

// ← Keep your existing screen imports
// import 'screens/login_screen.dart';
// import 'screens/signup_screen.dart';
// import 'screens/home_screen.dart';

// ← UPDATE: Import new screens (add only what you need)
import 'package:diabetes_health_app/screens/reminder_screen.dart';
import 'package:diabetes_health_app/screens/add_previous_entry_screen.dart';
import 'package:diabetes_health_app/screens/sugar_graph_screen.dart';
import 'package:diabetes_health_app/screens/doctor_report_screen.dart';
import 'package:diabetes_health_app/screens/insulin_log_screen.dart';
import 'package:diabetes_health_app/screens/sugar_prediction_screen.dart';
import 'package:diabetes_health_app/screens/food_warning_screen.dart';
import 'package:diabetes_health_app/screens/stability_score_screen.dart';
//import 'package:diabetes_health_app/screens/talk_to_doctor_screen.dart';
import 'package:diabetes_health_app/screens/settings_screen.dart';
import 'package:diabetes_health_app/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ← UPDATE: Initialize notification service
  await NotificationService().init();

  runApp(
    // ← UPDATE: Wrap with ChangeNotifierProvider for theme
    ChangeNotifierProvider(
      create: (_) => ThemeService(),
      child: const DiabetesApp(),
    ),
  );
}

class DiabetesApp extends StatelessWidget {
  const DiabetesApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ← UPDATE: Listen to ThemeService
    final themeService = context.watch<ThemeService>();

    return MaterialApp(
      title: 'Diabetes Health App',
      debugShowCheckedModeBanner: false,

      // ← UPDATE: Use themeMode from ThemeService
      themeMode: themeService.themeMode,

      // Light theme
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: Colors.grey.shade100,
        ),
      ),

      // Dark theme
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          fillColor: Color(0xFF1E1E2A),
        ),
      ),

      // ← Keep your existing initialRoute
      // initialRoute: '/login',

      // ← UPDATE: Add new routes (keep your existing ones)
      routes: {
        // Your existing routes:
        // '/login': (_) => const LoginScreen(),
        // '/signup': (_) => const SignupScreen(),
        // '/home': (_) => const HomeScreen(),

        // New feature routes:
      
  "/hba1c": (_) => const Hba1cCalculatorScreen(),

        '/reminders': (_) => const ReminderScreen(),
        '/add-previous': (_) => const AddPreviousEntryScreen(),
        '/graph': (_) => const SugarGraphScreen(),
        '/report': (_) => const DoctorReportScreen(),
        '/insulin': (_) => const InsulinLogScreen(),
        '/prediction': (_) => const SugarPredictionScreen(),
        '/food': (_) => const FoodWarningScreen(),
        '/score': (_) => const StabilityScoreScreen(),
        //'/doctor': (_) => const TalkToDoctorScreen(),
        '/settings': (_) => const SettingsScreen(),
      },

      // ← Keep your home screen
      home: const DashboardScreen(), // Replace with your actual home screen
    );
  }
}

// ────────────────────────────────────────────────────────────────────
// DEMO HOME — Replace this with your actual HomeScreen
// This just shows all features in a menu for testing
// ────────────────────────────────────────────────────────────────────
class _FeatureDemoHome extends StatelessWidget {
  const _FeatureDemoHome();

  @override
  Widget build(BuildContext context) {
    final features = [
      ('🔔 Reminders', '/reminders', Colors.orange),
      ('🕒 Add Previous Entry', '/add-previous', Colors.teal),
      ('📊 Sugar Graph', '/graph', Colors.blue),
      ('📄 Doctor Report', '/report', Colors.indigo),
      ('💉 Insulin Log', '/insulin', Colors.purple),
      ('🧠 Sugar Prediction', '/prediction', Colors.deepPurple),
      ('🍽️ Food Warning', '/food', Colors.green),
      ('📈 Stability Score', '/score', Colors.deepOrange),
      ('🎥 Talk to Doctor', '/doctor', Colors.red),
      ('⚙️ Settings', '/settings', Colors.blueGrey),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('🩺 Diabetes App'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        itemCount: features.length,
        itemBuilder: (context, i) {
          final (label, route, color) = features[i];
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, route),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
