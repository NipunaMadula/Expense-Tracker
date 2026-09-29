import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/expense_repository.dart';
import 'data/repositories/firestore_expense_repository.dart';
import 'data/repositories/local_expense_repository.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/theme_provider.dart';
import 'ui/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();

  bool isFirebaseInitialized = false;

  // Graceful Firebase Initialization
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    isFirebaseInitialized = true;
    developer.log('Firebase initialized successfully.');
  } catch (e, stack) {
    developer.log(
      'Firebase initialization error: $e. Falling back to Local Repository.',
      error: e,
      stackTrace: stack,
    );
    isFirebaseInitialized = false;
  }

  // Set up Repositories
  final ExpenseRepository localRepo = LocalExpenseRepository(preferences: preferences);
  final ExpenseRepository? firestoreRepo = isFirebaseInitialized
      ? FirestoreExpenseRepository()
      : null;

  final AuthRepository authRepo = isFirebaseInitialized
      ? FirebaseAuthRepository()
      : LocalAuthRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(preferences: preferences),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository: authRepo),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ExpenseProvider>(
          create: (context) => ExpenseProvider(
            initialRepository: isFirebaseInitialized && firestoreRepo != null
                ? firestoreRepo
                : localRepo,
            secondaryRepository: firestoreRepo ?? localRepo,
            isUsingFirestore: isFirebaseInitialized,
            userId: context.read<AuthProvider>().user?.id,
          ),
          update: (_, authProvider, expenseProvider) {
            expenseProvider!.setUserId(authProvider.user?.id);
            return expenseProvider;
          },
        ),
      ],
      child: const CyphExpenseApp(),
    ),
  );
}

class CyphExpenseApp extends StatelessWidget {
  const CyphExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const SplashScreen(),
    );
  }
}
