// models.dart
// Central barrel for all data models used across CourtCall.
// Hassan owns the Firestore schema — these models must stay in sync
// with the collection/field names defined in schema v4.

// ── AppUser ───────────────────────────────────────────────────────────────────

/// Represents a signed-in user returned by [AuthRepository].
class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  final String uid;
  final String name;
  final String email;

  /// 'player' | 'organizer' | 'venue_owner'
  final String role;

  AppUser copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
  }) =>
      AppUser(
        uid: uid ?? this.uid,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role ?? this.role,
      );

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) => AppUser(
        uid: uid,
        name: map['name'] as String? ?? '',
        email: map['email'] as String? ?? '',
        role: map['role'] as String? ?? 'player',
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'role': role,
      };
}

// ── Session ───────────────────────────────────────────────────────────────────

/// Mirrors the Firestore `sessions/{sessionId}` document.
class Session {
  const Session({
    required this.sessionId,
    required this.organizerId,
    required this.venueId,
    required this.venueName,
    required this.court,
    required this.date,
    required this.dateTimestamp,
    required this.time,
    required this.maxPlayers,
    required this.rsvpCount,
    required this.costPerPlayer,
    required this.status,
    required this.createdAt,
    required this.sport,
  });

  final String sessionId;
  final String organizerId;
  final String venueId;
  final String venueName;
  final String court;

  /// Human-readable date string, e.g. "Friday, 9 May"
  final String date;

  /// Machine-readable timestamp for sorting.
  final DateTime dateTimestamp;

  /// Human-readable time range, e.g. "8:00PM–10:00PM"
  final String time;

  final int maxPlayers;

  /// Maintained by Cloud Function — do NOT write from client.
  final int rsvpCount;

  final double costPerPlayer;

  /// 'upcoming' | 'completed' | 'cancelled'
  final String status;

  final DateTime createdAt;

  /// 'futsal' | 'badminton' | 'basketball' | 'volleyball' | ...
  final String sport;

  bool get isFull => rsvpCount >= maxPlayers;
  bool get isUpcoming => status == 'upcoming';

  Session copyWith({
    String? sessionId,
    String? organizerId,
    String? venueId,
    String? venueName,
    String? court,
    String? date,
    DateTime? dateTimestamp,
    String? time,
    int? maxPlayers,
    int? rsvpCount,
    double? costPerPlayer,
    String? status,
    DateTime? createdAt,
    String? sport,
  }) =>
      Session(
        sessionId: sessionId ?? this.sessionId,
        organizerId: organizerId ?? this.organizerId,
        venueId: venueId ?? this.venueId,
        venueName: venueName ?? this.venueName,
        court: court ?? this.court,
        date: date ?? this.date,
        dateTimestamp: dateTimestamp ?? this.dateTimestamp,
        time: time ?? this.time,
        maxPlayers: maxPlayers ?? this.maxPlayers,
        rsvpCount: rsvpCount ?? this.rsvpCount,
        costPerPlayer: costPerPlayer ?? this.costPerPlayer,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        sport: sport ?? this.sport,
      );

  factory Session.fromMap(String id, Map<String, dynamic> map) => Session(
        sessionId: id,
        organizerId: map['organizerId'] as String? ?? '',
        venueId: map['venueId'] as String? ?? '',
        venueName: map['venueName'] as String? ?? '',
        court: map['court'] as String? ?? '',
        date: map['date'] as String? ?? '',
        dateTimestamp: map['dateTimestamp'] != null
            ? DateTime.parse(map['dateTimestamp'] as String)
            : DateTime.now(),
        time: map['time'] as String? ?? '',
        maxPlayers: map['maxPlayers'] as int? ?? 0,
        rsvpCount: map['rsvpCount'] as int? ?? 0,
        costPerPlayer: (map['costPerPlayer'] as num?)?.toDouble() ?? 0.0,
        status: map['status'] as String? ?? 'upcoming',
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'] as String)
            : DateTime.now(),
        sport: map['sport'] as String? ?? 'futsal',
      );

  Map<String, dynamic> toMap() => {
        'organizerId': organizerId,
        'venueId': venueId,
        'venueName': venueName,
        'court': court,
        'date': date,
        'dateTimestamp': dateTimestamp.toIso8601String(),
        'time': time,
        'maxPlayers': maxPlayers,
        'rsvpCount': rsvpCount,
        'costPerPlayer': costPerPlayer,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'sport': sport,
      };
}

// ── Rsvp ──────────────────────────────────────────────────────────────────────

/// Mirrors `sessions/{sessionId}/rsvps/{rsvpId}`.
class Rsvp {
  const Rsvp({
    required this.rsvpId,
    required this.sessionId,
    required this.playerId,
    required this.playerName,
    required this.status,
    this.declineReason,
    this.respondedAt,
  });

  final String rsvpId;
  final String sessionId;
  final String playerId;
  final String playerName;

  /// 'confirmed' | 'pending' | 'declined'
  /// NOTE: 'waiting' is LOCAL UI STATE ONLY — never stored in Firestore.
  final String status;

  /// 'self' — player cancelled themselves (triggers waitlist promotion)
  /// 'removed' — organizer removed player (set only by organizer flow)
  /// null — not declined
  final String? declineReason;

  final DateTime? respondedAt;

  bool get isConfirmed => status == 'confirmed';
  bool get isPending => status == 'pending';
  bool get isDeclined => status == 'declined';

  Rsvp copyWith({
    String? rsvpId,
    String? sessionId,
    String? playerId,
    String? playerName,
    String? status,
    String? declineReason,
    DateTime? respondedAt,
  }) =>
      Rsvp(
        rsvpId: rsvpId ?? this.rsvpId,
        sessionId: sessionId ?? this.sessionId,
        playerId: playerId ?? this.playerId,
        playerName: playerName ?? this.playerName,
        status: status ?? this.status,
        declineReason: declineReason ?? this.declineReason,
        respondedAt: respondedAt ?? this.respondedAt,
      );

  factory Rsvp.fromMap(String id, Map<String, dynamic> map) => Rsvp(
        rsvpId: id,
        sessionId: map['sessionId'] as String? ?? '',
        playerId: map['playerId'] as String? ?? '',
        playerName: map['playerName'] as String? ?? '',
        status: map['status'] as String? ?? 'pending',
        declineReason: map['declineReason'] as String?,
        respondedAt: map['respondedAt'] != null
            ? DateTime.parse(map['respondedAt'] as String)
            : null,
      );

  Map<String, dynamic> toMap() => {
        'sessionId': sessionId,
        'playerId': playerId,
        'playerName': playerName,
        'status': status,
        if (declineReason != null) 'declineReason': declineReason,
        if (respondedAt != null)
          'respondedAt': respondedAt!.toIso8601String(),
      };
}

// ── Payment ───────────────────────────────────────────────────────────────────

/// Mirrors `payments/{paymentId}`.
class Payment {
  const Payment({
    required this.paymentId,
    required this.sessionId,
    required this.playerId,
    required this.playerName,
    required this.amount,
    required this.status,
    this.sessionName,
    this.sessionDate,
    this.transactionRef,
    this.paidAt,
  });

  final String paymentId;
  final String sessionId;
  final String playerId;
  final String playerName;
  final double amount;

  /// 'paid' | 'unpaid'
  final String status;

  final String? sessionName;
  final String? sessionDate;
  final String? transactionRef;
  final DateTime? paidAt;

  bool get isPaid => status == 'paid';
  bool get isUnpaid => status == 'unpaid';

  Payment copyWith({
    String? paymentId,
    String? sessionId,
    String? playerId,
    String? playerName,
    double? amount,
    String? status,
    String? sessionName,
    String? sessionDate,
    String? transactionRef,
    DateTime? paidAt,
  }) =>
      Payment(
        paymentId: paymentId ?? this.paymentId,
        sessionId: sessionId ?? this.sessionId,
        playerId: playerId ?? this.playerId,
        playerName: playerName ?? this.playerName,
        amount: amount ?? this.amount,
        status: status ?? this.status,
        sessionName: sessionName ?? this.sessionName,
        sessionDate: sessionDate ?? this.sessionDate,
        transactionRef: transactionRef ?? this.transactionRef,
        paidAt: paidAt ?? this.paidAt,
      );

  factory Payment.fromMap(String id, Map<String, dynamic> map) => Payment(
        paymentId: id,
        sessionId: map['sessionId'] as String? ?? '',
        playerId: map['playerId'] as String? ?? '',
        playerName: map['playerName'] as String? ?? '',
        amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
        status: map['status'] as String? ?? 'unpaid',
        sessionName: map['sessionName'] as String?,
        sessionDate: map['sessionDate'] as String?,
        transactionRef: map['transactionRef'] as String?,
        paidAt: map['paidAt'] != null
            ? DateTime.parse(map['paidAt'] as String)
            : null,
      );

  Map<String, dynamic> toMap() => {
        'sessionId': sessionId,
        'playerId': playerId,
        'playerName': playerName,
        'amount': amount,
        'status': status,
        if (sessionName != null) 'sessionName': sessionName,
        if (sessionDate != null) 'sessionDate': sessionDate,
        if (transactionRef != null) 'transactionRef': transactionRef,
        if (paidAt != null) 'paidAt': paidAt!.toIso8601String(),
      };
}
