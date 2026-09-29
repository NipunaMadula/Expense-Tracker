import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required AuthRepository authRepository})
      : _authRepository = authRepository {
    _init();
  }

  final AuthRepository _authRepository;
  StreamSubscription<AppUser?>? _subscription;

  AppUser? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isAnonymous => _user?.isAnonymous ?? true;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _init() {
    _user = _authRepository.currentUser;
    _subscription = _authRepository.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signInAnonymously() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authRepository.signInAnonymously();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _cleanErrorMessage(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authRepository.signInWithEmail(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _cleanErrorMessage(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUpWithEmail(String email, String password, {String? displayName}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authRepository.signUpWithEmail(email, password, displayName: displayName);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _cleanErrorMessage(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e.toString());
      notifyListeners();
    }
  }

  String _cleanErrorMessage(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('configuration_not_found')) {
      return 'Email sign-up is not enabled in Firebase. Enable Email/Password in Firebase Console under Authentication > Sign-in method, then rebuild the app.';
    }
    if (lower.contains('user-not-found') || lower.contains('no user record')) {
      return 'No account found with this email. Please check your email or create an account.';
    }
    if (lower.contains('wrong-password') || lower.contains('invalid-credential') || lower.contains('invalid password')) {
      return 'Incorrect email or password. Please verify and try again.';
    }
    if (lower.contains('email-already-in-use') || lower.contains('email already exists')) {
      return 'An account with this email already exists. Please sign in instead.';
    }
    if (lower.contains('weak-password') || lower.contains('password should be at least')) {
      return 'Password is too weak. Please use at least 6 characters with mixed letters & numbers.';
    }
    if (lower.contains('invalid-email')) {
      return 'The email format is invalid. Please check and try again.';
    }
    if (lower.contains('network-request-failed') || lower.contains('network error') || lower.contains('socketexception')) {
      return 'Network connection issue. Please check your internet connection.';
    }
    if (lower.contains('too-many-requests')) {
      return 'Too many unsuccessful attempts. Access temporarily blocked for security. Try again shortly.';
    }
    if (lower.contains('user-disabled')) {
      return 'This account has been disabled. Please contact customer support.';
    }

    if (raw.contains('] ')) {
      return raw.split('] ').last.trim();
    }
    return raw.replaceAll('Exception: ', '').trim();
  }
}
