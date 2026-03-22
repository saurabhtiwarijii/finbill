/// FinBill — App entry point.
///
/// Sets up the [MaterialApp.router] with GoRouter and initialises
/// Firebase before the app starts.
///
/// File location: lib/main.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/routing/app_router.dart';
import 'services/firebase_service.dart';
import 'services/app_state_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Firebase.
  await Firebase.initializeApp();

  // Check if the mandatory owner profile is complete.
  // Note: Since this is an offline-first SME tool, we attempt a quick pull.
  // If the owner has filled out their profile, `ownerName` will exist.
  try {
    final settings = await FirebaseService.instance.getAccountSettings();
    final hasName = settings != null && 
                    settings['ownerName'] != null && 
                    settings['ownerName'].toString().trim().isNotEmpty;
    
    AppStateService.instance.setProfileComplete(hasName);
  } catch (e) {
    debugPrint('Failed to fetch initial profile state: $e');
  }

  // Lock orientation to portrait for a consistent mobile experience.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set status bar style.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const FinBillApp());
}

/// Root widget of the FinBill application.
///
/// Uses [MaterialApp.router] instead of [MaterialApp] so that GoRouter
/// controls the entire navigation stack, including deep-link resolution
/// and the browser URL bar (useful during web/debug testing).
class FinBillApp extends StatelessWidget {
  const FinBillApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // GoRouter provides its own routerConfig that includes
      // routeInformationParser, routeInformationProvider, and
      // routerDelegate — all wired up automatically.
      routerConfig: AppRouter.router,
    );
  }
}
