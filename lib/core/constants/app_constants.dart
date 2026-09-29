class AppConstants {
  AppConstants._();

  static const String appName = 'CyphExpense';
  static const String appTagline = 'Smart & Elegant Expense Tracking';
  
  // Storage keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyCurrencySymbol = 'currency_symbol';
  static const String keyMonthlyBudget = 'monthly_budget';

  // Defaults
  static const String defaultCurrency = 'LKR';
  static const double defaultMonthlyBudget = 2500.0;

  // Firestore collections
  static const String collectionUsers = 'users';
  static const String collectionExpenses = 'expenses';

  // Validation rules
  static const int minTitleLength = 2;
  static const int maxTitleLength = 50;
  static const double minAmount = 0.01;
  static const double maxAmount = 10000000.0;
  static const int maxNoteLength = 250;
}
