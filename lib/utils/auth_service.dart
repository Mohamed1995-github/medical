import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user.dart';

class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  final _userController = StreamController<User?>.broadcast();

  Stream<User?> get userStream => _userController.stream;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<User> login(
      {required String phoneNumber, required String password}) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Basic validation
    if (phoneNumber.isEmpty || password.isEmpty) {
      throw AuthenticationException('Phone number and password are required');
    }

    // Simulated authentication logic
    // In a real app, this would be a network call to your backend
    if (phoneNumber == '1234567890' && password == 'password') {
      _currentUser = User(
          id: '1',
          name: 'John Doe',
          phoneNumber: phoneNumber,
          cniNumber: 'CNI12345');
      _userController.add(_currentUser);
      return _currentUser!;
    } else {
      throw AuthenticationException('Invalid phone number or password');
    }
  }

  Future<User> register(
      {required String name,
      required String phoneNumber,
      required String password,
      required String cniNumber}) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Basic validation
    if (name.isEmpty ||
        phoneNumber.isEmpty ||
        password.isEmpty ||
        cniNumber.isEmpty) {
      throw AuthenticationException('All fields are required');
    }

    // Simulated registration logic
    // In a real app, this would be a network call to your backend
    _currentUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        phoneNumber: phoneNumber,
        cniNumber: cniNumber);
    _userController.add(_currentUser);
    return _currentUser!;
  }

  Future<void> logout() async {
    _currentUser = null;
    _userController.add(null);
  }

  void dispose() {
    _userController.close();
  }
}
