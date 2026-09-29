import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  AppUser? get currentUser;
  Future<AppUser> signInAnonymously();
  Future<AppUser> signInWithEmail(String email, String password);
  Future<AppUser> signUpWithEmail(String email, String password, {String? displayName});
  Future<void> signOut();
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  @override
  Stream<AppUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(_mapFirebaseUser);
  }

  @override
  AppUser? get currentUser => _mapFirebaseUser(_firebaseAuth.currentUser);

  AppUser? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    return AppUser(
      id: user.uid,
      email: user.email ?? (user.isAnonymous ? 'guest@cyphlab.app' : ''),
      displayName: user.displayName ?? (user.isAnonymous ? 'Guest User' : user.email?.split('@').first),
      isAnonymous: user.isAnonymous,
    );
  }

  @override
  Future<AppUser> signInAnonymously() async {
    final credential = await _firebaseAuth.signInAnonymously();
    return _mapFirebaseUser(credential.user)!;
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return _mapFirebaseUser(credential.user)!;
  }

  @override
  Future<AppUser> signUpWithEmail(String email, String password, {String? displayName}) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    if (displayName != null && displayName.trim().isNotEmpty) {
      await credential.user?.updateDisplayName(displayName.trim());
      await credential.user?.reload();
    }
    return _mapFirebaseUser(_firebaseAuth.currentUser ?? credential.user)!;
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}

class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository() {
    // Start with anonymous guest user by default
    _currentUser = AppUser.anonymous('guest_user_local');
    _controller.add(_currentUser);
  }

  AppUser? _currentUser;
  final StreamController<AppUser?> _controller = StreamController<AppUser?>.broadcast();

  @override
  Stream<AppUser?> get authStateChanges async* {
    yield _currentUser;
    yield* _controller.stream;
  }

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Future<AppUser> signInAnonymously() async {
    _currentUser = AppUser.anonymous('guest_user_local');
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    _currentUser = AppUser(
      id: 'user_${email.hashCode.abs()}',
      email: email,
      displayName: email.split('@').first,
      isAnonymous: false,
    );
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<AppUser> signUpWithEmail(String email, String password, {String? displayName}) async {
    _currentUser = AppUser(
      id: 'user_${email.hashCode.abs()}',
      email: email,
      displayName: (displayName != null && displayName.trim().isNotEmpty)
          ? displayName.trim()
          : email.split('@').first,
      isAnonymous: false,
    );
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }
}
