import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoading = true;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get error => _error;

  AuthService() {
    _init();
  }

  void _init() async {
    _isLoading = true;
    notifyListeners();

    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> signInAnonymously() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await _auth.signInAnonymously();
    return true;
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return true;
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return true;
  }

  Future<void> signOut() async {
    await _auth.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
