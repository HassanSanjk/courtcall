import '../models/models.dart';

abstract class PlayerRepository {
  // ── Sessions ──────────────────────────────────────────────────────────────

  Stream<List<Session>> watchPlayerSessions(String playerId);

  Future<Session?> getSession(String sessionId);

  // ── RSVPs ─────────────────────────────────────────────────────────────────

  Future<Rsvp?> getPlayerRsvp({
    required String sessionId,
    required String playerId,
  });

  /// Create or update the player's RSVP.
  ///
  /// [status]  : 'confirmed' | 'pending' | 'declined'
  /// [amount]  : session costPerPlayer — used to create the payment doc when
  ///             the player first confirms. Pass 0.0 for non-confirm updates.
  Future<void> upsertRsvp({
    required String sessionId,
    required String playerId,
    required String playerName,
    required String status,
    String? declineReason,
    double amount,
  });

  /// Streams ALL RSVPs for a session (confirmed + pending + declined).
  /// Use this to compute going / maybe / out tallies.
  Stream<List<Rsvp>> watchSessionRsvps(String sessionId);

  Future<List<String>> getConfirmedPlayerNames(String sessionId);

  // ── Waitlist ──────────────────────────────────────────────────────────────

  Future<void> joinWaitlist({
    required String sessionId,
    required String playerId,
    required String playerName,
  });

  // ── Payments ──────────────────────────────────────────────────────────────

  Stream<List<Payment>> watchPlayerPayments(String playerId);

  Future<void> markPaid({
    required String paymentId,
    required String transactionRef,
  });
}
