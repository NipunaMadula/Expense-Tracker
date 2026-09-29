import 'package:expense_tracker/data/models/expense_category.dart';
import 'package:expense_tracker/data/models/expense_model.dart';
import 'package:expense_tracker/data/repositories/local_expense_repository.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpenseProvider ViewModel Tests', () {
    late LocalExpenseRepository repository;
    late ExpenseProvider provider;

    setUp(() async {
      repository = LocalExpenseRepository();
      provider = ExpenseProvider(initialRepository: repository);
      // Allow stream to emit initial data
      await Future.delayed(const Duration(milliseconds: 50));
    });

    tearDown(() {
      provider.dispose();
    });

    test('loads expenses and calculates total for selected month', () {
      expect(provider.isLoading, false);
      expect(provider.allExpenses.isNotEmpty, true);
      expect(provider.totalSelectedMonthExpenses >= 0, true);
    });

    test('filters expenses by search query accurately', () {
      final initialTotal = provider.filteredExpenses.length;
      provider.setSearchQuery('Grocery');

      expect(provider.filteredExpenses.length, lessThanOrEqualTo(initialTotal));
      for (final exp in provider.filteredExpenses) {
        final matches = exp.title.toLowerCase().contains('grocery') ||
            (exp.note?.toLowerCase().contains('grocery') ?? false);
        expect(matches, true);
      }
    });

    test('filters expenses by category accurately', () {
      provider.setSelectedCategory(ExpenseCategory.food);
      for (final exp in provider.filteredExpenses) {
        expect(exp.category, ExpenseCategory.food);
      }
    });

    test('adds an expense and updates state', () async {
      final countBefore = provider.allExpenses.length;
      final expense = ExpenseModel(
        id: 'test_add_id',
        title: 'Sushi Dinner',
        amount: 45.0,
        category: ExpenseCategory.food,
        date: DateTime.now(),
      );

      final success = await provider.addExpense(expense);
      expect(success, true);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(provider.allExpenses.length, countBefore + 1);
    });

    test('deletes an expense and supports undo', () async {
      final target = provider.allExpenses.first;
      final success = await provider.deleteExpense(target.id);
      expect(success, true);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(provider.allExpenses.any((e) => e.id == target.id), false);
      expect(provider.lastDeletedExpense?.id, target.id);

      // Undo delete
      final undoSuccess = await provider.undoDelete();
      expect(undoSuccess, true);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(provider.allExpenses.any((e) => e.id == target.id), true);
    });
  });
}
