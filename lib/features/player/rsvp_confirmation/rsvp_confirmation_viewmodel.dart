import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../models/models.dart';
import '../../../repositories/player_repository.dart';
import '../../../repositories/venue_repository.dart';

/// ViewModel for [RsvpConfirmationScreen].
///
/// Provides:
///   - Current player's RSVP status for the session
///   - Live stream of confirmed RSVPs (for participant list)
///   - Confirm / decline / waitlist actions
///   - Consequence visibility data (remaining spots, underpay risk)
class RsvpConfirmationViewModel extends ChangeNotifier {
  RsvpConfirmationViewModel({
    required PlayerRepository repository,
    required VenueRepository venueRepository,
    required Session session,
    required String playerId,
    required String playerName,
  })  : _repo = repository,
        _venueRepo = venueRepository,
        _session = session,
        _playerId = playerId,
        _playerName = playerName {
    _init();
  }

  final PlayerRepository _repo;
  final VenueRepository _venueRepo;
  final Session _session;
  final String _playerId;
  final String _playerName;

  Session get session => _session;

  String? _venueImageUrl;
  String? get venueImageUrl => _venueImageUrl;

  List<Rsvp> _confirmedRsvps = [];

  // FIX: _currentStatus tracks the local UI state only.
  // 'waiting' is a local-only value — it is never written to Firestore as an
  // Rsvp status. Waitlist entries live in a separate waitlist collection.
  // Valid Firestore values: 'confirmed' | 'pending' | 'declined'.
  String? _currentStatus;

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  StreamSubscription<List<Rsvp>>? _rsvpsSub;

  List<Rsvp> get confirmedRsvps => _confirmedRsvps;
  String? get currentStatus => _currentStatus;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  int get goingCount => _session.rsvpCount;
  int get maybeCount => 0; // Schema tracks confirmed/pending/declined only
  int get outCount => 0;

  bool get isFull => _session.isFull;

  /// Whether declining would leave the session underpaid.
  ///
  /// Uses _session.rsvpCount, which is populated from the constructor-time
  /// snapshot. This is acceptable for the underpay warning — a slight staleness
  /// is fine; the organizer's RSVP tracker is the source of truth.
  /// NOTE: rsvpCount is read-only on the client; it is maintained by a
  /// Cloud Function. Do not write to it from player screens.
  bool get wouldCauseUnderpay {
    if (_currentStatus != 'confirmed') return false;
    final remaining = _session.rsvpCount - 1;
    // Flag if leaving would drop below 60% of max players.
    return remaining < (_session.maxPlayers * 0.6).ceil();
  }

  /// Remaining spots available.
  int get spotsRemaining => (_session.maxPlayers - _session.rsvpCount)
      .clamp(0, _session.maxPlayers);

  void _init() {
    _isLoading = true;
    _loadCurrentRsvp();
    _loadVenueImage();
    _rsvpsSub = _repo
        .watchSessionRsvps(_session.sessionId)
        .listen(_onRsvpsUpdate, onError: _onError);
  }

  Future<void> _loadVenueImage() async {
    try {
      final venue = await _venueRepo.getVenueById(_session.venueId);
      _venueImageUrl = venue?['imageUrl'] as String?;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _loadCurrentRsvp() async {
    try {
      final rsvp = await _repo.getPlayerRsvp(
        sessionId: _session.sessionId,
        playerId: _playerId,
      );
      _currentStatus = rsvp?.status;
    } catch (_) {
      _errorMessage = 'Could not load your RSVP status.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _onRsvpsUpdate(List<Rsvp> rsvps) {
    _confirmedRsvps = rsvps;
    notifyListeners();
  }

  void _onError(Object error) {
    _errorMessage = 'Failed to load participant list.';
    notifyListeners();
  }

  Future<void> confirmAttendance() async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    _clearMessages();
    notifyListeners();

    try {
      await _repo.upsertRsvp(
        sessionId: _session.sessionId,
        playerId: _playerId,
        playerName: _playerName,
        status: 'confirmed',
      );
      _currentStatus = 'confirmed';
      _successMessage = "You're going! See you on the court.";
    } catch (_) {
      _errorMessage = 'Could not confirm. Please try again.';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> markMaybe() async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    _clearMessages();
    notifyListeners();

    try {
      await _repo.upsertRsvp(
        sessionId: _session.sessionId,
        playerId: _playerId,
        playerName: _playerName,
        status: 'pending',
      );
      _currentStatus = 'pending';
    } catch (_) {
      _errorMessage = 'Could not update. Please try again.';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> declineAttendance() async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    _clearMessages();
    notifyListeners();

    try {
      await _repo.upsertRsvp(
        sessionId: _session.sessionId,
        playerId: _playerId,
        playerName: _playerName,
        status: 'declined',
        declineReason: 'self',
      );
      _currentStatus = 'declined';
    } catch (_) {
      _errorMessage = 'Could not decline. Please try again.';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> joinWaitlist() async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    _clearMessages();
    notifyListeners();

    try {
      await _repo.joinWaitlist(
        sessionId: _session.sessionId,
        playerId: _playerId,
        playerName: _playerName,
      );
      // 'waiting' is LOCAL UI STATE ONLY — never written to Firestore.
      // Waitlist entries live in a separate waitlist/{sessionId}/entries collection.
      _currentStatus = 'waiting';
      _successMessage = "You're on the waitlist. We'll notify you if a spot opens.";
    } catch (_) {
      _errorMessage = 'Could not join waitlist. Please try again.';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void clearError() => _clearMessages();

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  @override
  void dispose() {
    _rsvpsSub?.cancel();
    super.dispose();
  }
}
