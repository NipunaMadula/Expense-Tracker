import 'package:expense_tracker/data/models/expense_category.dart';
import 'package:expense_tracker/data/models/expense_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpenseModel Tests', () {
    final testDate = DateTime(2026, 9, 28, 14, 30);
    final expense = ExpenseModel(
      id: 'test_123',
      title: 'Coffee and Croissant',
      amount: 8.50,
      category: ExpenseCategory.food,
      date: testDate,
      note: 'Morning bakery stop',
      userId: 'user_xyz',
    );

    test('should properly serialize toMap and deserialize fromMap', () {
      final map = expense.toMap();
      expect(map['id'], 'test_123');
      expect(map['title'], 'Coffee and Croissant');
      expect(map['amount'], 8.50);
      expect(map['category'], 'food');
      expect(map['note'], 'Morning bakery stop');

      final reconstructed = ExpenseModel.fromMap(map);
      expect(reconstructed.id, expense.id);
      expect(reconstructed.title, expense.title);
      expect(reconstructed.amount, expense.amount);
      expect(reconstructed.category, ExpenseCategory.food);
      expect(reconstructed.date, testDate);
      expect(reconstructed.note, expense.note);
    });

    test('copyWith creates a new instance with updated properties', () {
      final updated = expense.copyWith(
        title: 'Lunch Bowl',
        amount: 14.99,
        category: ExpenseCategory.shopping,
      );

      expect(updated.id, expense.id);
      expect(updated.title, 'Lunch Bowl');
      expect(updated.amount, 14.99);
      expect(updated.category, ExpenseCategory.shopping);
      expect(updated.date, expense.date);
      expect(updated.note, expense.note);
    });

    test('value equality and hashCode behave correctly', () {
      final identicalExpense = ExpenseModel(
        id: 'test_123',
        title: 'Coffee and Croissant',
        amount: 8.50,
        category: ExpenseCategory.food,
        date: testDate,
        note: 'Morning bakery stop',
        userId: 'user_xyz',
      );

      expect(expense, equals(identicalExpense));
      expect(expense.hashCode, equals(identicalExpense.hashCode));
    });
  });

  group('ExpenseCategory Enum Tests', () {
    test('fromId correctly resolves categories', () {
      expect(ExpenseCategory.fromId('food'), ExpenseCategory.food);
      expect(ExpenseCategory.fromId('transportation'), ExpenseCategory.transportation);
      expect(ExpenseCategory.fromId('shopping'), ExpenseCategory.shopping);
      expect(ExpenseCategory.fromId('bills'), ExpenseCategory.bills);
      expect(ExpenseCategory.fromId('unknown_id'), ExpenseCategory.other);
      expect(ExpenseCategory.fromId(null), ExpenseCategory.other);
    });
  });
}
