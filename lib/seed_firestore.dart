// lib/seed_firestore.dart
//
// Seeds Firestore with demo data AND creates real Firebase Auth accounts.
// Each account uses a simple Gmail address with password "12345678".
//
// Usage:
//   1. Run the app
//   2. Tap "Seed Firestore" on the dev menu
//   3. Wait for the success dialog
//   4. Sign out, then sign in with any seeded account

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ── Account definitions ───────────────────────────────────────────────────────

class _Account {
  final String email;
  final String password;
  final String name;
  final String role;
  String? uid;

  _Account({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });
}

final List<_Account> _venueOwners = [
  _Account(email: 'venue1@gmail.com', password: '12345678', name: 'En. Hafiz', role: 'venue_owner'),
  _Account(email: 'venue2@gmail.com', password: '12345678', name: 'Puan Siti', role: 'venue_owner'),
];

final List<_Account> _organizers = [
  _Account(email: 'organizer1@gmail.com', password: '12345678', name: 'Azri', role: 'organizer'),
  _Account(email: 'organizer2@gmail.com', password: '12345678', name: 'Syafiq', role: 'organizer'),
];

final List<_Account> _players = [
  _Account(email: 'player1@gmail.com', password: '12345678', name: 'Hussein', role: 'player'),
  _Account(email: 'player2@gmail.com', password: '12345678', name: 'Hafiz', role: 'player'),
  _Account(email: 'player3@gmail.com', password: '12345678', name: 'Danial', role: 'player'),
  _Account(email: 'player4@gmail.com', password: '12345678', name: 'Faris', role: 'player'),
  _Account(email: 'player5@gmail.com', password: '12345678', name: 'Imran', role: 'player'),
  _Account(email: 'player6@gmail.com', password: '12345678', name: 'Kamal', role: 'player'),
  _Account(email: 'player7@gmail.com', password: '12345678', name: 'Zikri', role: 'player'),
  _Account(email: 'player8@gmail.com', password: '12345678', name: 'Ali', role: 'player'),
  _Account(email: 'player9@gmail.com', password: '12345678', name: 'Mei Ling', role: 'player'),
  _Account(email: 'player10@gmail.com', password: '12345678', name: 'Priya', role: 'player'),
];

List<_Account> get _allAccounts => [..._venueOwners, ..._organizers, ..._players];

// ── Helpers ───────────────────────────────────────────────────────────────────

String _formatDate(DateTime dt) {
  const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]}';
}

Timestamp _ts(DateTime dt) => Timestamp.fromDate(dt);

// ── Account creation ─────────────────────────────────────────────────────────

Future<void> _createAccounts() async {
  final auth = FirebaseAuth.instance;

  for (final acct in _allAccounts) {
    try {
      await auth.signOut();
      final cred = await auth.createUserWithEmailAndPassword(
        email: acct.email,
        password: acct.password,
      );
      acct.uid = cred.user!.uid;
      await auth.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        await auth.signOut();
        final cred = await auth.signInWithEmailAndPassword(
          email: acct.email,
          password: acct.password,
        );
        acct.uid = cred.user!.uid;
        await auth.signOut();
      } else {
        rethrow;
      }
    }
  }
}

// ── Entry point ──────────────────────────────────────────────────────────────

Future<void> seedFirestore(BuildContext context) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _SeedProgressDialog(),
  );
}

/// Standalone seed function - works without a Flutter widget tree.
/// Use [onProgress] for CLI output (e.g. `print`).
Future<void> seedFirestoreData({void Function(String) onProgress = _noop}) async {
  final db = FirebaseFirestore.instance;
  await _createAccounts();

  // ── Step 1: Auth accounts ──
  await _createAccounts();

  final uidByEmail = <String, String>{};
  for (final acct in _allAccounts) {
    uidByEmail[acct.email] = acct.uid!;
  }

  // ── Step 2: User docs ──────────────────────────────────────────────
  onProgress('Writing user profiles...');
  final usersCol = db.collection('users');
  for (final acct in _allAccounts) {
    await usersCol.doc(acct.uid).set({
      'uid': acct.uid,
      'name': acct.name,
      'email': acct.email,
      'role': acct.role,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Step 3: Venues ─────────────────────────────────────────────────
  onProgress('Creating 8 venues across KL...');
  final venuesCol = db.collection('venues');

  const venues = [
    {'id': 'venue_1', 'name': 'Nexus Futsal Cheras', 'address': '12 Jalan Tun Perak, Cheras, KL', 'lat': 3.1390, 'lng': 101.6869, 'courts': ['Court 1', 'Court 2', 'Court 3'], 'owner': 'venue1@gmail.com', 'imageUrl': ''},
    {'id': 'venue_2', 'name': 'Arena Futsal KLCC', 'address': '45 Jalan Ampang, KLCC, KL', 'lat': 3.1450, 'lng': 101.6950, 'courts': ['Court 1', 'Court 2'], 'owner': 'venue1@gmail.com', 'imageUrl': ''},
    {'id': 'venue_3', 'name': 'Pro Futsal Bukit Bintang', 'address': '78 Jalan Bukit Bintang, KL', 'lat': 3.1320, 'lng': 101.6800, 'courts': ['Court 1', 'Court 2'], 'owner': 'venue2@gmail.com', 'imageUrl': ''},
    {'id': 'venue_4', 'name': 'City Sports Hub Bangsar', 'address': '23 Jalan Bangsar, KL', 'lat': 3.1500, 'lng': 101.7000, 'courts': ['Court 1', 'Court 2', 'Court 3', 'Court 4'], 'owner': 'venue2@gmail.com', 'imageUrl': ''},
    {'id': 'venue_5', 'name': 'Westside Arena PJ', 'address': '56 Jalan SS2, Petaling Jaya', 'lat': 3.1180, 'lng': 101.6350, 'courts': ['Court 1', 'Court 2', 'Court 3'], 'owner': 'venue1@gmail.com', 'imageUrl': ''},
    {'id': 'venue_6', 'name': 'Northpark Courts Mont Kiara', 'address': '90 Jalan Kiara, Mont Kiara, KL', 'lat': 3.1620, 'lng': 101.6470, 'courts': ['Court 1', 'Court 2'], 'owner': 'venue2@gmail.com', 'imageUrl': ''},
    {'id': 'venue_7', 'name': 'SportsRally Arena PJ', 'address': '34 Jalan 52, Petaling Jaya', 'lat': 3.1080, 'lng': 101.6420, 'courts': ['Court 1', 'Court 2'], 'owner': 'venue1@gmail.com', 'imageUrl': ''},
    {'id': 'venue_8', 'name': 'Mega Court KL Sentral', 'address': '5 Jalan Stesen, KL Sentral', 'lat': 3.1340, 'lng': 101.6850, 'courts': ['Court 1', 'Court 2', 'Court 3'], 'owner': 'venue2@gmail.com', 'imageUrl': ''},
  ];

  for (final v in venues) {
    await venuesCol.doc(v['id'] as String).set({
      'venueId': v['id'],
      'name': v['name'],
      'address': v['address'],
      'lat': v['lat'],
      'lng': v['lng'],
      'ownerId': uidByEmail[v['owner'] as String],
      'ownerName': _allAccounts.firstWhere((a) => a.email == v['owner']).name,
      'courts': v['courts'],
      'imageUrl': v['imageUrl'],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  final venueNames = {
    for (final v in venues) v['id'] as String: v['name'] as String,
  };

  // ── Step 4: Sessions ───────────────────────────────────────────────
  onProgress('Creating 25 sessions...');

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final daysFromMonday = today.weekday - DateTime.monday;
  final weekStart = today.subtract(Duration(days: daysFromMonday));

  final nameByEmail = {for (final a in _allAccounts) a.email: a.name};

  final timeSlots = [
    ('6:00 PM - 8:00 PM', 18),
    ('7:00 PM - 9:00 PM', 19),
    ('8:00 PM - 10:00 PM', 20),
    ('9:00 PM - 11:00 PM', 21),
    ('10:00 AM - 12:00 PM', 10),
    ('2:00 PM - 4:00 PM', 14),
  ];

  int tIdx(String label) => timeSlots.indexWhere((t) => t.$1 == label);

  final sessionDefs = [
    // Upcoming sessions (next 30 days)
    {'vid': 'venue_1', 'court': 'Court 1', 'sport': 'Futsal', 'price': 25.0, 'max': 12, 'day': 3, 'time': '8:00 PM - 10:00 PM', 'org': 'organizer1@gmail.com'},
    {'vid': 'venue_1', 'court': 'Court 2', 'sport': 'Badminton', 'price': 18.0, 'max': 8, 'day': 5, 'time': '6:00 PM - 8:00 PM', 'org': 'organizer1@gmail.com'},
    {'vid': 'venue_1', 'court': 'Court 3', 'sport': 'Futsal', 'price': 20.0, 'max': 10, 'day': 8, 'time': '9:00 PM - 11:00 PM', 'org': 'organizer2@gmail.com'},
    {'vid': 'venue_2', 'court': 'Court 1', 'sport': 'Futsal', 'price': 30.0, 'max': 10, 'day': 2, 'time': '7:00 PM - 9:00 PM', 'org': 'organizer1@gmail.com'},
    {'vid': 'venue_2', 'court': 'Court 2', 'sport': 'Futsal', 'price': 28.0, 'max': 8, 'day': 6, 'time': '8:00 PM - 10:00 PM', 'org': 'organizer2@gmail.com'},
    {'vid': 'venue_3', 'court': 'Court 1', 'sport': 'Basketball', 'price': 35.0, 'max': 10, 'day': 4, 'time': '7:00 PM - 9:00 PM', 'org': 'organizer1@gmail.com'},
    {'vid': 'venue_3', 'court': 'Court 2', 'sport': 'Futsal', 'price': 22.0, 'max': 12, 'day': 10, 'time': '6:00 PM - 8:00 PM', 'org': 'organizer2@gmail.com'},
    {'vid': 'venue_4', 'court': 'Court 1', 'sport': 'Tennis', 'price': 40.0, 'max': 4, 'day': 7, 'time': '10:00 AM - 12:00 PM', 'org': 'organizer1@gmail.com'},
    {'vid': 'venue_4', 'court': 'Court 2', 'sport': 'Badminton', 'price': 15.0, 'max': 8, 'day': 9, 'time': '2:00 PM - 4:00 PM', 'org': 'organizer2@gmail.com'},
    {'vid': 'venue_4', 'court': 'Court 3', 'sport': 'Futsal', 'price': 25.0, 'max': 12, 'day': 12, 'time': '8:00 PM - 10:00 PM', 'org': 'organizer1@gmail.com'},
    {'vid': 'venue_5', 'court': 'Court 1', 'sport': 'Pickleball', 'price': 20.0, 'max': 6, 'day': 11, 'time': '7:00 PM - 9:00 PM', 'org': 'organizer2@gmail.com'},
    {'vid': 'venue_5', 'court': 'Court 2', 'sport': 'Badminton', 'price': 16.0, 'max': 8, 'day': 14, 'time': '6:00 PM - 8:00 PM', 'org': 'organizer1@gmail.com'},
    {'vid': 'venue_5', 'court': 'Court 3', 'sport': 'Futsal', 'price': 22.0, 'max': 10, 'day': 16, 'time': '9:00 PM - 11:00 PM', 'org': 'organizer2@gmail.com'},
    {'vid': 'venue_6', 'court': 'Court 1', 'sport': 'Tennis', 'price': 38.0, 'max': 4, 'day': 15, 'time': '10:00 AM - 12:00 PM', 'org': 'organizer1@gmail.com'},
    {'vid': 'venue_6', 'court': 'Court 2', 'sport': 'Pickleball', 'price': 18.0, 'max': 6, 'day': 18, 'time': '2:00 PM - 4:00 PM', 'org': 'organizer2@gmail.com'},
    {'vid': 'venue_7', 'court': 'Court 1', 'sport': 'Badminton', 'price': 15.0, 'max': 8, 'day': 20, 'time': '7:00 PM - 9:00 PM', 'org': 'organizer1@gmail.com'},
    {'vid': 'venue_7', 'court': 'Court 2', 'sport': 'Futsal', 'price': 24.0, 'max': 12, 'day': 22, 'time': '8:00 PM - 10:00 PM', 'org': 'organizer2@gmail.com'},
    {'vid': 'venue_8', 'court': 'Court 1', 'sport': 'Basketball', 'price': 32.0, 'max': 10, 'day': 25, 'time': '6:00 PM - 8:00 PM', 'org': 'organizer1@gmail.com'},
    {'vid': 'venue_8', 'court': 'Court 2', 'sport': 'Futsal', 'price': 20.0, 'max': 10, 'day': 28, 'time': '9:00 PM - 11:00 PM', 'org': 'organizer2@gmail.com'},
    {'vid': 'venue_8', 'court': 'Court 3', 'sport': 'Pickleball', 'price': 18.0, 'max': 6, 'day': 30, 'time': '7:00 PM - 9:00 PM', 'org': 'organizer1@gmail.com'},
    // Completed sessions (past 14 days)
    {'vid': 'venue_1', 'court': 'Court 1', 'sport': 'Futsal', 'price': 25.0, 'max': 12, 'day': -3, 'time': '8:00 PM - 10:00 PM', 'org': 'organizer1@gmail.com'},
    {'vid': 'venue_3', 'court': 'Court 2', 'sport': 'Futsal', 'price': 22.0, 'max': 10, 'day': -5, 'time': '7:00 PM - 9:00 PM', 'org': 'organizer2@gmail.com'},
    {'vid': 'venue_4', 'court': 'Court 1', 'sport': 'Badminton', 'price': 15.0, 'max': 8, 'day': -8, 'time': '6:00 PM - 8:00 PM', 'org': 'organizer1@gmail.com'},
    {'vid': 'venue_5', 'court': 'Court 1', 'sport': 'Pickleball', 'price': 20.0, 'max': 6, 'day': -10, 'time': '2:00 PM - 4:00 PM', 'org': 'organizer2@gmail.com'},
    {'vid': 'venue_2', 'court': 'Court 1', 'sport': 'Futsal', 'price': 30.0, 'max': 10, 'day': -12, 'time': '8:00 PM - 10:00 PM', 'org': 'organizer1@gmail.com'},
    // Cancelled sessions
    {'vid': 'venue_1', 'court': 'Court 2', 'sport': 'Badminton', 'price': 18.0, 'max': 8, 'day': -2, 'time': '6:00 PM - 8:00 PM', 'org': 'organizer1@gmail.com'},
    {'vid': 'venue_4', 'court': 'Court 4', 'sport': 'Futsal', 'price': 25.0, 'max': 12, 'day': -6, 'time': '9:00 PM - 11:00 PM', 'org': 'organizer2@gmail.com'},
  ];

  final sessionsCol = db.collection('sessions');
  int sessionNum = 0;

  for (int i = 0; i < sessionDefs.length; i++) {
    final s = sessionDefs[i];
    sessionNum++;
    final dayOffset = s['day'] as int;
    final timeLabel = s['time'] as String;
            final ti = tIdx(timeLabel);
    final startHour = timeSlots[ti].$2;
    final date = weekStart.add(Duration(days: dayOffset, hours: startHour));

    final isCancelled = i >= sessionDefs.length - 2;
    final isCompleted = i >= sessionDefs.length - 7 && i < sessionDefs.length - 2;
    final status = isCancelled ? 'cancelled' : (isCompleted ? 'completed' : 'upcoming');
    final rsvpCount = isCancelled ? 0 : (isCompleted ? (s['max'] as int) ~/ 2 : (s['max'] as int) * 3 ~/ 4);

    await sessionsCol.doc('session_$sessionNum').set({
      'sessionId': 'session_$sessionNum',
      'organizerId': uidByEmail[s['org'] as String],
      'organizerName': nameByEmail[s['org'] as String] ?? '',
      'venueId': s['vid'],
      'venueName': venueNames[s['vid']]!,
      'court': s['court'],
      'date': _formatDate(date),
      'dateTimestamp': _ts(date),
      'time': timeLabel,
      'maxPlayers': s['max'],
      'rsvpCount': rsvpCount,
      'costPerPlayer': s['price'],
      'status': status,
      'createdAt': _ts(today.subtract(Duration(days: 30 - (dayOffset < 0 ? 0 : dayOffset)))),
      'sport': s['sport'],
    });
  }

  // ── Step 5: RSVPs ──────────────────────────────────────────────────
  onProgress('Creating RSVPs...');
  final rsvpsCol = db.collection('rsvps');
  int rsvpNum = 0;
  final rsvpCountBySession = <int, int>{};

  for (int sessionIdx = 0; sessionIdx < sessionDefs.length; sessionIdx++) {
    final s = sessionDefs[sessionIdx];
    final sessionNumId = sessionIdx + 1;
    final isCancelled = sessionIdx >= sessionDefs.length - 2;
    final maxPlayers = s['max'] as int;
    // Assign 3 to 10 players per session
    final numPlayers = maxPlayers > 8 ? (maxPlayers * 3 ~/ 4).clamp(3, 10) : maxPlayers.clamp(2, 8);

    for (int p = 0; p < numPlayers && p < _players.length; p++) {
      rsvpNum++;
      final player = _players[p];
      final isConfirmed = p < (numPlayers * 0.7).round();
      final status = isCancelled ? 'declined' : (isConfirmed ? 'confirmed' : (p % 3 == 0 ? 'pending' : 'declined'));

      await rsvpsCol.doc('rsvp_$rsvpNum').set({
        'rsvpId': 'rsvp_$rsvpNum',
        'sessionId': 'session_$sessionNumId',
        'playerId': player.uid,
        'playerName': player.name,
        'status': status,
        'declineReason': status == 'declined' ? 'self' : null,
        'respondedAt': status != 'pending' ? _ts(today.subtract(const Duration(hours: 2))) : null,
      });

      if (status == 'confirmed') {
        rsvpCountBySession[sessionNumId] = (rsvpCountBySession[sessionNumId] ?? 0) + 1;
      }
    }
  }

  // Update rsvpCount on sessions (more accurate than hardcoded values)
  for (final entry in rsvpCountBySession.entries) {
    await sessionsCol.doc('session_${entry.key}').update({
      'rsvpCount': entry.value,
    });
  }

  // ── Step 6: Payments ───────────────────────────────────────────────
  onProgress('Creating payments...');
  final paymentsCol = db.collection('payments');
  int payNum = 0;

  for (int sessionIdx = 0; sessionIdx < sessionDefs.length; sessionIdx++) {
    final s = sessionDefs[sessionIdx];
    final sessionNumId = sessionIdx + 1;
    final maxPlayers = s['max'] as int;
    final numPlayers = maxPlayers > 8 ? (maxPlayers * 3 ~/ 4).clamp(3, 10) : maxPlayers.clamp(2, 8);

    for (int p = 0; p < numPlayers && p < _players.length; p++) {
      final player = _players[p];
      final isCancelled = sessionIdx >= sessionDefs.length - 2;
      final isPaid = !isCancelled && p % 3 != 0; // 2/3 paid

      payNum++;
      final payId = 'payment_$payNum';

      await paymentsCol.doc(payId).set({
        'paymentId': payId,
        'sessionId': 'session_$sessionNumId',
        'playerId': player.uid,
        'playerName': player.name,
        'amount': s['price'],
        'status': isPaid ? 'paid' : 'unpaid',
        'sessionName': '${s['sport']} at ${venueNames[s['vid']]}',
        'sessionDate': '${today.day}/${today.month}/${today.year}',
        'transactionRef': isPaid ? 'FPX-${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}-$payNum' : null,
        'paidAt': isPaid ? _ts(today.subtract(const Duration(hours: 4))) : null,
      });
    }
  }

  // ── Step 7: Slots ──────────────────────────────────────────────────
  onProgress('Creating availability slots...');
  final slotsCol = db.collection('slots');

  for (final v in venues) {
    final vid = v['id'] as String;
    final courts = v['courts'] as List;

    for (int dayOff = 0; dayOff < 14; dayOff++) {
      final slotDate = weekStart.add(Duration(days: dayOff));
      final dateLabel = _formatDate(slotDate);

      for (int ci = 0; ci < courts.length; ci++) {
        for (int h = 18; h <= 22; h++) {
          final slotId = '${vid}_c${ci}_d${dayOff}_h$h';
          final isBooked = dayOff == 3 && ci == 0 && (h == 20 || h == 21);
          final isMaintenance = dayOff == 5 && ci == 1 && h == 19;

          await slotsCol.doc(slotId).set({
            'slotId': slotId,
            'venueId': vid,
            'courtIndex': ci,
            'date': dateLabel,
            'dateTimestamp': _ts(DateTime(slotDate.year, slotDate.month, slotDate.day, h)),
            'timeLabel': '${h > 12 ? h - 12 : h}:00 ${h >= 12 ? "PM" : "AM"}',
            'status': isBooked ? 'booked' : (isMaintenance ? 'maintenance' : 'available'),
            'isEnabled': !isBooked && !isMaintenance,
            'sessionId': isBooked ? 'session_1' : null,
          });
        }
      }
    }
  }

  // ── Step 8: Cancellations ──────────────────────────────────────────
  onProgress('Creating cancellation records...');
  final cancelsCol = db.collection('cancellations');

  await cancelsCol.doc('cancellation_1').set({
    'cancellationId': 'cancellation_1',
    'venueId': 'venue_1',
    'sessionId': 'session_26',
    'organizerId': uidByEmail['organizer1@gmail.com'],
    'organizerName': 'Azri',
    'court': 'Court 2',
    'timeRange': '6:00 PM - 8:00 PM',
    'dateLabel': _formatDate(today.subtract(const Duration(days: 2))),
    'dateTimestamp': _ts(today.subtract(const Duration(days: 2, hours: 18))),
    'lostRevenue': 144.0,
    'depositCollected': 30.0,
    'noticeHours': 2,
    'createdAt': FieldValue.serverTimestamp(),
  });

  await cancelsCol.doc('cancellation_2').set({
    'cancellationId': 'cancellation_2',
    'venueId': 'venue_4',
    'sessionId': 'session_27',
    'organizerId': uidByEmail['organizer2@gmail.com'],
    'organizerName': 'Syafiq',
    'court': 'Court 4',
    'timeRange': '9:00 PM - 11:00 PM',
    'dateLabel': _formatDate(today.subtract(const Duration(days: 6))),
    'dateTimestamp': _ts(today.subtract(const Duration(days: 6, hours: 21))),
    'lostRevenue': 300.0,
    'depositCollected': 50.0,
    'noticeHours': 5,
    'createdAt': FieldValue.serverTimestamp(),
  });


}

void _noop(String _) {}

// ── Progress dialog ──────────────────────────────────────────────────────────

class _SeedProgressDialog extends StatefulWidget {
  const _SeedProgressDialog();
  @override
  State<_SeedProgressDialog> createState() => _SeedProgressDialogState();
}

class _SeedProgressDialogState extends State<_SeedProgressDialog> {
  String _message = 'Initialising...';
  bool _done = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _seed());
  }

  Future<void> _seed() async {
    try {
      await seedFirestoreData(onProgress: _update);

      if (!mounted) return;
      setState(() {
        _done = true;
        _message = 'Database seeded successfully!';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _done = true;
      });
    }
  }
  Future<void> _update(String msg) async {
    if (!mounted) return;
    setState(() => _message = msg);
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_done ? (_error == null ? 'Seed Complete' : 'Seed Failed') : 'Seeding Database'),
      content: SizedBox(
        width: double.maxFinite,
        child: _error != null
            ? SingleChildScrollView(child: Text('❌ $_error', style: const TextStyle(color: Color(0xFFD92B2B))))
            : _done
                ? _buildResult()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(_message),
                      const SizedBox(height: 8),
                      const Text('Do not close this dialog.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                    ],
                  ),
      ),
      actions: [
        if (_done)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
      ],
    );
  }

  Widget _buildResult() {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('All data seeded!', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D7A3E))),
          const SizedBox(height: 12),
          const Text('Sign out, then sign in with any account below:',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          const SizedBox(height: 4),
          const Text('Password: 12345678',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 12),
          const Text('Venue Owners', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0D7A3E))),
          ..._venueOwners.map((a) => Text('  ${a.email} - ${a.name}', style: const TextStyle(fontSize: 12))),
          const SizedBox(height: 8),
          const Text('Organizers', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0D7A3E))),
          ..._organizers.map((a) => Text('  ${a.email} - ${a.name}', style: const TextStyle(fontSize: 12))),
          const SizedBox(height: 8),
          const Text('Players', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0D7A3E))),
          ..._players.map((a) => Text('  ${a.email} - ${a.name}', style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}
