import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/models.dart';
import '../../../repositories/session_repository.dart';
import '../../../repositories/venue_repository.dart';
import '../../../repositories/availability_repository.dart';

class CreateSessionViewModel extends ChangeNotifier {
  final SessionRepository _repo;
  final VenueRepository _venueRepo;
  final AvailabilityRepository? _availabilityRepo;
  final String organizerId;

  String selectedSport = 'Futsal';
  int maxPlayers = 12;
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool isSaving = false;
  bool isLoadingVenues = false;
  String? errorMessage;
  List<Venue> venues = [];
  Venue? selectedVenue;
  String? selectedCourt;

  CreateSessionViewModel({
    required SessionRepository sessionRepo,
    required VenueRepository venueRepo,
    AvailabilityRepository? availabilityRepo,
    required this.organizerId,
  })  : _repo = sessionRepo,
        _venueRepo = venueRepo,
        _availabilityRepo = availabilityRepo {
    _loadVenues();
  }

  Future<void> _loadVenues() async {
    isLoadingVenues = true;
    notifyListeners();
    try {
      venues = await _venueRepo.getAllVenues();
    } catch (_) {
      venues = [];
    } finally {
      isLoadingVenues = false;
      notifyListeners();
    }
  }

  void setSport(String sport) {
    selectedSport = sport;
    notifyListeners();
  }

  void setMaxPlayers(int value) {
    maxPlayers = value;
    notifyListeners();
  }

  void setDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  void setStartTime(TimeOfDay time) {
    startTime = time;
    notifyListeners();
  }

  void setEndTime(TimeOfDay time) {
    endTime = time;
    notifyListeners();
  }

  void setVenue(Venue venue) {
    selectedVenue = venue;
    // Reset court when venue changes - previous court no longer valid.
    selectedCourt = null;
    notifyListeners();
  }

  void setCourt(String court) {
    selectedCourt = court;
    notifyListeners();
  }

  /// Courts available for the currently selected venue.
  List<String> get availableCourts => selectedVenue?.courts ?? [];

  Future<bool> createSession({
    required String cost,
    required String notes,
  }) async {
    if (selectedVenue == null ||
        selectedDate == null ||
        startTime == null ||
        endTime == null) {
      errorMessage = 'Please fill in Venue, Date, Start Time, and End Time.';
      notifyListeners();
      return false;
    }

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      final courtIndex = selectedCourt != null
          ? selectedVenue!.courts.indexOf(selectedCourt!)
          : -1;
      final slotStart = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        startTime!.hour,
      );
      final slotEnd = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        endTime!.hour,
      );

      if (_availabilityRepo != null && courtIndex >= 0) {
        final available = await _availabilityRepo
            .isSlotAvailable(selectedVenue!.venueId, courtIndex, slotStart, slotEnd);
        if (!available) {
          errorMessage =
              'This slot is not available for booking (blocked or already booked).';
          isSaving = false;
          notifyListeners();
          return false;
        }
      }

      final dateStr = DateFormat('EEEE, d MMMM').format(selectedDate!);
      final timeStr = '${_formatTime(startTime!)}-${_formatTime(endTime!)}';
      final sessionId = await _repo.createSession({
        'sport': selectedSport,
        'organizerId': organizerId,
        'venueId': selectedVenue!.venueId,
        'venueName': selectedVenue!.name,
        'court': selectedCourt ?? '',
        'date': dateStr,
        'dateTimestamp': selectedDate!,
        'time': timeStr,
        'maxPlayers': maxPlayers,
        'costPerPlayer': double.tryParse(cost.trim()) ?? 0.0,
        'notes': notes.trim(),
        'status': 'upcoming',
      }).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException(
          'Session creation timed out - check Firestore security rules.',
        ),
      );

      if (_availabilityRepo != null && courtIndex >= 0) {
        await _availabilityRepo.markSlotBooked(
          selectedVenue!.venueId, courtIndex, slotStart, slotEnd, sessionId,
        );
      }
      return true;
    } catch (e) {
      if (e is TimeoutException) {
        errorMessage = 'Request timed out. Check Firestore security rules.';
      } else if (e.toString().contains('permission-denied') ||
          e.toString().contains('PERMISSION_DENIED')) {
        errorMessage = 'Permission denied. Update Firestore security rules.';
      } else {
        errorMessage = 'Failed to create session: $e';
      }
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }
}
