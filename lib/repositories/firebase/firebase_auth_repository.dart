import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth_repository.dart';
import '../../models/models.dart';

/// Firebase implementation of [AuthRepository].
///
/// Uses [FirebaseAuth] for authentication and [FirebaseFirestore]
/// to persist / read user profile data (name, role, fcmToken).
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  // ── authStateChanges ──────────────────────────────────────────────────────

  @override
  Stream<AppUser?> get authStateChanges => _auth.authStateChanges().asyncMap(
        (user) async {
          if (user == null) return null;
          return _fetchUser(user.uid);
        },
      );

  // ── signIn ────────────────────────────────────────────────────────────────

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _fetchUser(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    }
  }

  // ── register ──────────────────────────────────────────────────────────────

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;

      // Write user profile to Firestore.
      await _db.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return AppUser(uid: uid, name: name, email: email, role: role);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    }
  }

  // ── signOut ───────────────────────────────────────────────────────────────

  @override
  Future<void> signOut() => _auth.signOut();

  // ── sendPasswordReset ─────────────────────────────────────────────────────

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<AppUser> _fetchUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    final data = doc.data() ?? {};
    return AppUser(
      uid: uid,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? _auth.currentUser?.email ?? '',
      role: data['role'] as String? ?? 'player',
    );
  }

  String _mapFirebaseError(String code) => switch (code) {
        'user-not-found'        => 'No account found for this email.',
        'wrong-password'        => 'Incorrect password. Please try again.',
        'invalid-email'         => 'Please enter a valid email address.',
        'email-already-in-use'  => 'An account with this email already exists.',
        'weak-password'         => 'Password must be at least 6 characters.',
        'too-many-requests'     => 'Too many attempts. Please try again later.',
        'network-request-failed'=> 'No internet connection.',
        _                       => 'Something went wrong. Please try again.',
      };
}
