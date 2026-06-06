import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/auth_viewmodel.dart';
import 'role_selection_screen.dart';

/// Login screen — entry point for all roles.
///
/// Handles sign-in and navigates to [RoleSelectionScreen] for new users,
/// or directly to the role home screen for returning users.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isRegisterMode  = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xxl),

                // ── Logo / branding ───────────────────────────────────
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: const Icon(
                      Icons.sports_soccer,
                      color: AppColors.surfaceWhite,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: Text(
                    'CourtCall',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.primaryNavy,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'Book. Play. Connect.',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // ── Heading ───────────────────────────────────────────
                Text(
                  _isRegisterMode ? 'Create Account' : 'Welcome Back',
                  style: AppTextStyles.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _isRegisterMode
                      ? 'Sign up to start booking sessions'
                      : 'Sign in to continue',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Error banner ──────────────────────────────────────
                if (vm.errorMessage != null) ...[
                  _ErrorBanner(
                    message: vm.errorMessage!,
                    onDismiss: vm.clearError,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // ── Email field ───────────────────────────────────────
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email address';
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'you@example.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Password field ────────────────────────────────────
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(context, vm),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Primary action button ─────────────────────────────
                ElevatedButton(
                  onPressed: vm.isLoading ? null : () => _submit(context, vm),
                  child: vm.isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.surfaceWhite,
                          ),
                        )
                      : Text(_isRegisterMode ? 'Create Account' : 'Sign In'),
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Forgot password ───────────────────────────────────
                if (!_isRegisterMode)
                  Center(
                    child: TextButton(
                      onPressed: () => _forgotPassword(context, vm),
                      child: const Text('Forgot password?'),
                    ),
                  ),

                // ── Toggle register / login ───────────────────────────
                Center(
                  child: TextButton(
                    onPressed: () {
                      vm.clearError();
                      setState(() => _isRegisterMode = !_isRegisterMode);
                    },
                    child: Text(
                      _isRegisterMode
                          ? 'Already have an account? Sign In'
                          : "Don't have an account? Sign Up",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryNavy,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context, AuthViewModel vm) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email    = _emailController.text.trim();
    final password = _passwordController.text;

    if (_isRegisterMode) {
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RoleSelectionScreen(
            email: email,
            password: password,
          ),
        ),
      );
    } else {
      final success = await vm.signIn(email: email, password: password);
      if (success && context.mounted) {
        _navigateByRole(context, vm.currentUser?.role ?? 'player');
      }
    }
  }

  void _navigateByRole(BuildContext context, String role) {
    final route = switch (role) {
      'organizer'   => '/organizer_home',
      'venue_owner' => '/venue_owner_home',
      _             => '/player_home',
    };
    Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
  }

  Future<void> _forgotPassword(
      BuildContext context, AuthViewModel vm) async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Enter your email first, then tap Forgot password.')),
      );
      return;
    }
    await vm.sendPasswordReset(email);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent to $email')),
      );
    }
  }
}

// ── Error banner ──────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.declined.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.declined),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.declined, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.declined),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(Icons.close, color: AppColors.declined, size: 16),
          ),
        ],
      ),
    );
  }
}
