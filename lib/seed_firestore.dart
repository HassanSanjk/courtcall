// lib/seed_firestore.dart
//
// HOW TO USE:
// 1. Add seed button in dev_menu.dart (already done)
// 2. Run the app, tap 'Seed Firestore' once
// 3. Check Firebase Console — all collections will be there
// 4. Remove the button when done
//
// IMPORTANT — UIDs:
// Replace kVenueOwnerUid and kOrganizerUid with real UIDs from
// Firebase Console → Authentication → Users after creating accounts.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ── Placeholder UIDs (replace after creating real Auth accounts) ─────────────
const String kVenueOwnerUid = 'venue_owner_uid_replace_me';
const String kOrganizerUid  = 'organizer_uid_replace_me';
const String kPlayerUid     = 'player_uid_replace_me';

// ── Entry point ──────────────────────────────────────────────────────────────
Future<void> seedFirestore(BuildContext context) async {
  final db = FirebaseFirestore.instance;

  try {
    await _seedUsers(db);
    await _seedVenues(db);
    await _seedSlots(db);
    await _seedSessions(db);
    await _seedRsvps(db);
    await _seedPayments(db);
    await _seedCancellations(db);
    await _seedWaitlist(db);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Firestore seeded successfully!'),
          backgroundColor: Color(0xFF0D7A3E),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Seed failed: $e'),
          backgroundColor: const Color(0xFFD92B2B),
        ),
      );
    }
  }
}

// ── users ────────────────────────────────────────────────────────────────────
Future<void> _seedUsers(FirebaseFirestore db) async {
  final col = db.collection('users');

  await col.doc(kVenueOwnerUid).set({
    'uid': kVenueOwnerUid,
    'name': 'En. Hafiz',
    'email': 'hafiz@nexusfutsal.com',
    'role': 'venue_owner',
    'createdAt': FieldValue.serverTimestamp(),
  });

  await col.doc(kOrganizerUid).set({
    'uid': kOrganizerUid,
    'name': 'Azri',
    'email': 'azri@courtcall.com',
    'role': 'organizer',
    'createdAt': FieldValue.serverTimestamp(),
  });

  await col.doc(kPlayerUid).set({
    'uid': kPlayerUid,
    'name': 'Syafiq',
    'email': 'syafiq@courtcall.com',
    'role': 'player',
    'createdAt': FieldValue.serverTimestamp(),
  });
}

// ── venues ───────────────────────────────────────────────────────────────────
Future<void> _seedVenues(FirebaseFirestore db) async {
  final col = db.collection('venues');

  await col.doc('venue_1').set({
    'venueId': 'venue_1',
    'ownerId': kVenueOwnerUid,
    'name': 'Nexus Futsal',
    'address': 'Jalan Ampang, Kuala Lumpur',
    'lat': 3.1390,
    'lng': 101.6869,
    'courts': ['Court 1', 'Court 2', 'Court 3'],
    'createdAt': FieldValue.serverTimestamp(),
  });

  await col.doc('venue_2').set({
    'venueId': 'venue_2',
    'ownerId': kVenueOwnerUid,
    'name': 'Arena Futsal',
    'address': 'Jalan Bukit Bintang, Kuala Lumpur',
    'lat': 3.1450,
    'lng': 101.6950,
    'courts': ['Court 1', 'Court 2'],
    'createdAt': FieldValue.serverTimestamp(),
  });
}

// ── slots ────────────────────────────────────────────────────────────────────
Future<void> _seedSlots(FirebaseFirestore db) async {
  final col = db.collection('slots');

  // Helper — converts a date string to Timestamp for querying
  Timestamp toTs(int year, int month, int day, int hour) =>
      Timestamp.fromDate(DateTime(year, month, day, hour));

  final slots = [
    {
      'slotId': 'slot_1',
      'venueId': 'venue_1',
      'courtIndex': 0,
      'date': 'Friday, 9 May',
      'dateTimestamp': toTs(2026, 5, 9, 18),
      'timeLabel': '6:00 PM',
      'status': 'available',
      'isEnabled': true,
      'sessionId': null,
    },
    {
      'slotId': 'slot_2',
      'venueId': 'venue_1',
      'courtIndex': 0,
      'date': 'Friday, 9 May',
      'dateTimestamp': toTs(2026, 5, 9, 19),
      'timeLabel': '7:00 PM',
      'status': 'available',
      'isEnabled': true,
      'sessionId': null,
    },
    {
      'slotId': 'slot_3',
      'venueId': 'venue_1',
      'courtIndex': 0,
      'date': 'Friday, 9 May',
      'dateTimestamp': toTs(2026, 5, 9, 20),
      'timeLabel': '8:00 PM',
      'status': 'booked',
      'isEnabled': false,
      'sessionId': 'session_1',
    },
    {
      'slotId': 'slot_4',
      'venueId': 'venue_1',
      'courtIndex': 0,
      'date': 'Friday, 9 May',
      'dateTimestamp': toTs(2026, 5, 9, 21),
      'timeLabel': '9:00 PM',
      'status': 'maintenance',
      'isEnabled': false,
      'sessionId': null,
    },
    {
      'slotId': 'slot_5',
      'venueId': 'venue_1',
      'courtIndex': 0,
      'date': 'Friday, 9 May',
      'dateTimestamp': toTs(2026, 5, 9, 22),
      'timeLabel': '10:00 PM',
      'status': 'available',
      'isEnabled': false,       // available but toggled off by venue owner
      'sessionId': null,
    },
    {
      'slotId': 'slot_6',
      'venueId': 'venue_1',
      'courtIndex': 1,
      'date': 'Friday, 9 May',
      'dateTimestamp': toTs(2026, 5, 9, 18),
      'timeLabel': '6:00 PM',
      'status': 'booked',
      'isEnabled': false,
      'sessionId': 'session_2',
    },
    {
      'slotId': 'slot_7',
      'venueId': 'venue_1',
      'courtIndex': 1,
      'date': 'Friday, 9 May',
      'dateTimestamp': toTs(2026, 5, 9, 20),
      'timeLabel': '8:00 PM',
      'status': 'blocked',
      'isEnabled': false,
      'sessionId': null,
    },
    {
      'slotId': 'slot_8',
      'venueId': 'venue_1',
      'courtIndex': 2,
      'date': 'Friday, 9 May',
      'dateTimestamp': toTs(2026, 5, 9, 18),
      'timeLabel': '6:00 PM',
      'status': 'available',
      'isEnabled': true,
      'sessionId': null,
    },
  ];

  for (final slot in slots) {
    await col.doc(slot['slotId'] as String).set(slot);
  }
}

// ── sessions ─────────────────────────────────────────────────────────────────
Future<void> _seedSessions(FirebaseFirestore db) async {
  final col = db.collection('sessions');

  await col.doc('session_1').set({
    'sessionId': 'session_1',
    'organizerId': kOrganizerUid,
    'venueId': 'venue_1',
    'venueName': 'Nexus Futsal',
    'court': 'Court 1',
    'date': 'Friday, 9 May',
    'dateTimestamp': Timestamp.fromDate(DateTime(2026, 5, 9, 20)),
    'time': '8:00 PM – 10:00 PM',
    'maxPlayers': 12,
    'rsvpCount': 3,             // matches confirmed rsvps seeded below
    'costPerPlayer': 25.0,
    'status': 'upcoming',
    'createdAt': FieldValue.serverTimestamp(),
  });

  await col.doc('session_2').set({
    'sessionId': 'session_2',
    'organizerId': kOrganizerUid,
    'venueId': 'venue_1',
    'venueName': 'Nexus Futsal',
    'court': 'Court 2',
    'date': 'Sunday, 11 May',
    'dateTimestamp': Timestamp.fromDate(DateTime(2026, 5, 11, 19)),
    'time': '7:00 PM – 9:00 PM',
    'maxPlayers': 10,
    'rsvpCount': 1,             // matches confirmed rsvps seeded below
    'costPerPlayer': 20.0,
    'status': 'upcoming',
    'createdAt': FieldValue.serverTimestamp(),
  });
}

// ── rsvps ────────────────────────────────────────────────────────────────────
Future<void> _seedRsvps(FirebaseFirestore db) async {
  final col = db.collection('rsvps');

  final rsvps = [
    // session_1 — 3 confirmed, 1 pending, 1 declined (self)
    {
      'rsvpId': 'rsvp_1',
      'sessionId': 'session_1',
      'playerId': kOrganizerUid,
      'playerName': 'Azri',
      'status': 'confirmed',
      'declineReason': null,
    },
    {
      'rsvpId': 'rsvp_2',
      'sessionId': 'session_1',
      'playerId': kPlayerUid,
      'playerName': 'Syafiq',
      'status': 'confirmed',
      'declineReason': null,
    },
    {
      'rsvpId': 'rsvp_3',
      'sessionId': 'session_1',
      'playerId': 'player_3',
      'playerName': 'Danial',
      'status': 'confirmed',
      'declineReason': null,
    },
    {
      'rsvpId': 'rsvp_4',
      'sessionId': 'session_1',
      'playerId': 'player_4',
      'playerName': 'Hafiz',
      'status': 'pending',
      'declineReason': null,
    },
    {
      'rsvpId': 'rsvp_5',
      'sessionId': 'session_1',
      'playerId': 'player_5',
      'playerName': 'Ridhwan',
      'status': 'declined',
      'declineReason': 'self',  // self-decline → waitlist promotion triggered
    },

    // session_2 — 1 confirmed
    {
      'rsvpId': 'rsvp_6',
      'sessionId': 'session_2',
      'playerId': kOrganizerUid,
      'playerName': 'Azri',
      'status': 'confirmed',
      'declineReason': null,
    },
  ];

  for (final rsvp in rsvps) {
    await col.doc(rsvp['rsvpId'] as String).set(rsvp);
  }
}

// ── payments ─────────────────────────────────────────────────────────────────
Future<void> _seedPayments(FirebaseFirestore db) async {
  final col = db.collection('payments');

  final payments = [
    {
      'paymentId': 'payment_1',
      'sessionId': 'session_1',
      'playerId': kOrganizerUid,
      'playerName': 'Azri',
      'amount': 25.0,
      'status': 'paid',
      'transactionRef': 'FPX-20260509-001',
      'paidAt': FieldValue.serverTimestamp(),
    },
    {
      'paymentId': 'payment_2',
      'sessionId': 'session_1',
      'playerId': kPlayerUid,
      'playerName': 'Syafiq',
      'amount': 25.0,
      'status': 'unpaid',
      'transactionRef': null,
      'paidAt': null,
    },
    {
      'paymentId': 'payment_3',
      'sessionId': 'session_1',
      'playerId': 'player_3',
      'playerName': 'Danial',
      'amount': 25.0,
      'status': 'paid',
      'transactionRef': 'FPX-20260509-002',
      'paidAt': FieldValue.serverTimestamp(),
    },
    {
      'paymentId': 'payment_4',
      'sessionId': 'session_1',
      'playerId': 'player_4',
      'playerName': 'Hafiz',
      'amount': 25.0,
      'status': 'unpaid',
      'transactionRef': null,
      'paidAt': null,
    },
  ];

  for (final payment in payments) {
    await col.doc(payment['paymentId'] as String).set(payment);
  }
}

// ── cancellations ─────────────────────────────────────────────────────────────
Future<void> _seedCancellations(FirebaseFirestore db) async {
  final col = db.collection('cancellations');

  await col.doc('cancellation_1').set({
    'cancellationId': 'cancellation_1',
    'venueId': 'venue_1',
    'sessionId': 'session_1',
    'organizerId': kOrganizerUid,
    'organizerName': 'Azri',
    'court': 'Court 1',
    'timeRange': '8:00 PM – 10:00 PM',
    'dateLabel': '9 May 2026, Friday',
    'dateTimestamp': Timestamp.fromDate(DateTime(2026, 5, 9, 20)),
    'lostRevenue': 120.0,
    'depositCollected': 50.0,
    'noticeHours': 2,
    'createdAt': FieldValue.serverTimestamp(),
  });
}

// ── waitlist ──────────────────────────────────────────────────────────────────
Future<void> _seedWaitlist(FirebaseFirestore db) async {
  final col = db.collection('waitlist');

  // Two players waiting for session_1
  // In production, position is assigned via Firestore transaction.
  // Seeding with hardcoded positions for dev only.
  final entries = [
    {
      'waitlistId': 'waitlist_1',
      'sessionId': 'session_1',
      'playerId': 'player_6',
      'playerName': 'Faiz',
      'position': 1,
      'joinedAt': FieldValue.serverTimestamp(),
      'status': 'waiting',
    },
    {
      'waitlistId': 'waitlist_2',
      'sessionId': 'session_1',
      'playerId': 'player_7',
      'playerName': 'Izzat',
      'position': 2,
      'joinedAt': FieldValue.serverTimestamp(),
      'status': 'waiting',
    },
  ];

  for (final entry in entries) {
    await col.doc(entry['waitlistId'] as String).set(entry);
  }
}