import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import '../../../models/models.dart';
import '../../../repositories/rsvp_repository.dart';
import '../../../repositories/payment_repository.dart';

class PlayerRsvpEntry {
  final String playerId;
  final String name;
  final String initials;
  final String status; // 'going', 'maybe', 'out'
  final bool paid;

  const PlayerRsvpEntry({
    required this.playerId,
    required this.name,
    required this.initials,
    required this.status,
    required this.paid,
  });
}

class RsvpTrackerViewModel extends ChangeNotifier {
  final RsvpRepository _rsvpRepo;
  final PaymentRepository _paymentRepo;
  final Session session;

  StreamSubscription? _rsvpSub;
  StreamSubscription? _paymentSub;

  String selectedFilter = 'going';

  List<PlayerRsvpEntry> _allPlayers = [];

  RsvpTrackerViewModel({
    required RsvpRepository rsvpRepo,
    required PaymentRepository paymentRepo,
    required this.session,
  })  : _rsvpRepo = rsvpRepo,
        _paymentRepo = paymentRepo {
    _init();
  }

  List<PlayerRsvpEntry> get visiblePlayers =>
      _allPlayers.where((p) => p.status == selectedFilter).toList();

  int get goingCount => _allPlayers.where((p) => p.status == 'going').length;
  int get maybeCount => _allPlayers.where((p) => p.status == 'maybe').length;
  int get outCount => _allPlayers.where((p) => p.status == 'out').length;

  String get title => '${session.sport} · ${session.date}';
  String get subtitle =>
      '${session.venueName} ${session.court} · ${session.time}';

  void setFilter(String filter) {
    selectedFilter = filter;
    notifyListeners();
  }

  void sendReminder() {}

  void shareInviteLink() {
    final msg = 'Join my ${session.sport} session at ${session.venueName} '
        '(${session.court}) on ${session.date} from ${session.time}!\n'
        'RM${session.costPerPlayer.toStringAsFixed(0)}/pax. '
        'Respond via CourtCall: courtcall://sessions/${session.sessionId}';
    Share.share(msg);
  }

  void _init() {
    _rsvpSub = _rsvpRepo.watchRsvpsForSession(session.sessionId).listen(
      (rsvps) {
        _merge(rsvps, _cachedPayments);
      },
    );
    _paymentSub =
        _paymentRepo.watchPaymentsForSession(session.sessionId).listen(
      (payments) {
        _merge(_cachedRsvps, payments);
      },
    );
  }

  List<Rsvp> _cachedRsvps = [];
  List<Payment> _cachedPayments = [];

  void _merge(List<Rsvp> rsvps, List<Payment> payments) {
    _cachedRsvps = rsvps;
    _cachedPayments = payments;

    final paymentByPlayer = {
      for (final p in payments) p.playerId: p,
    };

    _allPlayers = rsvps.map((r) {
      final payment = paymentByPlayer[r.playerId];
      return PlayerRsvpEntry(
        playerId: r.playerId,
        name: r.playerName,
        initials: _initials(r.playerName),
        status: _mapStatus(r.status),
        paid: payment?.status == 'paid',
      );
    }).toList();

    notifyListeners();
  }

  String _mapStatus(String s) {
    switch (s) {
      case 'confirmed':
        return 'going';
      case 'pending':
        return 'maybe';
      case 'declined':
        return 'out';
      default:
        return 'maybe';
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  void dispose() {
    _rsvpSub?.cancel();
    _paymentSub?.cancel();
    super.dispose();
  }
}
