// TEMPORARY model — Hassan (data layer owner) will finalize. Coordinate before changing field names.

class Session {
  final String id;
  final String sport;
  final String venueName;
  final String courtName;
  final String date;          // 'YYYY-MM-DD'
  final String startTime;     // e.g. '8:00 PM'
  final String endTime;       // e.g. '10:00 PM'
  final int maxPlayers;
  final int confirmedCount;
  final double costPerPlayer;
  final double courtCost;
  final String status;        // 'upcoming' | 'cancelled'

  const Session({
    required this.id,
    required this.sport,
    required this.venueName,
    required this.courtName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.maxPlayers,
    required this.confirmedCount,
    required this.costPerPlayer,
    required this.courtCost,
    required this.status,
  });

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        id: json['id'] as String? ?? '',
        sport: json['sport'] as String? ?? 'Futsal',
        venueName: json['venueName'] as String? ?? '',
        courtName: json['courtName'] as String? ?? '',
        date: json['date'] as String? ?? '',
        startTime: json['startTime'] as String? ?? '',
        endTime: json['endTime'] as String? ?? '',
        maxPlayers: json['maxPlayers'] as int? ?? 0,
        confirmedCount: json['confirmedCount'] as int? ?? 0,
        costPerPlayer: (json['costPerPlayer'] as num?)?.toDouble() ?? 0.0,
        courtCost: (json['courtCost'] as num?)?.toDouble() ?? 0.0,
        status: json['status'] as String? ?? 'upcoming',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sport': sport,
        'venueName': venueName,
        'courtName': courtName,
        'date': date,
        'startTime': startTime,
        'endTime': endTime,
        'maxPlayers': maxPlayers,
        'confirmedCount': confirmedCount,
        'costPerPlayer': costPerPlayer,
        'courtCost': courtCost,
        'status': status,
      };
}
