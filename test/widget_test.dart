import 'package:expense_tracker/data/repositories/auth_repository.dart';
import 'package:expense_tracker/data/repositories/local_expense_repository.dart';
import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('CyphExpenseApp smoke test and navigation tabs verification', (WidgetTester tester) async {
    final localRepo = LocalExpenseRepository();
    final authRepo = LocalAuthRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider(authRepository: authRepo)),
          ChangeNotifierProvider(
            create: (_) => ExpenseProvider(initialRepository: localRepo),
          ),
        ],
        child: const CyphExpenseApp(),
      ),
    );

    // Wait for the splash screen and initial streams to settle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    // Verify NavigationBar exists
    expect(find.byType(NavigationBar), findsOneWidget);

    // Verify Navigation Destination labels
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Expenses'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Verify FloatingActionButton exists on dashboard
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
