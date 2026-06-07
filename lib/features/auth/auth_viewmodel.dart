import 'package:flutter/foundation.dart';
import '../../repositories/auth_repository.dart';
import '../../models/models.dart';
import '../../core/services/notification_service.dart';

/// ViewModel shared by [LoginScreen] and [RoleSelectionScreen].
///
/// Exposes loading state, error messages, and the current user
/// so screens remain stateless and testable.
class AuthViewModel extends ChangeNotifier {
  AuthViewModel({required AuthRepository authRepository})
      : _repo = authRepository;

  final AuthRepository _repo;

  bool _isLoading = false;
  String? _errorMessage;
  AppUser? _currentUser;

  bool get isLoading    => _isLoading;
  String? get errorMessage => _errorMessage;
  AppUser? get currentUser => _currentUser;

  void initialize() {
    _repo.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  String get playerId   => _currentUser?.uid  ?? 'player_001';
  String get playerName => _currentUser?.name ?? 'Player';

  Stream<AppUser?> get authStateChanges => _repo.authStateChanges;

  // ── Sign in ───────────────────────────────────────────────────────────

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      _currentUser = await _repo.signIn(email: email, password: password);
      await NotificationService.instance.attachToUser(_currentUser!.uid);
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Register ──────────────────────────────────────────────────────────

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      _currentUser = await _repo.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      await NotificationService.instance.attachToUser(_currentUser!.uid);
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Sign out ──────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _repo.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // ── Password reset ────────────────────────────────────────────────────

  Future<void> sendPasswordReset(String email) async {
    _setLoading(true);
    _clearError();
    try {
      await _repo.sendPasswordReset(email);
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void clearError() => _clearError();

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() => _errorMessage = null;
}
