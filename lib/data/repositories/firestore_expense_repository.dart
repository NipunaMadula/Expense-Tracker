import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../models/expense_model.dart';
import 'expense_repository.dart';

class FirestoreExpenseRepository implements ExpenseRepository {
  FirestoreExpenseRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _getCollection({required String userId}) {
    if (userId.isEmpty) {
      throw StateError('A signed-in user is required to access Firestore expenses.');
    }
    return _firestore
        .collection(AppConstants.collectionUsers)
        .doc(userId)
        .collection(AppConstants.collectionExpenses);
  }

  @override
  Stream<List<ExpenseModel>> watchExpenses({String? userId}) {
    try {
      if (userId == null || userId.isEmpty) {
        return Stream.value(const <ExpenseModel>[]);
      }
      return _getCollection(userId: userId)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return ExpenseModel.fromFirestore(doc);
        }).toList();
      });
    } catch (e, stack) {
      developer.log('Error watching expenses from Firestore: $e', error: e, stackTrace: stack);
      rethrow;
    }
  }

  @override
  Future<List<ExpenseModel>> getExpenses({String? userId}) async {
    try {
      if (userId == null || userId.isEmpty) return [];
      final snapshot = await _getCollection(userId: userId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) => ExpenseModel.fromFirestore(doc)).toList();
    } catch (e, stack) {
      developer.log('Error getting expenses from Firestore: $e', error: e, stackTrace: stack);
      rethrow;
    }
  }

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    try {
      final userId = expense.userId;
      if (userId == null || userId.isEmpty) {
        throw StateError('A signed-in user is required to save an expense.');
      }
      final collection = _getCollection(userId: userId);
      if (expense.id.isNotEmpty) {
        await collection.doc(expense.id).set(expense.toFirestore());
      } else {
        await collection.add(expense.toFirestore());
      }
    } catch (e, stack) {
      developer.log('Error adding expense to Firestore: $e', error: e, stackTrace: stack);
      rethrow;
    }
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      if (expense.id.isEmpty) {
        throw ArgumentError('Cannot update expense without valid ID');
      }
      final userId = expense.userId;
      if (userId == null || userId.isEmpty) {
        throw StateError('A signed-in user is required to update an expense.');
      }
      await _getCollection(userId: userId)
          .doc(expense.id)
          .update(expense.toFirestore());
    } catch (e, stack) {
      developer.log('Error updating expense in Firestore: $e', error: e, stackTrace: stack);
      rethrow;
    }
  }

  @override
  Future<void> deleteExpense(String id, {String? userId}) async {
    try {
      if (userId == null || userId.isEmpty) {
        throw StateError('A signed-in user is required to delete an expense.');
      }
      await _getCollection(userId: userId).doc(id).delete();
    } catch (e, stack) {
      developer.log('Error deleting expense in Firestore: $e', error: e, stackTrace: stack);
      rethrow;
    }
  }

}
