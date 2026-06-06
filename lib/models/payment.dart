// TEMPORARY model — Hassan (data layer owner) will finalize. Coordinate before changing field names.

class Payment {
  final String id;
  final String playerId;
  final String playerName;
  final String initials;
  final String sessionId;
  final double amount;
  final bool paid;

  const Payment({
    required this.id,
    required this.playerId,
    required this.playerName,
    required this.initials,
    required this.sessionId,
    required this.amount,
    required this.paid,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: json['id'] as String? ?? '',
        playerId: json['playerId'] as String? ?? '',
        playerName: json['playerName'] as String? ?? '',
        initials: json['initials'] as String? ?? '',
        sessionId: json['sessionId'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        paid: json['paid'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'playerId': playerId,
        'playerName': playerName,
        'initials': initials,
        'sessionId': sessionId,
        'amount': amount,
        'paid': paid,
      };

  Payment copyWith({bool? paid}) => Payment(
        id: id,
        playerId: playerId,
        playerName: playerName,
        initials: initials,
        sessionId: sessionId,
        amount: amount,
        paid: paid ?? this.paid,
      );
}
