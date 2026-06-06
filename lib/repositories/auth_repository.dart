import '../models/models.dart';

/// Exception thrown by [AuthRepository] implementations for known auth errors.
/// Screens catch this to display user-friendly messages.
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => 'AuthException: $message';
}

/// Abstract contract for authentication operations.
///
/// [FirebaseAuthRepository] is the real implementation.
/// Tests may provide a mock without depending on Firebase.
abstract class AuthRepository {
  /// Stream that emits the current [AppUser] when signed in,
  /// or null when signed out. Backed by FirebaseAuth.authStateChanges().
  Stream<AppUser?> get authStateChanges;

  /// Sign in with email and password.
  /// Throws [AuthException] on failure.
  Future<AppUser> signIn({
    required String email,
    required String password,
  });

  /// Register a new account and write the user doc to Firestore.
  /// Throws [AuthException] on failure.
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required String role,
  });

  /// Sign out the current user.
  Future<void> signOut();

  /// Send a password-reset email.
  /// Throws [AuthException] if the email is not registered.
  Future<void> sendPasswordReset(String email);
}
