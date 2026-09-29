import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider({SharedPreferences? preferences}) : _preferences = preferences {
    _loadPreferences();
  }

  final SharedPreferences? _preferences;
  ThemeMode _themeMode = ThemeMode.system;
  String _currencySymbol = AppConstants.defaultCurrency;
  double _monthlyBudget = AppConstants.defaultMonthlyBudget;

  ThemeMode get themeMode => _themeMode;
  String get currencySymbol => _currencySymbol;
  double get monthlyBudget => _monthlyBudget;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  }

  void _loadPreferences() {
    if (_preferences == null) return;
    
    // Load theme
    final themeIndex = _preferences.getInt(AppConstants.keyThemeMode);
    if (themeIndex != null && themeIndex >= 0 && themeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[themeIndex];
    }

    // Load currency
    final savedCurrency = _preferences.getString(AppConstants.keyCurrencySymbol);
    if (savedCurrency != null && savedCurrency.isNotEmpty) {
      _currencySymbol = savedCurrency;
    }

    // Load budget
    final savedBudget = _preferences.getDouble(AppConstants.keyMonthlyBudget);
    if (savedBudget != null && savedBudget > 0) {
      _monthlyBudget = savedBudget;
    }

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    if (_preferences != null) {
      await _preferences.setInt(AppConstants.keyThemeMode, mode.index);
    }
  }

  Future<void> toggleTheme() async {
    final nextMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(nextMode);
  }

  Future<void> setCurrencySymbol(String symbol) async {
    if (_currencySymbol == symbol) return;
    _currencySymbol = symbol;
    notifyListeners();
    if (_preferences != null) {
      await _preferences.setString(AppConstants.keyCurrencySymbol, symbol);
    }
  }

  Future<void> setMonthlyBudget(double budget) async {
    if (_monthlyBudget == budget || budget <= 0) return;
    _monthlyBudget = budget;
    notifyListeners();
    if (_preferences != null) {
      await _preferences.setDouble(AppConstants.keyMonthlyBudget, budget);
    }
  }
}
