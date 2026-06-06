import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../auth/auth_viewmodel.dart';

/// Role selection screen shown after a user enters their email/password.
///
/// The user picks Player, Organizer, or Venue Owner. Their choice is
/// written to Firestore via [AuthViewModel.register] and they are
/// navigated to their role's home screen.
class RoleSelectionScreen extends StatefulWidget {
  RoleSelectionScreen({
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
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        title: Text('Choose Your Role'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What brings you to CourtCall?',
                style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: 4.0),
            Text('You can only have one role per account.',
                style: Theme.of(context).textTheme.bodySmall),
            SizedBox(height: 24.0),

            // ── Name field ──────────────────────────────────────────
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Full Name',
                hintText: 'e.g. Hussein Ahmad',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            SizedBox(height: 24.0),

            // ── Error banner ────────────────────────────────────────
            if (vm.errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Theme.of(context).colorScheme.error),
                ),
                child: Text(
                  vm.errorMessage!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
                ),
              ),
              SizedBox(height: 16.0),
            ],

            // ── Role cards ──────────────────────────────────────────
            for (final option in _roles) ...[
              _RoleCard(
                option: option,
                isSelected: _selectedRole == option.role,
                onTap: () =>
                    setState(() => _selectedRole = option.role),
              ),
              SizedBox(height: 8.0),
            ],
            SizedBox(height: 24.0),

            // ── Continue button ─────────────────────────────────────
            ElevatedButton(
              onPressed:
                  (vm.isLoading || _selectedRole == null)
                      ? null
                      : () => _register(context, vm),
              child: vm.isLoading
                  ? SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    )
                  : Text('Continue'),
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
        SnackBar(content: Text('Please enter your name.')),
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
        'organizer'   => '/organizer/dashboard',
        'venue_owner' => '/venue/setup',
        _             => '/player/session-feed',
      };
      context.go(route);
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
  _RoleCard({
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
        duration: Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.06)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outlineVariant,
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
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(
                option.icon,
                color: isSelected
                    ? Theme.of(context).colorScheme.surface
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.title,
                      style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 2),
                  Text(option.subtitle,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary, size: 22),
          ],
        ),
      ),
    );
  }
}
