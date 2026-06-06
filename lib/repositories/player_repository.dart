import '../models/models.dart';

/// Abstract contract for all Player-role data operations.
abstract class PlayerRepository {
  // ── Sessions ─────────────────────────────────────────────────────────

  /// Stream of upcoming sessions the player has been invited to
  /// or has already responded to.
  Stream<List<Session>> watchPlayerSessions(String playerId);

  /// Fetch a single session by ID.
  Future<Session?> getSession(String sessionId);

  // ── RSVPs ─────────────────────────────────────────────────────────────

  /// Fetch the current player's RSVP for a given session.
  /// Returns null if no RSVP doc exists yet.
  Future<Rsvp?> getPlayerRsvp({
    required String sessionId,
    required String playerId,
  });

  /// Create or update the player's RSVP.
  ///
  /// [status]        : 'confirmed' | 'pending' | 'declined'
  /// [declineReason] : 'self' | null  (only required when status == 'declined')
  ///
  /// NOTE: Never pass declineReason == 'removed' from the player flow.
  /// 'removed' is set only by the organizer.
  Future<void> upsertRsvp({
    required String sessionId,
    required String playerId,
    required String playerName,
    required String status,
    String? declineReason,
  });

  /// Stream of all confirmed RSVPs for a session — used to show the
  /// confirmed player list on the RSVP confirmation screen.
  Stream<List<Rsvp>> watchSessionRsvps(String sessionId);

  /// Returns the names of confirmed players for a session.
  ///
  /// Used to populate avatar rows on [SessionCard].
  /// The real Firebase implementation should query the confirmed RSVPs
  /// for the session and return their playerName values.
  Future<List<String>> getConfirmedPlayerNames(String sessionId);

  // ── Waitlist ──────────────────────────────────────────────────────────

  /// Add the player to the waitlist for a full session.
  /// Uses a Firestore transaction to assign position atomically.
  Future<void> joinWaitlist({
    required String sessionId,
    required String playerId,
    required String playerName,
  });

  // ── Payments ──────────────────────────────────────────────────────────

  /// Stream of all payments for the current player across all sessions.
  Stream<List<Payment>> watchPlayerPayments(String playerId);

  /// Mark a payment as paid.
  Future<void> markPaid({
    required String paymentId,
    required String transactionRef,
  });
}
