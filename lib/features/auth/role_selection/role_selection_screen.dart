import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_viewmodel.dart';
import '../../../core/theme/app_colors.dart';
import '../../organizer/dashboard/dashboard_screen.dart';
import '../../venue/venue_dashboard/venue_dashboard_screen.dart';
import '../../../core/widgets/player_shell_screen.dart';

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
      role: 'organizer',
      title: 'Session Organizer',
      subtitle: 'I book courts and run sessions',
      icon: Icons.monitor_heart_outlined,
    ),
    _RoleOption(
      role: 'player',
      title: 'Regular Player',
      subtitle: 'I join sessions and pay my share',
      icon: Icons.person_outline_rounded,
    ),
    _RoleOption(
      role: 'venue_owner',
      title: 'Venue Owner',
      subtitle: 'I manage courts and track',
      icon: Icons.store_mall_directory_outlined,
    ),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canContinue =>
      _selectedRole != null && _nameController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              const Text(
                'I am joining as...',
                style: TextStyle(
                  color: AppColors.darkNavy,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 24),

              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.darkNavy,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Full Name',
                  hintStyle:
                      const TextStyle(color: AppColors.textLight, fontSize: 15),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.outline, width: 1.4),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.accentGreen, width: 1.8),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (vm.errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.redLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          vm.errorMessage!,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              Expanded(
                child: ListView(
                  children: [
                    for (final option in _roles) ...[
                      _RoleCard(
                        option: option,
                        isSelected: _selectedRole == option.role,
                        onTap: () =>
                            setState(() => _selectedRole = option.role),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ],
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: (vm.isLoading || !_canContinue)
                      ? null
                      : () => _register(context, vm),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkNavy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    disabledBackgroundColor:
                        AppColors.darkNavy.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: vm.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
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
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => switch (_selectedRole!) {
            'organizer' => const DashboardScreen(),
            'venue_owner' => const VenueDashboardScreen(),
            _ => const PlayerShellScreen(),
          },
        ),
        (_) => false,
      );
    }
  }
}

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

class _RoleCard extends StatelessWidget {
  final _RoleOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  static const Color _selectedBg = Color(0xFFF0FBF5);
  static const Color _selectedBorder = Color(0xFFB8EDD5);
  static const Color _mutedIcon = Color(0xFF6B7A99);
  static const Color _mutedCircleBg = Color(0xFFF0F2F6);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? _selectedBg : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _selectedBorder : AppColors.outline,
            width: isSelected ? 1.8 : 1.4,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accentGreen.withValues(alpha: 0.10),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentGreen.withValues(alpha: 0.12)
                      : _mutedCircleBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  option.icon,
                  size: 24,
                  color: isSelected ? AppColors.accentGreen : _mutedIcon,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: const TextStyle(
                        color: AppColors.darkNavy,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      option.subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isSelected
                    ? Container(
                        key: const ValueKey('checked'),
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: AppColors.accentGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 14,
                        ),
                      )
                    : const SizedBox(
                        key: ValueKey('unchecked'),
                        width: 24,
                        height: 24,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
