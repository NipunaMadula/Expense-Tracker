import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/expense_category.dart';
import '../data/models/expense_model.dart';
import '../data/repositories/expense_repository.dart';

enum ExpenseSortOption {
  dateDesc('Newest First'),
  dateAsc('Oldest First'),
  amountDesc('Highest Amount'),
  amountAsc('Lowest Amount');

  const ExpenseSortOption(this.label);
  final String label;
}

enum ExpensePeriodFilter {
  thisMonth('This Month'),
  lastMonth('Last Month'),
  threeMonths('3 Months'),
  thisYear('This Year'),
  all('All');

  const ExpensePeriodFilter(this.label);
  final String label;
}

class ExpenseProvider extends ChangeNotifier {
  ExpenseProvider({
    required ExpenseRepository initialRepository,
    ExpenseRepository? secondaryRepository,
    bool isUsingFirestore = false,
    String? userId,
  })  : _currentRepository = initialRepository,
        _secondaryRepository = secondaryRepository,
        _isUsingFirestore = isUsingFirestore,
        _userId = userId {
    _initStream();
  }

  ExpenseRepository _currentRepository;
  final ExpenseRepository? _secondaryRepository;
  bool _isUsingFirestore;
  String? _userId;

  StreamSubscription<List<ExpenseModel>>? _subscription;
  List<ExpenseModel> _allExpenses = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filters & State
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  ExpensePeriodFilter _periodFilter = ExpensePeriodFilter.thisMonth;
  ExpenseCategory? _selectedCategory;
  DateTimeRange? _selectedDateRange;
  String _searchQuery = '';
  ExpenseSortOption _sortOption = ExpenseSortOption.dateDesc;

  // Undo support
  ExpenseModel? _lastDeletedExpense;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isUsingFirestore => _isUsingFirestore;
  DateTime get selectedMonth => _selectedMonth;
  ExpensePeriodFilter get periodFilter => _periodFilter;
  ExpenseCategory? get selectedCategory => _selectedCategory;
  DateTimeRange? get selectedDateRange => _selectedDateRange;
  String get searchQuery => _searchQuery;
  ExpenseSortOption get sortOption => _sortOption;
  List<ExpenseModel> get allExpenses => List.unmodifiable(_allExpenses);
  ExpenseModel? get lastDeletedExpense => _lastDeletedExpense;

  void setUserId(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    if (_isUsingFirestore) {
      _initStream();
    }
  }

  void _initStream() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _currentRepository.watchExpenses(userId: _userId).listen(
      (expenses) {
        _allExpenses = expenses;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = 'Failed to load expenses: $error';
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  /// Switch between Firestore and Local repositories
  Future<void> switchRepository({required bool useFirestore}) async {
    if (_isUsingFirestore == useFirestore) return;
    if (_secondaryRepository == null) return;

    _isUsingFirestore = useFirestore;
    _currentRepository = _secondaryRepository;
    _initStream();
  }

  // --- Filter and Search Setters ---

  void setSelectedMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
    notifyListeners();
  }

  void previousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    notifyListeners();
  }

  void nextMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    notifyListeners();
  }

  void resetToCurrentMonth() {
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
    _selectedDateRange = null;
    _selectedCategory = null;
    _searchQuery = '';
    notifyListeners();
  }

  void setSelectedCategory(ExpenseCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setDateRange(DateTimeRange? range) {
    _selectedDateRange = range;
    notifyListeners();
  }

  void setPeriodFilter(ExpensePeriodFilter filter) {
    _periodFilter = filter;
    _selectedDateRange = null; // Custom range gets cleared when selecting a preset period
    notifyListeners();
  }

  void clearDateRange() {
    _selectedDateRange = null;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    notifyListeners();
  }

  void setSortOption(ExpenseSortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  void clearAllFilters() {
    _selectedCategory = null;
    _selectedDateRange = null;
    _periodFilter = ExpensePeriodFilter.thisMonth;
    _searchQuery = '';
    notifyListeners();
  }

  // --- Filtered and Processed Lists ---

  /// Expenses strictly for the selected month
  List<ExpenseModel> get selectedMonthExpenses {
    return _allExpenses.where((exp) {
      return exp.date.year == _selectedMonth.year &&
          exp.date.month == _selectedMonth.month;
    }).toList();
  }

  /// Filtered expenses based on all active criteria
  List<ExpenseModel> get filteredExpenses {
    final list = _allExpenses.where((exp) {
      // 1. Date Range Filter OR Period Filter
      if (_selectedDateRange != null) {
        final start = DateTime(
          _selectedDateRange!.start.year,
          _selectedDateRange!.start.month,
          _selectedDateRange!.start.day,
        );
        final end = DateTime(
          _selectedDateRange!.end.year,
          _selectedDateRange!.end.month,
          _selectedDateRange!.end.day,
          23,
          59,
          59,
        );
        if (exp.date.isBefore(start) || exp.date.isAfter(end)) {
          return false;
        }
      } else {
        final now = DateTime.now();
        switch (_periodFilter) {
          case ExpensePeriodFilter.thisMonth:
            if (exp.date.year != _selectedMonth.year ||
                exp.date.month != _selectedMonth.month) {
              return false;
            }
            break;
          case ExpensePeriodFilter.lastMonth:
            final lastMonth = DateTime(now.year, now.month - 1);
            if (exp.date.year != lastMonth.year || exp.date.month != lastMonth.month) {
              return false;
            }
            break;
          case ExpensePeriodFilter.threeMonths:
            final threeMonthsAgo = DateTime(now.year, now.month - 2, 1);
            if (exp.date.isBefore(threeMonthsAgo)) {
              return false;
            }
            break;
          case ExpensePeriodFilter.thisYear:
            if (exp.date.year != now.year) {
              return false;
            }
            break;
          case ExpensePeriodFilter.all:
            break;
        }
      }

      // 2. Category Filter
      if (_selectedCategory != null && exp.category != _selectedCategory) {
        return false;
      }

      // 3. Search Query Filter
      if (_searchQuery.isNotEmpty) {
        final titleMatch = exp.title.toLowerCase().contains(_searchQuery);
        final noteMatch = exp.note?.toLowerCase().contains(_searchQuery) ?? false;
        final amountMatch = exp.amount.toString().contains(_searchQuery);
        if (!titleMatch && !noteMatch && !amountMatch) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sorting
    switch (_sortOption) {
      case ExpenseSortOption.dateDesc:
        list.sort((a, b) => b.date.compareTo(a.date));
        break;
      case ExpenseSortOption.dateAsc:
        list.sort((a, b) => a.date.compareTo(b.date));
        break;
      case ExpenseSortOption.amountDesc:
        list.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case ExpenseSortOption.amountAsc:
        list.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }

    return list;
  }

  // --- Financial Computations & Analytics ---

  /// Total expenses for the selected month
  double get totalSelectedMonthExpenses {
    return selectedMonthExpenses.fold(
      0.0,
      (sum, item) => sum + item.amount,
    );
  }

  /// Total expenses for the previous month (for comparison)
  double get totalPreviousMonthExpenses {
    final prevMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    return _allExpenses.where((exp) {
      return exp.date.year == prevMonth.year && exp.date.month == prevMonth.month;
    }).fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Percentage difference compared to last month
  double get monthOverMonthPercentage {
    final prevTotal = totalPreviousMonthExpenses;
    if (prevTotal <= 0) return 0.0;
    final currentTotal = totalSelectedMonthExpenses;
    return ((currentTotal - prevTotal) / prevTotal) * 100;
  }

  /// Average daily expense for the selected month
  double get averageDailyExpenseForMonth {
    final now = DateTime.now();
    final isCurrentMonth = _selectedMonth.year == now.year && _selectedMonth.month == now.month;
    final daysInPeriod = isCurrentMonth ? now.day : DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    if (daysInPeriod <= 0) return 0.0;
    return totalSelectedMonthExpenses / daysInPeriod;
  }

  /// Breakdown of spending per category for selected month
  Map<ExpenseCategory, double> get categorySpendingMap {
    final map = <ExpenseCategory, double>{};
    for (final exp in selectedMonthExpenses) {
      map[exp.category] = (map[exp.category] ?? 0.0) + exp.amount;
    }
    return map;
  }

  /// Category with highest expenditure in selected month
  ExpenseCategory? get topCategory {
    final map = categorySpendingMap;
    if (map.isEmpty) return null;
    ExpenseCategory? top;
    double max = -1;
    map.forEach((cat, amt) {
      if (amt > max) {
        max = amt;
        top = cat;
      }
    });
    return top;
  }

  /// Spending for last 6 months (for bar chart)
  Map<DateTime, double> get monthlySpendingTrends {
    final result = <DateTime, double>{};
    final now = DateTime.now();

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i);
      final total = _allExpenses.where((exp) {
        return exp.date.year == month.year && exp.date.month == month.month;
      }).fold(0.0, (sum, exp) => sum + exp.amount);
      result[month] = total;
    }

    return result;
  }

  // --- CRUD Operations ---

  Future<bool> addExpense(ExpenseModel expense) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final expenseForRepository = _isUsingFirestore
          ? expense.copyWith(userId: _userId)
          : expense;
      await _currentRepository.addExpense(expenseForRepository);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to add expense: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateExpense(ExpenseModel expense) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final expenseForRepository = _isUsingFirestore
          ? expense.copyWith(userId: _userId)
          : expense;
      await _currentRepository.updateExpense(expenseForRepository);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update expense: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteExpense(String id) async {
    _lastDeletedExpense = _allExpenses.firstWhere(
      (e) => e.id == id,
      orElse: () => _allExpenses.first,
    );

    try {
      await _currentRepository.deleteExpense(id, userId: _userId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete expense: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> undoDelete() async {
    if (_lastDeletedExpense == null) return false;
    final toRestore = _lastDeletedExpense!;
    _lastDeletedExpense = null;
    return addExpense(toRestore);
  }

  Future<void> refresh() async {
    _initStream();
  }
}
