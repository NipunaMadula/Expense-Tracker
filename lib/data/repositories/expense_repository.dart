import '../models/expense_model.dart';

abstract class ExpenseRepository {
  /// Stream of all expenses, sorted by date descending
  Stream<List<ExpenseModel>> watchExpenses({String? userId});

  /// Fetch expenses as a single future
  Future<List<ExpenseModel>> getExpenses({String? userId});

  /// Add a new expense
  Future<void> addExpense(ExpenseModel expense);

  /// Update an existing expense
  Future<void> updateExpense(ExpenseModel expense);

  /// Delete an expense by ID
  Future<void> deleteExpense(String id, {String? userId});

}
