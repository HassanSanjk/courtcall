import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../models/models.dart';
import '../../../repositories/player_repository.dart';
import '../../../repositories/venue_repository.dart';

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

  // All RSVPs for this session — confirmed + pending + declined.
  List<Rsvp> _allRsvps = [];

  String? _currentStatus;

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  StreamSubscription<List<Rsvp>>? _rsvpsSub;

  /// Only the confirmed attendees — used for the participant list.
  List<Rsvp> get confirmedRsvps =>
      _allRsvps.where((r) => r.isConfirmed).toList();

  String? get currentStatus => _currentStatus;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Real going count derived from live RSVP stream.
  int get goingCount => _allRsvps.where((r) => r.isConfirmed).length;

  /// Real maybe count derived from live RSVP stream.
  int get maybeCount => _allRsvps.where((r) => r.isPending).length;

  /// Real out count derived from live RSVP stream.
  int get outCount => _allRsvps.where((r) => r.isDeclined).length;

  bool get isFull => _session.isFull;

  bool get wouldCauseUnderpay {
    if (_currentStatus != 'confirmed') return false;
    final remaining = _session.rsvpCount - 1;
    return remaining < (_session.maxPlayers * 0.6).ceil();
  }

  int get spotsRemaining =>
      (_session.maxPlayers - _session.rsvpCount).clamp(0, _session.maxPlayers);

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
    _allRsvps = rsvps;
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
        amount: _session.costPerPlayer,
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
      _currentStatus = 'waiting';
      _successMessage =
          "You're on the waitlist. We'll notify you if a spot opens.";
    } catch (_) {
      _errorMessage = 'Could not join waitlist. Please try again.';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Clears only the error banner — leaves the success message visible.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

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
