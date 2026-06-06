import 'package:flutter/foundation.dart';

class PlayerRsvp {
  final String name;
  final String initials;
  final String status; // 'going', 'maybe', or 'out'
  final bool paid;
  const PlayerRsvp(this.name, this.initials, this.status, this.paid);
}

class RsvpTrackerViewModel extends ChangeNotifier {
  String selectedFilter = 'going';

  final List<PlayerRsvp> _allPlayers = const [
    // Going (8)
    PlayerRsvp('Azri',   'AZ', 'going', true),
    PlayerRsvp('Hafiz',  'HF', 'going', false),
    PlayerRsvp('Syafiq', 'SY', 'going', true),
    PlayerRsvp('Danial', 'DN', 'going', false),
    PlayerRsvp('Faris',  'FR', 'going', true),
    PlayerRsvp('Imran',  'IM', 'going', true),
    PlayerRsvp('Kamal',  'KM', 'going', true),
    PlayerRsvp('Zikri',  'ZK', 'going', false),
    // Maybe (2)
    PlayerRsvp('Rashid', 'RA', 'maybe', false),
    PlayerRsvp('Hakim',  'HK', 'maybe', false),
    // Out (3)
    PlayerRsvp('Faizal', 'FZ', 'out', false),
    PlayerRsvp('Aiman',  'AM', 'out', false),
    PlayerRsvp('Rizal',  'RZ', 'out', false),
  ];

  List<PlayerRsvp> get visiblePlayers =>
      _allPlayers.where((p) => p.status == selectedFilter).toList();

  int get goingCount => _allPlayers.where((p) => p.status == 'going').length;
  int get maybeCount => _allPlayers.where((p) => p.status == 'maybe').length;
  int get outCount   => _allPlayers.where((p) => p.status == 'out').length;

  void setFilter(String filter) {
    selectedFilter = filter;
    notifyListeners();
  }

  void sendReminder() {}
  void shareInviteLink() {}
}