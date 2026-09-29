import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/expense_category.dart';
import '../models/expense_model.dart';
import 'expense_repository.dart';

class LocalExpenseRepository implements ExpenseRepository {
  LocalExpenseRepository({SharedPreferences? preferences})
      : _preferences = preferences {
    _initData();
  }

  final SharedPreferences? _preferences;
  static const String _storageKey = 'local_expenses_storage';
  final _uuid = const Uuid();

  final List<ExpenseModel> _expenses = [];
  final StreamController<List<ExpenseModel>> _streamController =
      StreamController<List<ExpenseModel>>.broadcast();

  void _initData() {
    if (_preferences != null) {
      final jsonString = _preferences.getString(_storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        try {
          final List decoded = jsonDecode(jsonString) as List;
          _expenses.clear();
          _expenses.addAll(
            decoded.map((item) => ExpenseModel.fromMap(item as Map<String, dynamic>)),
          );
          _sortExpenses();
          _notify();
          return;
        } catch (_) {
          // Fallback to sample data on parse error
        }
      }
    }
    _loadSampleData();
  }

  void _loadSampleData() {
    final now = DateTime.now();
    final sampleExpenses = [
      ExpenseModel(
        id: _uuid.v4(),
        title: 'Weekly Grocery Store',
        amount: 86.50,
        category: ExpenseCategory.food,
        date: now.subtract(const Duration(days: 1)),
        note: 'Fresh fruits, vegetables, and almond milk',
      ),
      ExpenseModel(
        id: _uuid.v4(),
        title: 'Electric & Water Utility',
        amount: 124.30,
        category: ExpenseCategory.bills,
        date: now.subtract(const Duration(days: 3)),
        note: 'Monthly city utility bill',
      ),
      ExpenseModel(
        id: _uuid.v4(),
        title: 'Gasoline Station',
        amount: 45.00,
        category: ExpenseCategory.transportation,
        date: now.subtract(const Duration(days: 5)),
        note: 'Full tank refill',
      ),
      ExpenseModel(
        id: _uuid.v4(),
        title: 'Dinner with Colleagues',
        amount: 62.75,
        category: ExpenseCategory.food,
        date: now.subtract(const Duration(days: 7)),
        note: 'Italian pasta & beverages',
      ),
      ExpenseModel(
        id: _uuid.v4(),
        title: 'Movie Tickets & Snacks',
        amount: 32.50,
        category: ExpenseCategory.entertainment,
        date: now.subtract(const Duration(days: 10)),
        note: 'IMAX weekend screening',
      ),
      ExpenseModel(
        id: _uuid.v4(),
        title: 'New Running Shoes',
        amount: 110.00,
        category: ExpenseCategory.shopping,
        date: now.subtract(const Duration(days: 14)),
        note: 'Nike Pegasus workout gear',
      ),
      ExpenseModel(
        id: _uuid.v4(),
        title: 'Pharmacy Vitamins',
        amount: 28.90,
        category: ExpenseCategory.health,
        date: now.subtract(const Duration(days: 18)),
        note: 'Multivitamins & Omega-3',
      ),
      ExpenseModel(
        id: _uuid.v4(),
        title: 'Online Tech Course',
        amount: 49.99,
        category: ExpenseCategory.education,
        date: now.subtract(const Duration(days: 22)),
        note: 'Flutter & Dart Deep Dive Certification',
      ),
      // Last month expense for month-over-month comparison
      ExpenseModel(
        id: _uuid.v4(),
        title: 'Home WiFi Internet',
        amount: 60.00,
        category: ExpenseCategory.bills,
        date: DateTime(now.year, now.month - 1, 15),
        note: 'High-speed broadband',
      ),
      ExpenseModel(
        id: _uuid.v4(),
        title: 'Weekend Flight Ticket',
        amount: 215.00,
        category: ExpenseCategory.travel,
        date: DateTime(now.year, now.month - 1, 20),
        note: 'Short vacation trip',
      ),
    ];

    _expenses.clear();
    _expenses.addAll(sampleExpenses);
    _sortExpenses();
    _saveToPrefs();
    _notify();
  }

  void _sortExpenses() {
    _expenses.sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> _saveToPrefs() async {
    if (_preferences == null) return;
    final encoded = jsonEncode(_expenses.map((e) => e.toMap()).toList());
    await _preferences.setString(_storageKey, encoded);
  }

  void _notify() {
    _streamController.add(List.unmodifiable(_expenses));
  }

  @override
  Stream<List<ExpenseModel>> watchExpenses({String? userId}) async* {
    yield List.unmodifiable(_expenses);
    yield* _streamController.stream;
  }

  @override
  Future<List<ExpenseModel>> getExpenses({String? userId}) async {
    return List.unmodifiable(_expenses);
  }

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    final newExpense = expense.id.isEmpty
        ? expense.copyWith(id: _uuid.v4())
        : expense;
    _expenses.add(newExpense);
    _sortExpenses();
    await _saveToPrefs();
    _notify();
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      _sortExpenses();
      await _saveToPrefs();
      _notify();
    }
  }

  @override
  Future<void> deleteExpense(String id, {String? userId}) async {
    _expenses.removeWhere((e) => e.id == id);
    await _saveToPrefs();
    _notify();
  }

}
