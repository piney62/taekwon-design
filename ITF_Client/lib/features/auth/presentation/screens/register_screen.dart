import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../settings/application/providers.dart';
import '../../../settings/domain/entities/belt_level.dart';
import '../../application/providers.dart';

// ── 3-step registration: role → credentials → role-specific ──────────────────

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  // step: 0=welcome, 1=login, 2=role, 3=credentials, 4=profile
  int _step = 0;
  bool _isLoginMode = false;

  String _role = 'student';

  final _usernameCtrl = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _nameCtrl     = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  bool _obscurePass    = true;
  bool _obscureConfirm = true;

  String _beltLevel = 'white';
  final _startYearCtrl  = TextEditingController();
  final _inviteCodeCtrl = TextEditingController();
  final _dojoNameCtrl   = TextEditingController();
  final _danRankCtrl    = TextEditingController();

  bool _isSaving = false;
  String? _error;

  static const _belts = ['white', 'yellow', 'green', 'blue', 'red', 'black'];

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _startYearCtrl.dispose();
    _inviteCodeCtrl.dispose();
    _dojoNameCtrl.dispose();
    _danRankCtrl.dispose();
    super.dispose();
  }

  void _goLogin() => setState(() {
        _isLoginMode = true;
        _step = 1;
        _error = null;
      });

  void _goRegister() => setState(() {
        _isLoginMode = false;
        _step = 2;
        _error = null;
      });

  void _back() {
    setState(() {
      _error = null;
      if (_isLoginMode) {
        _isLoginMode = false;
        _step = 0;
      } else if (_step <= 2) {
        _step = 0;
      } else {
        _step--;
      }
    });
  }

  bool get _credentialsOk {
    if (_usernameCtrl.text.trim().length < 3) return false;
    if (_nameCtrl.text.trim().isEmpty) return false;
    if (_passCtrl.text.length < 4) return false;
    if (_passCtrl.text != _confirmCtrl.text) return false;
    final email = _emailCtrl.text.trim();
    if (email.isNotEmpty && !_isValidEmail(email)) return false;
    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  bool get _studentFieldsOk {
    final text = _startYearCtrl.text.trim();
    if (text.isNotEmpty) {
      final year = int.tryParse(text);
      if (year == null || year < 1970 || year > DateTime.now().year) return false;
    }
    return true;
  }

  bool get _instructorFieldsOk => _dojoNameCtrl.text.trim().length >= 2;

  Future<void> _submitLogin() async {
    setState(() { _isSaving = true; _error = null; });
    try {
      await ref.read(authControllerProvider.notifier).login(
            username: _usernameCtrl.text.trim(),
            password: _passCtrl.text,
          );
    } catch (e) {
      final msg = e.toString();
      setState(() {
        _error = msg.contains('unauthorized') || msg.contains('401')
            ? 'auth.invalidCredentials'.tr()
            : msg.replaceFirst('Exception: ', '');
        _isSaving = false;
      });
    }
  }

  Future<void> _submitRegister() async {
    setState(() { _isSaving = true; _error = null; });
    try {
      final inviteCode = _inviteCodeCtrl.text.trim().toUpperCase();
      final email = _emailCtrl.text.trim();
      await ref.read(authControllerProvider.notifier).register(
            username: _usernameCtrl.text.trim(),
            displayName: _nameCtrl.text.trim(),
            password: _passCtrl.text,
            role: _role,
            email: email.isNotEmpty ? email : null,
            beltLevel: _role == 'student' ? _beltLevel : null,
            trainingStartYear: _role == 'student'
                ? int.tryParse(_startYearCtrl.text.trim())
                : null,
            dojoName: _role == 'instructor' ? _dojoNameCtrl.text.trim() : null,
            danRank: _role == 'instructor' && _danRankCtrl.text.trim().isNotEmpty
                ? _danRankCtrl.text.trim()
                : null,
            inviteCode: _role == 'student' && inviteCode.isNotEmpty
                ? inviteCode
                : null,
          );
      if (_role == 'student') {
        final belt = BeltLevel.values.firstWhere(
          (b) => b.name == _beltLevel,
          orElse: () => BeltLevel.white,
        );
        await ref.read(settingsControllerProvider.notifier).setBeltLevel(belt);
      }
    } catch (e) {
      final msg = e.toString();
      setState(() {
        _error = msg.contains('conflict') && msg.contains('email')
            ? 'auth.emailTaken'.tr()
            : msg.contains('conflict')
                ? 'auth.usernameTaken'.tr()
                : msg.replaceFirst('Exception: ', '');
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: ValueKey(_step * 2 + (_isLoginMode ? 1 : 0)),
          child: _buildCurrentStep(),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    if (_step == 0) {
      return _WelcomeView(onGetStarted: _goRegister, onLogin: _goLogin);
    }
    if (_isLoginMode) {
      return _LoginView(
        usernameCtrl: _usernameCtrl,
        passCtrl: _passCtrl,
        obscure: _obscurePass,
        onToggleObscure: () => setState(() => _obscurePass = !_obscurePass),
        onBack: _back,
        onSubmit: _submitLogin,
        isSaving: _isSaving,
        error: _error,
      );
    }
    if (_step == 2) {
      return _RoleView(
        role: _role,
        onRoleChanged: (r) => setState(() => _role = r),
        onBack: _back,
        onNext: () => setState(() { _step = 3; _error = null; }),
      );
    }
    if (_step == 3) {
      return _CredentialsView(
        usernameCtrl: _usernameCtrl,
        emailCtrl: _emailCtrl,
        nameCtrl: _nameCtrl,
        passCtrl: _passCtrl,
        confirmCtrl: _confirmCtrl,
        obscurePass: _obscurePass,
        obscureConfirm: _obscureConfirm,
        onTogglePass: () => setState(() => _obscurePass = !_obscurePass),
        onToggleConfirm: () => setState(() => _obscureConfirm = !_obscureConfirm),
        onChanged: () => setState(() {}),
        credentialsOk: _credentialsOk,
        onBack: _back,
        onNext: () => setState(() { _step = 4; _error = null; }),
        error: _error,
      );
    }
    if (_step == 4 && _role == 'student') {
      return _StudentProfileView(
        beltLevel: _beltLevel,
        belts: _belts,
        onBeltChanged: (b) => setState(() => _beltLevel = b),
        startYearCtrl: _startYearCtrl,
        inviteCodeCtrl: _inviteCodeCtrl,
        onBack: _back,
        onSubmit: _studentFieldsOk && !_isSaving ? _submitRegister : null,
        isSaving: _isSaving,
        error: _error,
      );
    }
    if (_step == 4 && _role == 'instructor') {
      return _InstructorProfileView(
        dojoNameCtrl: _dojoNameCtrl,
        danRankCtrl: _danRankCtrl,
        onBack: _back,
        onSubmit: _instructorFieldsOk && !_isSaving ? _submitRegister : null,
        isSaving: _isSaving,
        error: _error,
      );
    }
    return const SizedBox.shrink();
  }
}

// ── Welcome ───────────────────────────────────────────────────────────────────

class _WelcomeView extends StatelessWidget {
  const _WelcomeView({required this.onGetStarted, required this.onLogin});
  final VoidCallback onGetStarted;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0A0C), Color(0xFF050507)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(),
              // Logo
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppColors.gradMain,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.sports_martial_arts_rounded,
                    size: 36, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                'TulMaster',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Master Every Pattern.',
                style: TextStyle(fontSize: 15, color: AppColors.textMuted),
              ),
              const Spacer(),
              // Description
              Text(
                'auth.welcomeDesc'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, color: AppColors.textMuted, height: 1.6),
              ),
              const SizedBox(height: 32),
              // CTA
              _GradBtn(
                label: 'auth.getStarted'.tr(),
                onTap: onGetStarted,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: onLogin,
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 14),
                        children: [
                          TextSpan(
                              text: '${'auth.haveAccount'.tr()}  ',
                              style: TextStyle(color: AppColors.textMuted)),
                          TextSpan(
                              text: 'auth.login'.tr(),
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Login ─────────────────────────────────────────────────────────────────────

class _LoginView extends StatelessWidget {
  const _LoginView({
    required this.usernameCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.onToggleObscure,
    required this.onBack,
    required this.onSubmit,
    required this.isSaving,
    required this.error,
  });

  final TextEditingController usernameCtrl;
  final TextEditingController passCtrl;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final VoidCallback onBack;
  final Future<void> Function() onSubmit;
  final bool isSaving;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _BackBtn(onBack: onBack),
            const SizedBox(height: 32),
            // Logo + title
            Center(
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradMain,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.sports_martial_arts_rounded,
                        size: 28, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text('auth.loginTitle'.tr(),
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text('auth.loginSubtitle'.tr(),
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textMuted)),
                ],
              ),
            ),
            const SizedBox(height: 36),
            _AuthField(
              ctrl: usernameCtrl,
              label: 'auth.username'.tr(),
              hint: 'auth.usernameHint'.tr(),
              icon: Icons.person_outline_rounded,
              action: TextInputAction.next,
            ),
            const SizedBox(height: 14),
            _PasswordField(
              ctrl: passCtrl,
              label: 'auth.password'.tr(),
              obscure: obscure,
              onToggle: onToggleObscure,
              action: TextInputAction.done,
              onSubmit: (_) => onSubmit(),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: Text('auth.forgotPassword'.tr(),
                    style: TextStyle(
                        fontSize: 12, color: AppColors.primary)),
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              _ErrorBanner(message: error!),
            ],
            const SizedBox(height: 24),
            _GradBtn(
              label: isSaving ? '' : 'auth.login'.tr(),
              loading: isSaving,
              onTap: isSaving ? null : onSubmit,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Step 1: Role ──────────────────────────────────────────────────────────────

class _RoleView extends StatelessWidget {
  const _RoleView({
    required this.role,
    required this.onRoleChanged,
    required this.onBack,
    required this.onNext,
  });

  final String role;
  final void Function(String) onRoleChanged;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _BackBtn(onBack: onBack),
            const SizedBox(height: 24),
            _StepDots(current: 0, total: 3),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
                children: [
                  TextSpan(text: '${'auth.roleSelectTitle'.tr().split(' ').take(2).join(' ')} '),
                  TextSpan(
                      text: 'auth.roleSelectTitle'.tr().split(' ').skip(2).join(' '),
                      style: TextStyle(color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text('auth.roleSelectSubtitle'.tr(),
                style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: 28),
            _RoleCard(
              selected: role == 'student',
              icon: Icons.school_outlined,
              accentColor: AppColors.primary,
              title: 'auth.roleStudent'.tr(),
              desc: 'auth.roleStudentDesc'.tr(),
              onTap: () => onRoleChanged('student'),
            ),
            const SizedBox(height: 12),
            _RoleCard(
              selected: role == 'instructor',
              icon: Icons.sports_martial_arts_rounded,
              accentColor: AppColors.secondary,
              title: 'auth.roleInstructor'.tr(),
              desc: 'auth.roleInstructorDesc'.tr(),
              onTap: () => onRoleChanged('instructor'),
            ),
            const SizedBox(height: 36),
            _NavRow(onBack: onBack, onNext: onNext),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Step 2: Credentials ───────────────────────────────────────────────────────

class _CredentialsView extends StatelessWidget {
  const _CredentialsView({
    required this.usernameCtrl,
    required this.emailCtrl,
    required this.nameCtrl,
    required this.passCtrl,
    required this.confirmCtrl,
    required this.obscurePass,
    required this.obscureConfirm,
    required this.onTogglePass,
    required this.onToggleConfirm,
    required this.onChanged,
    required this.credentialsOk,
    required this.onBack,
    required this.onNext,
    required this.error,
  });

  final TextEditingController usernameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController nameCtrl;
  final TextEditingController passCtrl;
  final TextEditingController confirmCtrl;
  final bool obscurePass;
  final bool obscureConfirm;
  final VoidCallback onTogglePass;
  final VoidCallback onToggleConfirm;
  final VoidCallback onChanged;
  final bool credentialsOk;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _BackBtn(onBack: onBack),
            const SizedBox(height: 24),
            _StepDots(current: 1, total: 3),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
                children: [
                  const TextSpan(text: 'Create your '),
                  TextSpan(
                      text: 'account',
                      style: TextStyle(color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text('auth.registerSubtitle'.tr(),
                style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: 28),
            _AuthField(
              ctrl: usernameCtrl,
              label: 'auth.username'.tr(),
              hint: 'auth.usernameHint'.tr(),
              icon: Icons.alternate_email_rounded,
              action: TextInputAction.next,
              onChanged: (_) => onChanged(),
            ),
            const SizedBox(height: 14),
            _AuthField(
              ctrl: nameCtrl,
              label: 'auth.displayName'.tr(),
              hint: 'auth.displayNameHint'.tr(),
              icon: Icons.person_outline_rounded,
              action: TextInputAction.next,
              onChanged: (_) => onChanged(),
            ),
            const SizedBox(height: 14),
            _AuthField(
              ctrl: emailCtrl,
              label: 'auth.email'.tr(),
              hint: 'auth.emailHint'.tr(),
              icon: Icons.email_outlined,
              action: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => onChanged(),
              isOptional: true,
            ),
            const SizedBox(height: 14),
            _PasswordField(
              ctrl: passCtrl,
              label: 'auth.password'.tr(),
              obscure: obscurePass,
              onToggle: onTogglePass,
              action: TextInputAction.next,
              onChanged: (_) => onChanged(),
            ),
            const SizedBox(height: 14),
            _PasswordField(
              ctrl: confirmCtrl,
              label: 'auth.confirmPassword'.tr(),
              obscure: obscureConfirm,
              onToggle: onToggleConfirm,
              action: TextInputAction.done,
              onChanged: (_) => onChanged(),
            ),
            if (error != null) ...[
              const SizedBox(height: 12),
              _ErrorBanner(message: error!),
            ],
            const SizedBox(height: 28),
            _NavRow(
              onBack: onBack,
              onNext: credentialsOk ? onNext : null,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Step 3a: Student profile ──────────────────────────────────────────────────

class _StudentProfileView extends StatelessWidget {
  const _StudentProfileView({
    required this.beltLevel,
    required this.belts,
    required this.onBeltChanged,
    required this.startYearCtrl,
    required this.inviteCodeCtrl,
    required this.onBack,
    required this.onSubmit,
    required this.isSaving,
    required this.error,
  });

  final String beltLevel;
  final List<String> belts;
  final void Function(String) onBeltChanged;
  final TextEditingController startYearCtrl;
  final TextEditingController inviteCodeCtrl;
  final VoidCallback onBack;
  final VoidCallback? onSubmit;
  final bool isSaving;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _BackBtn(onBack: onBack),
            const SizedBox(height: 24),
            _StepDots(current: 2, total: 3),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
                children: [
                  const TextSpan(text: 'Set up your '),
                  TextSpan(
                      text: 'profile',
                      style: TextStyle(color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text('auth.studentProfileSubtitle'.tr(),
                style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: 28),
            // Belt dropdown
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child: DropdownButtonFormField<String>(
                initialValue: beltLevel,
                decoration: InputDecoration(
                  labelText: 'auth.currentBelt'.tr(),
                  labelStyle:
                      TextStyle(color: AppColors.textMuted, fontSize: 12),
                  prefixIcon: Icon(Icons.military_tech_outlined,
                      color: AppColors.textMuted, size: 20),
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                dropdownColor: AppColors.surface,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                iconEnabledColor: AppColors.textMuted,
                items: belts
                    .map((b) => DropdownMenuItem(
                        value: b, child: Text('belt.$b'.tr())))
                    .toList(),
                onChanged: (v) => onBeltChanged(v ?? 'white'),
              ),
            ),
            const SizedBox(height: 14),
            _AuthField(
              ctrl: startYearCtrl,
              label: 'auth.trainingStartYear'.tr(),
              hint: 'auth.trainingStartYearHint'.tr(),
              icon: Icons.calendar_today_outlined,
              keyboardType: TextInputType.number,
              action: TextInputAction.next,
              isOptional: true,
            ),
            const SizedBox(height: 14),
            _AuthField(
              ctrl: inviteCodeCtrl,
              label: 'auth.inviteCode'.tr(),
              hint: 'auth.inviteCodeHint'.tr(),
              icon: Icons.qr_code_outlined,
              action: TextInputAction.done,
              textCapitalization: TextCapitalization.characters,
              isOptional: true,
            ),
            if (error != null) ...[
              const SizedBox(height: 12),
              _ErrorBanner(message: error!),
            ],
            const SizedBox(height: 28),
            _NavRow(
              onBack: onBack,
              onNext: onSubmit,
              nextLabel: isSaving ? '' : 'auth.getStarted'.tr(),
              loading: isSaving,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Step 3b: Instructor profile ───────────────────────────────────────────────

class _InstructorProfileView extends StatelessWidget {
  const _InstructorProfileView({
    required this.dojoNameCtrl,
    required this.danRankCtrl,
    required this.onBack,
    required this.onSubmit,
    required this.isSaving,
    required this.error,
  });

  final TextEditingController dojoNameCtrl;
  final TextEditingController danRankCtrl;
  final VoidCallback onBack;
  final VoidCallback? onSubmit;
  final bool isSaving;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _BackBtn(onBack: onBack),
            const SizedBox(height: 24),
            _StepDots(current: 2, total: 3),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
                children: [
                  const TextSpan(text: 'Set up your '),
                  TextSpan(
                      text: 'dojang',
                      style: TextStyle(color: AppColors.secondary)),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text('auth.instructorProfileSubtitle'.tr(),
                style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: 28),
            _AuthField(
              ctrl: dojoNameCtrl,
              label: 'auth.dojoName'.tr(),
              hint: 'auth.dojoNameHint'.tr(),
              icon: Icons.home_work_outlined,
              action: TextInputAction.next,
            ),
            const SizedBox(height: 14),
            _AuthField(
              ctrl: danRankCtrl,
              label: 'auth.danRank'.tr(),
              hint: 'auth.danRankHint'.tr(),
              icon: Icons.emoji_events_outlined,
              action: TextInputAction.done,
            ),
            if (error != null) ...[
              const SizedBox(height: 12),
              _ErrorBanner(message: error!),
            ],
            const SizedBox(height: 28),
            _NavRow(
              onBack: onBack,
              onNext: onSubmit,
              nextLabel: isSaving ? '' : 'auth.getStarted'.tr(),
              loading: isSaving,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _GradBtn extends StatelessWidget {
  const _GradBtn({required this.label, this.onTap, this.loading = false});
  final String label;
  final dynamic onTap; // VoidCallback | Future Function() | null
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap != null ? () => onTap!() : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 54,
        decoration: BoxDecoration(
          gradient: onTap != null ? AppColors.gradMain : null,
          color: onTap == null ? AppColors.muted : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Text(label,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: onTap != null ? Colors.white : AppColors.textMuted)),
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.onBack,
    required this.onNext,
    this.nextLabel,
    this.loading = false,
  });
  final VoidCallback onBack;
  final VoidCallback? onNext;
  final String? nextLabel;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child:
                Icon(Icons.chevron_left_rounded, color: AppColors.text, size: 22),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GradBtn(
            label: nextLabel ?? 'auth.next'.tr(),
            onTap: onNext,
            loading: loading,
          ),
        ),
      ],
    );
  }
}

class _BackBtn extends StatelessWidget {
  const _BackBtn({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onBack,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(Icons.chevron_left_rounded,
            color: AppColors.text, size: 20),
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < total; i++) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: i == current ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i <= current ? AppColors.primary : AppColors.muted,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          if (i < total - 1) const SizedBox(width: 6),
        ],
        const SizedBox(width: 10),
        Text(
          'auth.stepOf'.tr(namedArgs: {
            'step': '${current + 1}',
            'total': '$total',
          }),
          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.ctrl,
    required this.label,
    this.hint,
    this.icon,
    this.action = TextInputAction.next,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.isOptional = false,
  });

  final TextEditingController ctrl;
  final String label;
  final String? hint;
  final IconData? icon;
  final TextInputAction action;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final void Function(String)? onChanged;
  final bool isOptional;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      textInputAction: action,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, color: Colors.white),
      decoration: InputDecoration(
        labelText: isOptional ? '$label  (optional)' : label,
        labelStyle: TextStyle(color: AppColors.textMuted, fontSize: 12),
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textDisabled, fontSize: 13),
        prefixIcon: icon != null
            ? Icon(icon, size: 18, color: AppColors.textMuted)
            : null,
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.ctrl,
    required this.label,
    required this.obscure,
    required this.onToggle,
    this.action = TextInputAction.next,
    this.onSubmit,
    this.onChanged,
  });

  final TextEditingController ctrl;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;
  final TextInputAction action;
  final void Function(String)? onSubmit;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      textInputAction: action,
      onSubmitted: onSubmit,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textMuted, fontSize: 12),
        prefixIcon:
            Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.textMuted),
        suffixIcon: IconButton(
          icon: Icon(
              obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 18,
              color: AppColors.textMuted),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.selected,
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.desc,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final Color accentColor;
  final String title;
  final String desc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected
              ? accentColor.withValues(alpha: 0.07)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? accentColor : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: selected ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon,
                  size: 24, color: selected ? accentColor : AppColors.textMuted),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: selected ? accentColor : AppColors.text)),
                  const SizedBox(height: 4),
                  Text(desc,
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          height: 1.4)),
                ],
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              Icon(Icons.check_circle_rounded, color: accentColor, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
