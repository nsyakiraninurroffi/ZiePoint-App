// login_page.dart - cleaned version
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/validators.dart';
import '../viewmodels/login_viewmodel.dart';
import '../services/notification_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _identityController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identityController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<LoginViewModel>();
    bool success;
    if (vm.isGuruMode) {
      success = await vm.loginGuru(
        _identityController.text.trim(),
        _passwordController.text.trim(),
      );
    } else {
      success = await vm.loginSiswa(
        _identityController.text.trim(),
        _passwordController.text.trim(),
      );
    }

    if (!mounted) return;
    if (success) {
      NotificationService.showSuccess(context, 'Login berhasil! Selamat datang.');
      if (vm.role == 'guru') {
        context.go('/teacher');
      } else {
        context.go('/student');
      }
    } else if (vm.errorMessage != null) {
      NotificationService.showError(context, vm.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        children: [
                          const Spacer(flex: 2),
                          _buildHeader(),
                          const SizedBox(height: 48),
                          _buildGlassCard(),
                          const Spacer(flex: 3),
                          Text(
                            '© 2026 ZiePoint — School Discipline Manager',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11,
                            ),
                          ).animate().fadeIn(delay: 1200.ms),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.4)),
          ),
          child: const Icon(
            Icons.shield_rounded,
            size: 48,
            color: Colors.white,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1, 1),
              curve: Curves.elasticOut,
              duration: 800.ms,
            ),
        const SizedBox(height: 20),
        const Text(
          'ZiePoint',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
        const SizedBox(height: 6),
        Text(
          'School Discipline Manager',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w400,
            letterSpacing: 1.5,
          ),
        ).animate().fadeIn(delay: 500.ms),
      ],
    );
  }

  Widget _buildGlassCard() {
    return Consumer<LoginViewModel>(
      builder: (context, vm, _) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ClipRRect(
              borderRadius: AppTheme.radiusLg,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppTheme.glassBg,
                    borderRadius: AppTheme.radiusLg,
                    border: Border.all(color: AppTheme.glassBorder, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildRoleToggle(vm),
                    const SizedBox(height: 24),
                    // Identity field
                    TextFormField(
                      controller: _identityController,
                      keyboardType: vm.isGuruMode ? TextInputType.emailAddress : TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _glassInputDecoration(
                        label: vm.isGuruMode ? 'Email Guru' : 'NIS Siswa',
                        icon: vm.isGuruMode ? Icons.email_rounded : Icons.badge_rounded,
                      ),
                      validator: (v) {
                        final req = Validators.required(v, vm.isGuruMode ? 'Email' : 'NIS');
                        if (req != null) return req;
                        if (vm.isGuruMode) return Validators.email(v, 'Email');
                        return Validators.numericOnly(v, 'NIS');
                      },
                    ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.1),
                    const SizedBox(height: 16),
                    // Password field with eye toggle
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white),
                      decoration: _glassInputDecoration(
                        label: 'Password',
                        icon: Icons.lock_rounded,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            color: AppTheme.accentLavender.withOpacity(0.6),
                            size: 22,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) => Validators.required(v, 'Password'),
                    ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.1),
                    const SizedBox(height: 28),
                    // Login button
                    Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: AppTheme.buttonGradient,
                        borderRadius: AppTheme.radiusMd,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentRose.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: vm.isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          disabledBackgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMd),
                          elevation: 0,
                        ),
                        child: vm.isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.login_rounded, size: 22),
                                  SizedBox(width: 10),
                                  Text(
                                    'MASUK',
                                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 2),
                                  ),
                                ],
                              ),
                      ),
                    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
                  ],
                ),
              ),
            ),
          ),
        ))).animate().fadeIn(delay: 400.ms, duration: 500.ms).slideY(begin: 0.15);
      },
    );
  }

  Widget _buildRoleToggle(LoginViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.glassBg.withOpacity(0.1),
        borderRadius: AppTheme.radiusMd,
      ),
      child: Row(
        children: [
          _roleChip('Guru', Icons.school_rounded, vm.isGuruMode, () {
            if (!vm.isGuruMode) {
              vm.toggleMode();
              _identityController.clear();
            }
          }),
          _roleChip('Siswa', Icons.person_rounded, !vm.isGuruMode, () {
            if (vm.isGuruMode) {
              vm.toggleMode();
              _identityController.clear();
            }
          }),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _roleChip(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.accentRose.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppTheme.accentRose.withOpacity(0.5) : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: isSelected ? AppTheme.accentRose : AppTheme.textLabel),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppTheme.textLabel,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _glassInputDecoration({required String label, required IconData icon, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppTheme.textLabel),
      prefixIcon: Icon(icon, color: AppTheme.textLabel),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(borderRadius: AppTheme.radiusSm, borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
      enabledBorder: OutlineInputBorder(borderRadius: AppTheme.radiusSm, borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
      focusedBorder: OutlineInputBorder(borderRadius: AppTheme.radiusSm, borderSide: BorderSide(color: AppTheme.accentRose, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: AppTheme.radiusSm, borderSide: BorderSide(color: AppTheme.errorRed, width: 1.5)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: AppTheme.radiusSm, borderSide: BorderSide(color: AppTheme.errorRed, width: 2)),
    );
  }
}
