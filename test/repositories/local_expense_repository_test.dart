import 'package:expense_tracker/data/models/expense_category.dart';
import 'package:expense_tracker/data/models/expense_model.dart';
import 'package:expense_tracker/data/repositories/local_expense_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalExpenseRepository Tests', () {
    late LocalExpenseRepository repository;

    setUp(() {
      repository = LocalExpenseRepository();
    });

    test('initializes with sample data', () async {
      final expenses = await repository.getExpenses();
      expect(expenses.isNotEmpty, true);
    });

    test('adds a new expense successfully', () async {
      final initialCount = (await repository.getExpenses()).length;
      final newExpense = ExpenseModel(
        id: 'new_id_1',
        title: 'Book Purchase',
        amount: 25.0,
        category: ExpenseCategory.education,
        date: DateTime.now(),
      );

      await repository.addExpense(newExpense);
      final updated = await repository.getExpenses();
      expect(updated.length, initialCount + 1);
      expect(updated.any((e) => e.title == 'Book Purchase'), true);
    });

    test('updates an existing expense', () async {
      final expenses = await repository.getExpenses();
      final target = expenses.first;

      final modified = target.copyWith(title: 'Modified Title', amount: 99.99);
      await repository.updateExpense(modified);

      final updatedExpenses = await repository.getExpenses();
      final found = updatedExpenses.firstWhere((e) => e.id == target.id);
      expect(found.title, 'Modified Title');
      expect(found.amount, 99.99);
    });

    test('deletes an expense by ID', () async {
      final expenses = await repository.getExpenses();
      final target = expenses.first;

      await repository.deleteExpense(target.id);
      final afterDelete = await repository.getExpenses();
      expect(afterDelete.any((e) => e.id == target.id), false);
    });
  });
}
