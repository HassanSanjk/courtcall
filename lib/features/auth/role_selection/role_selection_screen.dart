import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/auth_viewmodel.dart';

/// Role selection screen shown after a user enters their email/password.
///
/// The user picks Player, Organizer, or Venue Owner. Their choice is
/// written to Firestore via [AuthViewModel.register] and they are
/// navigated to their role's home screen.
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({
    super.key,
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;
  final _nameController = TextEditingController();

  static const _roles = [
    _RoleOption(
      role: 'player',
      title: 'Player',
      subtitle: 'Join sessions, RSVP, and track payments',
      icon: Icons.sports_soccer,
    ),
    _RoleOption(
      role: 'organizer',
      title: 'Organizer',
      subtitle: 'Create and manage sessions, track RSVPs',
      icon: Icons.edit_calendar_outlined,
    ),
    _RoleOption(
      role: 'venue_owner',
      title: 'Venue Owner',
      subtitle: 'Manage availability and view revenue',
      icon: Icons.stadium_outlined,
    ),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: AppColors.backgroundAsh,
      appBar: AppBar(
        title: const Text('Choose Your Role'),
        backgroundColor: AppColors.backgroundAsh,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What brings you to CourtCall?',
                style: AppTextStyles.headlineMedium),
            const SizedBox(height: AppSpacing.xs),
            Text('You can only have one role per account.',
                style: AppTextStyles.bodySmall),
            const SizedBox(height: AppSpacing.lg),

            // ── Name field ──────────────────────────────────────────
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                hintText: 'e.g. Hussein Ahmad',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Error banner ────────────────────────────────────────
            if (vm.errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.declined.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.declined),
                ),
                child: Text(
                  vm.errorMessage!,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.declined),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // ── Role cards ──────────────────────────────────────────
            for (final option in _roles) ...[
              _RoleCard(
                option: option,
                isSelected: _selectedRole == option.role,
                onTap: () =>
                    setState(() => _selectedRole = option.role),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            const SizedBox(height: AppSpacing.lg),

            // ── Continue button ─────────────────────────────────────
            ElevatedButton(
              onPressed:
                  (vm.isLoading || _selectedRole == null)
                      ? null
                      : () => _register(context, vm),
              child: vm.isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.surfaceWhite,
                      ),
                    )
                  : const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _register(BuildContext context, AuthViewModel vm) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name.')),
      );
      return;
    }

    final success = await vm.register(
      name: name,
      email: widget.email,
      password: widget.password,
      role: _selectedRole!,
    );

    if (success && context.mounted) {
      final route = switch (_selectedRole!) {
        'organizer'   => '/organizer_home',
        'venue_owner' => '/venue_owner_home',
        _             => '/player_home',
      };
      Navigator.of(context)
          .pushNamedAndRemoveUntil(route, (_) => false);
    }
  }
}

// ── Role option data ──────────────────────────────────────────────────────────

class _RoleOption {
  const _RoleOption({
    required this.role,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String role;
  final String title;
  final String subtitle;
  final IconData icon;
}

// ── Role card widget ──────────────────────────────────────────────────────────

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _RoleOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryNavy.withValues(alpha: 0.06)
              : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryNavy
                : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryNavy
                    : AppColors.backgroundAsh,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                option.icon,
                color: isSelected
                    ? AppColors.surfaceWhite
                    : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.title,
                      style: AppTextStyles.titleMedium),
                  const SizedBox(height: 2),
                  Text(option.subtitle,
                      style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle,
                  color: AppColors.primaryNavy, size: 22),
          ],
        ),
      ),
    );
  }
}
