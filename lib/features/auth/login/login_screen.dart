import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:go_router/go_router.dart';
import '../../auth/auth_viewmodel.dart';
import '../role_selection/role_selection_screen.dart';

/// Login screen — entry point for all roles.
///
/// Handles sign-in and navigates to [RoleSelectionScreen] for new users,
/// or directly to the role home screen for returning users.
class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

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
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 48.0),

                // ── Logo / branding ───────────────────────────────────
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 72,
                    height: 72,
                  ),
                ),
                SizedBox(height: 16.0),
                Center(
                  child: Text(
                    'CourtCall',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'Book. Play. Connect.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                SizedBox(height: 48.0),

                // ── Heading ───────────────────────────────────────────
                Text(
                  _isRegisterMode ? 'Create Account' : 'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: 4.0),
                Text(
                  _isRegisterMode
                      ? 'Sign up to start booking sessions'
                      : 'Sign in to continue',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(height: 24.0),

                // ── Error banner ──────────────────────────────────────
                if (vm.errorMessage != null) ...[
                  _ErrorBanner(
                    message: vm.errorMessage!,
                    onDismiss: vm.clearError,
                  ),
                  SizedBox(height: 16.0),
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
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'you@example.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                SizedBox(height: 16.0),

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
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                SizedBox(height: 24.0),

                // ── Primary action button ─────────────────────────────
                ElevatedButton(
                  onPressed: vm.isLoading ? null : () => _submit(context, vm),
                  child: vm.isLoading
                      ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        )
                      : Text(_isRegisterMode ? 'Create Account' : 'Sign In'),
                ),
                SizedBox(height: 16.0),

                // ── Forgot password ───────────────────────────────────
                if (!_isRegisterMode)
                  Center(
                    child: TextButton(
                      onPressed: () => _forgotPassword(context, vm),
                      child: Text('Forgot password?'),
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
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
      'organizer'   => '/organizer/dashboard',
      'venue_owner' => '/venue/setup',
      _             => '/player/session-feed',
    };
    context.go(route);
  }

  Future<void> _forgotPassword(
      BuildContext context, AuthViewModel vm) async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
  _ErrorBanner({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Theme.of(context).colorScheme.error),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 18),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(Icons.close, color: Theme.of(context).colorScheme.error, size: 16),
          ),
        ],
      ),
    );
  }
}
