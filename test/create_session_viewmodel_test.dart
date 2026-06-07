import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:courtcall/repositories/mocks/mock_session_repository.dart';
import 'package:courtcall/features/organizer/create_session/create_session_viewmodel.dart';

void main() {
  late MockSessionRepository repo;
  late CreateSessionViewModel vm;

  setUp(() {
    repo = MockSessionRepository();
    vm = CreateSessionViewModel(repo: repo);
  });

  tearDown(() {
    vm.dispose();
    repo.dispose();
  });

  group('CreateSessionViewModel —', () {
    test('default sport is Futsal', () {
      expect(vm.selectedSport, 'Futsal');
    });

    test('default maxPlayers is 12', () {
      expect(vm.maxPlayers, 12);
    });

    test('default selectedDate is null', () {
      expect(vm.selectedDate, isNull);
    });

    test('default startTime is null', () {
      expect(vm.startTime, isNull);
    });

    test('default endTime is null', () {
      expect(vm.endTime, isNull);
    });

    test('default isSaving is false', () {
      expect(vm.isSaving, isFalse);
    });

    test('default errorMessage is null', () {
      expect(vm.errorMessage, isNull);
    });

    test('setSport updates selectedSport', () {
      vm.setSport('Basketball');
      expect(vm.selectedSport, 'Basketball');
    });

    test('setSport notifies listeners', () {
      int count = 0;
      vm.addListener(() => count++);
      vm.setSport('Volleyball');
      expect(count, 1);
    });

    test('setMaxPlayers updates maxPlayers', () {
      vm.setMaxPlayers(6);
      expect(vm.maxPlayers, 6);
    });

    test('setMaxPlayers notifies listeners', () {
      int count = 0;
      vm.addListener(() => count++);
      vm.setMaxPlayers(8);
      expect(count, 1);
    });

    test('setDate stores the date', () {
      final date = DateTime(2026, 7, 15);
      vm.setDate(date);
      expect(vm.selectedDate, date);
    });

    test('setDate notifies listeners', () {
      int count = 0;
      vm.addListener(() => count++);
      vm.setDate(DateTime(2026, 7, 15));
      expect(count, 1);
    });

    test('setStartTime stores the time', () {
      const time = TimeOfDay(hour: 20, minute: 0);
      vm.setStartTime(time);
      expect(vm.startTime, time);
    });

    test('setEndTime stores the time', () {
      const time = TimeOfDay(hour: 22, minute: 0);
      vm.setEndTime(time);
      expect(vm.endTime, time);
    });

    test('createSession fails when venue is empty', () async {
      vm.setDate(DateTime(2026, 7, 15));
      vm.setStartTime(const TimeOfDay(hour: 20, minute: 0));
      vm.setEndTime(const TimeOfDay(hour: 22, minute: 0));

      final result = await vm.createSession(venue: '', cost: '15', notes: '');
      expect(result, isFalse);
    });

    test('createSession sets errorMessage when venue is empty', () async {
      vm.setDate(DateTime(2026, 7, 15));
      vm.setStartTime(const TimeOfDay(hour: 20, minute: 0));
      vm.setEndTime(const TimeOfDay(hour: 22, minute: 0));

      await vm.createSession(venue: '', cost: '15', notes: '');
      expect(vm.errorMessage, isNotNull);
    });

    test('createSession fails when selectedDate is null', () async {
      vm.setStartTime(const TimeOfDay(hour: 20, minute: 0));
      vm.setEndTime(const TimeOfDay(hour: 22, minute: 0));

      final result = await vm.createSession(venue: 'Test Venue', cost: '15', notes: '');
      expect(result, isFalse);
      expect(vm.errorMessage, isNotNull);
    });

    test('createSession fails when startTime is null', () async {
      vm.setDate(DateTime(2026, 7, 15));
      vm.setEndTime(const TimeOfDay(hour: 22, minute: 0));

      final result = await vm.createSession(venue: 'Test Venue', cost: '15', notes: '');
      expect(result, isFalse);
    });

    test('createSession fails when endTime is null', () async {
      vm.setDate(DateTime(2026, 7, 15));
      vm.setStartTime(const TimeOfDay(hour: 20, minute: 0));

      final result = await vm.createSession(venue: 'Test Venue', cost: '15', notes: '');
      expect(result, isFalse);
    });

    test('createSession succeeds with all required fields', () async {
      vm.setDate(DateTime(2026, 7, 15));
      vm.setStartTime(const TimeOfDay(hour: 20, minute: 0));
      vm.setEndTime(const TimeOfDay(hour: 22, minute: 0));

      final result = await vm.createSession(venue: 'Nexus Futsal', cost: '15', notes: '');
      expect(result, isTrue);
    });

    test('isSaving is false after createSession completes', () async {
      vm.setDate(DateTime(2026, 7, 15));
      vm.setStartTime(const TimeOfDay(hour: 20, minute: 0));
      vm.setEndTime(const TimeOfDay(hour: 22, minute: 0));

      await vm.createSession(venue: 'Test Venue', cost: '15', notes: '');
      expect(vm.isSaving, isFalse);
    });

    test('createSession success clears errorMessage', () async {
      // trigger an error first
      await vm.createSession(venue: '', cost: '15', notes: '');
      expect(vm.errorMessage, isNotNull);

      vm.setDate(DateTime(2026, 7, 15));
      vm.setStartTime(const TimeOfDay(hour: 20, minute: 0));
      vm.setEndTime(const TimeOfDay(hour: 22, minute: 0));
      await vm.createSession(venue: 'Test Venue', cost: '15', notes: '');
      expect(vm.errorMessage, isNull);
    });

    test('createSession adds session to repository', () async {
      vm.setDate(DateTime(2026, 7, 15));
      vm.setStartTime(const TimeOfDay(hour: 20, minute: 0));
      vm.setEndTime(const TimeOfDay(hour: 22, minute: 0));
      await vm.createSession(venue: 'New Venue', cost: '20', notes: '');

      final sessions = await repo.watchUpcomingSessions('org_1').first;
      expect(sessions.length, 4); // 3 initial + 1 created
    });
  });
}
