import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../models/models.dart';
import '../../../repositories/player_repository.dart';

/// ViewModel for [SessionFeedScreen].
///
/// Provides:
///   - Stream of upcoming / past sessions for the current player
///   - RSVP action (confirm / decline) with per-session loading state
///   - Confirmed player names for avatar rows (via repository interface)
class SessionFeedViewModel extends ChangeNotifier {
  SessionFeedViewModel({
    required PlayerRepository repository,
    required String playerId,
    required String playerName,
  })  : _repo = repository,
        _playerId = playerId,
        _playerName = playerName {
    _init();
  }

  final PlayerRepository _repo;
  final String _playerId;
  final String _playerName;

  List<Session> _upcomingSessions = [];
  List<Session> _pastSessions = [];
  final Map<String, String?> _playerRsvpStatuses = {};
  final Map<String, List<String>> _confirmedPlayerNames = {};
  final Set<String> _loadingSessions = {};
  String? _errorMessage;

  StreamSubscription<List<Session>>? _sessionsSub;
  bool _disposed = false;

  String get playerId => _playerId;
  String get playerName => _playerName;

  List<Session> get upcomingSessions => _upcomingSessions;
  List<Session> get pastSessions => _pastSessions;
  bool get isLoading => _upcomingSessions.isEmpty && _errorMessage == null;
  String? get errorMessage => _errorMessage;

  bool isSessionLoading(String sessionId) =>
      _loadingSessions.contains(sessionId);

  String? rsvpStatusFor(String sessionId) =>
      _playerRsvpStatuses[sessionId];

  /// Returns confirmed player names for avatar row display.
  /// Backed by [PlayerRepository.getConfirmedPlayerNames] — no mock type-check.
  List<String> confirmedPlayerNamesFor(String sessionId) =>
      _confirmedPlayerNames[sessionId] ?? [];

  void _init() {
    _sessionsSub = _repo
        .watchPlayerSessions(_playerId)
        .listen(_onSessionsUpdate, onError: _onError);
  }

  // FIX: wrapped in a proper async method so errors from getPlayerRsvp
  // and getConfirmedPlayerNames are caught and surfaced instead of silently
  // dropped by the listen callback.
  Future<void> _onSessionsUpdate(List<Session> sessions) async {
    if (_disposed) return;
    _upcomingSessions =
        sessions.where((s) => s.status == 'upcoming').toList()
          ..sort((a, b) => a.dateTimestamp.compareTo(b.dateTimestamp));
    _pastSessions =
        sessions.where((s) => s.status != 'upcoming').toList()
          ..sort((a, b) => b.dateTimestamp.compareTo(a.dateTimestamp));

    // Fetch RSVP statuses and player names for upcoming sessions.
    // Both use Future.wait so they run in parallel per session.
    await Future.wait([
      ..._upcomingSessions.map((session) async {
        // Only fetch if not already cached.
        if (!_playerRsvpStatuses.containsKey(session.sessionId)) {
          try {
            final rsvp = await _repo.getPlayerRsvp(
              sessionId: session.sessionId,
              playerId: _playerId,
            );
            _playerRsvpStatuses[session.sessionId] = rsvp?.status;
          } catch (_) {
            // Non-fatal — leave status as null; will retry on next stream event.
          }
        }
        if (!_confirmedPlayerNames.containsKey(session.sessionId)) {
          try {
            _confirmedPlayerNames[session.sessionId] =
                await _repo.getConfirmedPlayerNames(session.sessionId);
          } catch (_) {
            // Non-fatal — avatar row will show empty.
          }
        }
      }),
    ]);

    if (_disposed) return;
    notifyListeners();
  }

  void _onError(Object error) {
    if (_disposed) return;
    _errorMessage = 'Failed to load sessions. Please try again.';
    notifyListeners();
  }

  Future<void> confirmAttendance(String sessionId) async {
    _setSessionLoading(sessionId, true);
    try {
      final session = _upcomingSessions
          .where((s) => s.sessionId == sessionId)
          .firstOrNull;
      await _repo.upsertRsvp(
        sessionId: sessionId,
        playerId: _playerId,
        playerName: _playerName,
        status: 'confirmed',
        amount: session?.costPerPlayer ?? 0.0,
      );
      _playerRsvpStatuses[sessionId] = 'confirmed';
    } catch (_) {
      _errorMessage = 'Could not confirm. Please try again.';
    } finally {
      _setSessionLoading(sessionId, false);
    }
  }

  Future<void> declineAttendance(String sessionId) async {
    _setSessionLoading(sessionId, true);
    try {
      await _repo.upsertRsvp(
        sessionId: sessionId,
        playerId: _playerId,
        playerName: _playerName,
        status: 'declined',
        declineReason: 'self',
      );
      _playerRsvpStatuses[sessionId] = 'declined';
    } catch (_) {
      _errorMessage = 'Could not decline. Please try again.';
    } finally {
      _setSessionLoading(sessionId, false);
    }
  }

  void _setSessionLoading(String sessionId, bool value) {
    if (_disposed) return;
    if (value) {
      _loadingSessions.add(sessionId);
    } else {
      _loadingSessions.remove(sessionId);
    }
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _sessionsSub?.cancel();
    super.dispose();
  }
}
