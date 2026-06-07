import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../repositories/venue_repository.dart';
import '../../auth/auth_viewmodel.dart';
import '../../auth/login/login_screen.dart';
import '../venue_dashboard/venue_dashboard_screen.dart';
import 'venue_setup_viewmodel.dart';

class VenueSetupScreen extends StatefulWidget {
  const VenueSetupScreen({super.key});

  @override
  State<VenueSetupScreen> createState() => _VenueSetupScreenState();
}

class _VenueSetupScreenState extends State<VenueSetupScreen> {
  late final VenueSetupViewModel _viewModel;
  late final TextEditingController _venueNameCtrl;
  late final TextEditingController _addressCtrl;
  final List<TextEditingController> _courtNameCtrls = [];

  @override
  void initState() {
    super.initState();
    final repo = context.read<VenueRepository>();
    _viewModel = VenueSetupViewModel(repo: repo);
    _viewModel.addListener(_onStateChanged);

    _venueNameCtrl = TextEditingController();
    _addressCtrl = TextEditingController();

    _venueNameCtrl.addListener(() => _viewModel.setVenueName(_venueNameCtrl.text));
    _addressCtrl.addListener(() => _viewModel.setAddress(_addressCtrl.text));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthViewModel>().currentUser;
      if (user != null) {
        _viewModel.checkExistingVenue(user.uid);
      }
    });
  }

  void _syncCourtControllers() {
    final names = _viewModel.state.courtNames;
    while (_courtNameCtrls.length < names.length) {
      final i = _courtNameCtrls.length;
      final ctrl = TextEditingController(text: names[i]);
      ctrl.addListener(() => _viewModel.setCourtName(i, ctrl.text));
      _courtNameCtrls.add(ctrl);
    }
    while (_courtNameCtrls.length > names.length) {
      _courtNameCtrls.removeLast().dispose();
    }
    for (int i = 0; i < names.length; i++) {
      if (_courtNameCtrls[i].text != names[i]) {
        _courtNameCtrls[i].text = names[i];
      }
    }
  }

  void _onStateChanged() {
    if (!mounted) return;
    final s = _viewModel.state;
    if (s.successVenueId != null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => VenueDashboardScreen(venueId: s.successVenueId),
        ),
        (_) => false,
      );
      return;
    }
    _syncCourtControllers();
    setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onStateChanged);
    _viewModel.dispose();
    _venueNameCtrl.dispose();
    _addressCtrl.dispose();
    for (final c in _courtNameCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = _viewModel.state;
    if (s.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
          ),
        ),
        title: const Text(
          'Setup Your Venue',
          style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Venue Name *',
              child: TextField(
                controller: _venueNameCtrl,
                decoration: _inputDecoration('e.g. Nexus Futsal'),
                textCapitalization: TextCapitalization.words,
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Address *',
              child: TextField(
                controller: _addressCtrl,
                decoration: _inputDecoration('e.g. Jalan Ampang, Kuala Lumpur'),
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Number of Courts *',
              child: Row(
                children: [
                  _IconBtn(
                    icon: Icons.remove_circle_outline,
                    onTap: s.courtCount > 1 ? () => _viewModel.setCourtCount(s.courtCount - 1) : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${s.courtCount}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                  ),
                  const SizedBox(width: 12),
                  _IconBtn(
                    icon: Icons.add_circle_outline,
                    onTap: s.courtCount < 10 ? () => _viewModel.setCourtCount(s.courtCount + 1) : null,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    s.courtCount == 1 ? 'court' : 'courts',
                    style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Court Names *',
              child: Column(
                children: List.generate(s.courtCount, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextField(
                      decoration: _inputDecoration('Court ${i + 1}')
                          .copyWith(suffixText: 'Court ${i + 1}'),
                      controller: _courtNameCtrls.length > i ? _courtNameCtrls[i] : null,
                      textCapitalization: TextCapitalization.words,
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Operating Hours *',
              child: Row(
                children: [
                  Expanded(
                    child: _HourPicker(
                      label: 'Opens',
                      hour: s.startHour,
                      onChanged: (h) => _viewModel.setStartHour(h),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: const Text('to', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14)),
                  ),
                  Expanded(
                    child: _HourPicker(
                      label: 'Closes',
                      hour: s.endHour,
                      onChanged: (h) => _viewModel.setEndHour(h),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildVenuePhotoSection(s),
            if (s.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  s.errorMessage!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: s.isFormValid && !s.isSaving
                    ? () => _submit()
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  disabledBackgroundColor: AppColors.outline,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: s.isSaving
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onSecondary,
                        ),
                      )
                    : Text(
                        'Create Venue',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSecondary,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVenuePhotoSection(VenueSetupState s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Venue Photo (optional)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _viewModel.pickImage,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: s.venueImage != null
                    ? const Color(0xFF0D7A3E)
                    : const Color(0xFFE5E7EB),
                width: 1.5,
              ),
            ),
            child: s.venueImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.file(
                      s.venueImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 40,
                        color: Color(0xFF9CA3AF),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add Venue Photo',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tap to choose from gallery',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (s.isUploadingImage)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF0D7A3E),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Uploading photo...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _submit() async {
    final user = context.read<AuthViewModel>().currentUser;
    if (user == null) return;
    await _viewModel.createVenue(user.uid, user.name);
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.outline),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _IconBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: onTap == null ? AppColors.outline : AppColors.secondary, size: 28),
    );
  }
}

class _HourPicker extends StatelessWidget {
  final String label;
  final int hour;
  final ValueChanged<int> onChanged;

  const _HourPicker({
    required this.label,
    required this.hour,
    required this.onChanged,
  });

  String get _display {
    final period = hour < 12 ? 'AM' : 'PM';
    final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$h:00 $period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onChanged(hour - 1),
            child: const Icon(Icons.remove, size: 18, color: AppColors.secondary),
          ),
          Expanded(
            child: Column(
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.onSurfaceVariant)),
                Text(_display,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(hour + 1),
            child: const Icon(Icons.add, size: 18, color: AppColors.secondary),
          ),
        ],
      ),
    );
  }
}
