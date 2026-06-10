import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../../repositories/venue_repository.dart';
import '../../../core/services/cloudinary_service.dart';

class VenueSetupState {
  final String venueName;
  final String address;
  final int courtCount;
  final List<String> courtNames;
  final int startHour;
  final int endHour;
  final bool isLoading;
  final bool isSaving;
  final bool isUploadingImage;
  final File? venueImage;
  final String? errorMessage;
  final String? successVenueId;
  final String? originalVenueId;

  const VenueSetupState({
    this.venueName = '',
    this.address = '',
    this.courtCount = 1,
    this.courtNames = const ['Court 1'],
    this.startHour = 8,
    this.endHour = 22,
    this.isLoading = false,
    this.isSaving = false,
    this.isUploadingImage = false,
    this.venueImage,
    this.errorMessage,
    this.successVenueId,
    this.originalVenueId,
  });

  bool get isEditing => originalVenueId != null;

  VenueSetupState copyWith({
    String? venueName,
    String? address,
    int? courtCount,
    List<String>? courtNames,
    int? startHour,
    int? endHour,
    bool? isLoading,
    bool? isSaving,
    bool? isUploadingImage,
    File? venueImage,
    String? errorMessage,
    String? successVenueId,
    String? originalVenueId,
  }) {
    return VenueSetupState(
      venueName: venueName ?? this.venueName,
      address: address ?? this.address,
      courtCount: courtCount ?? this.courtCount,
      courtNames: courtNames ?? this.courtNames,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      venueImage: venueImage ?? this.venueImage,
      errorMessage: errorMessage ?? this.errorMessage,
      successVenueId: successVenueId ?? this.successVenueId,
      originalVenueId: originalVenueId ?? this.originalVenueId,
    );
  }

  bool get isFormValid =>
      venueName.trim().isNotEmpty &&
      address.trim().isNotEmpty &&
      courtCount >= 1 &&
      courtNames.every((name) => name.trim().isNotEmpty);
}

class VenueSetupViewModel extends ChangeNotifier {
  final VenueRepository _repo;
  VenueSetupState _state = const VenueSetupState();

  VenueSetupState get state => _state;

  final _picker = ImagePicker();
  final _cloudinary = CloudinaryService();

  VenueSetupViewModel({required VenueRepository repo}) : _repo = repo;

  Future<void> pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1080,
    );
    if (picked != null) {
      _state = _state.copyWith(venueImage: File(picked.path));
      notifyListeners();
    }
  }

  Future<void> checkExistingVenue(String ownerId) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final venue = await _repo.getVenueByOwnerId(ownerId);
    if (venue != null) {
      _state = _state.copyWith(
        isLoading: false,
        successVenueId: venue['venueId'] as String?,
      );
    } else {
      _state = _state.copyWith(isLoading: false);
    }
    notifyListeners();
  }

  Future<void> loadVenueForEditing(String venueId) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final venue = await _repo.getVenueById(venueId);
    if (venue != null) {
      final courts = (venue['courts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['Court 1'];
      _state = _state.copyWith(
        isLoading: false,
        originalVenueId: venueId,
        venueName: venue['name'] as String? ?? '',
        address: venue['address'] as String? ?? '',
        courtCount: courts.length,
        courtNames: courts,
        startHour: 8,
        endHour: 22,
      );
    } else {
      _state = _state.copyWith(isLoading: false);
    }
    notifyListeners();
  }

  void setVenueName(String value) {
    _state = _state.copyWith(venueName: value);
    notifyListeners();
  }

  void setAddress(String value) {
    _state = _state.copyWith(address: value);
    notifyListeners();
  }

  void setCourtCount(int count) {
    final clamped = count.clamp(1, 10);
    final names = List.generate(clamped, (i) {
      if (i < _state.courtNames.length &&
          _state.courtNames[i].startsWith('Court')) {
        return _state.courtNames[i];
      }
      return 'Court ${i + 1}';
    });
    _state = _state.copyWith(courtCount: clamped, courtNames: names);
    notifyListeners();
  }

  void setCourtName(int index, String name) {
    final names = List<String>.from(_state.courtNames);
    if (index < names.length) {
      names[index] = name;
      _state = _state.copyWith(courtNames: names);
      notifyListeners();
    }
  }

  void setStartHour(int hour) {
    _state = _state.copyWith(startHour: hour.clamp(0, _state.endHour - 1));
    notifyListeners();
  }

  void setEndHour(int hour) {
    _state = _state.copyWith(endHour: hour.clamp(_state.startHour + 1, 23));
    notifyListeners();
  }

  Future<void> createVenue(String ownerId, String ownerName) async {
    if (!_state.isFormValid) return;

    _state = _state.copyWith(isSaving: true, errorMessage: null);
    notifyListeners();

    try {
      final venueId = await _repo.createVenue({
        'ownerId': ownerId,
        'ownerName': ownerName,
        'name': _state.venueName.trim(),
        'address': _state.address.trim(),
        'courts': _state.courtNames.map((n) => n.trim()).toList(),
      });

      // Upload image after venue created
      if (_state.venueImage != null) {
        _state = _state.copyWith(isUploadingImage: true);
        notifyListeners();

        final imageUrl = await _cloudinary.uploadVenueImage(
          _state.venueImage!,
          venueId,
        );

        if (imageUrl != null) {
          await _repo.updateVenueImage(venueId, imageUrl);
        }

        _state = _state.copyWith(isUploadingImage: false);
        notifyListeners();
      }

      await _repo.generateSlots(
        venueId,
        _state.courtCount,
        _state.startHour,
        _state.endHour,
      );

      _state = _state.copyWith(
        isSaving: false,
        successVenueId: venueId,
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        isSaving: false,
        errorMessage: e.toString(),
      );
      notifyListeners();
    }
  }

  Future<void> updateVenue() async {
    if (!_state.isFormValid) return;

    _state = _state.copyWith(isSaving: true, errorMessage: null);
    notifyListeners();

    try {
      await _repo.updateVenue(_state.originalVenueId!, {
        'name': _state.venueName.trim(),
        'address': _state.address.trim(),
        'courts': _state.courtNames.map((n) => n.trim()).toList(),
      });

      if (_state.venueImage != null) {
        _state = _state.copyWith(isUploadingImage: true);
        notifyListeners();

        final imageUrl = await _cloudinary.uploadVenueImage(
          _state.venueImage!,
          _state.originalVenueId!,
        );

        if (imageUrl != null) {
          await _repo.updateVenueImage(_state.originalVenueId!, imageUrl);
        }

        _state = _state.copyWith(isUploadingImage: false);
        notifyListeners();
      }

      _state = _state.copyWith(
        isSaving: false,
        successVenueId: _state.originalVenueId,
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        isSaving: false,
        errorMessage: e.toString(),
      );
      notifyListeners();
    }
  }
}
