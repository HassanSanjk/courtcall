import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../models/models.dart';
import '../../../repositories/player_repository.dart';

/// ViewModel for [PaymentHistoryScreen].
///
/// Provides:
///   - Stream of all player payments
///   - Filter state (All / Paid / Pending)
///   - Total outstanding and total paid amounts
///   - Mark-as-paid action
class PaymentHistoryViewModel extends ChangeNotifier {
  PaymentHistoryViewModel({
    required PlayerRepository repository,
    required String playerId,
  })  : _repo = repository,
        _playerId = playerId {
    _init();
  }

  final PlayerRepository _repo;
  final String _playerId;

  List<Payment> _allPayments = [];
  PaymentFilter _activeFilter = PaymentFilter.all;
  bool _isLoading = true;
  bool _isMarkingPaid = false;
  String? _errorMessage;

  StreamSubscription<List<Payment>>? _paymentsSub;

  String get playerId => _playerId;

  PaymentFilter get activeFilter  => _activeFilter;
  bool get isLoading     => _isLoading;
  bool get isMarkingPaid => _isMarkingPaid;
  String? get errorMessage => _errorMessage;

  List<Payment> get filteredPayments => switch (_activeFilter) {
        PaymentFilter.all     => _allPayments,
        PaymentFilter.paid    => _allPayments.where((p) => p.isPaid).toList(),
        PaymentFilter.pending => _allPayments.where((p) => p.isUnpaid).toList(),
      };

  double get totalOutstanding =>
      _allPayments.where((p) => p.isUnpaid).fold(0.0, (s, p) => s + p.amount);

  double get totalPaid =>
      _allPayments.where((p) => p.isPaid).fold(0.0, (s, p) => s + p.amount);

  bool get hasOutstanding => totalOutstanding > 0;

  void setFilter(PaymentFilter filter) {
    if (_activeFilter == filter) return;
    _activeFilter = filter;
    notifyListeners();
  }

  void _init() {
    _paymentsSub = _repo
        .watchPlayerPayments(_playerId)
        .listen(_onPaymentsUpdate, onError: _onError);
  }

  void _onPaymentsUpdate(List<Payment> payments) {
    // Stable sort: unpaid first, then by sessionDate descending within each group.
    _allPayments = List.of(payments)
      ..sort((a, b) {
        if (a.isUnpaid && b.isPaid)  return -1;
        if (a.isPaid  && b.isUnpaid) return 1;
        final dateA = a.sessionDate ?? '';
        final dateB = b.sessionDate ?? '';
        return dateB.compareTo(dateA);
      });
    _isLoading = false;
    notifyListeners();
  }

  void _onError(Object error) {
    _errorMessage = 'Failed to load payments. Please try again.';
    _isLoading = false;
    notifyListeners();
  }

  Future<void> markPaid(String paymentId) async {
    // Guard against double-tap while a payment is already being processed.
    if (_isMarkingPaid) return;
    _isMarkingPaid = true;
    notifyListeners();
    try {
      final ref = 'MOCK-${DateTime.now().millisecondsSinceEpoch}';
      await _repo.markPaid(paymentId: paymentId, transactionRef: ref);
    } catch (_) {
      _errorMessage = 'Payment failed. Please try again.';
    } finally {
      _isMarkingPaid = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _paymentsSub?.cancel();
    super.dispose();
  }
}

enum PaymentFilter { all, paid, pending }
