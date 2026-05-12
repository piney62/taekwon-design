import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/tul_gradients.dart';
import '../../../../core/theme/tul_palette.dart';
import '../../../../core/theme/tul_radius.dart';
import '../../../../core/theme/tul_text_styles.dart';
import '../../../../shared/widgets/gradient_text.dart';
import '../../../../shared/widgets/tul_buttons.dart';
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
  bool _showSplash = true;

  static const _belts = ['white', 'yellow', 'green', 'blue', 'red', 'black'];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

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
    if (_showSplash) return const _SplashView();
    return Scaffold(
      backgroundColor: context.tul.stage,
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

// ── Splash ────────────────────────────────────────────────────────────────────

class _SplashView extends StatefulWidget {
  const _SplashView();

  @override
  State<_SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<_SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<double> _textFade;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _fade = CurvedAnimation(
      parent: _ctl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _scale = Tween<double>(begin: 0.86, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );
    _textFade = CurvedAnimation(
      parent: _ctl,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    );
    _ctl.forward();
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Warm red wash behind the mark
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.15),
                  radius: 0.95,
                  colors: [Color(0x80EF4444), Colors.transparent],
                  stops: [0, 0.6],
                ),
              ),
            ),
          ),
          // Cool blue wash on the lower half
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, 0.65),
                  radius: 1.0,
                  colors: [Color(0x593B82F6), Colors.transparent],
                  stops: [0, 0.55],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity: _fade,
                    child: ScaleTransition(
                      scale: _scale,
                      child: Container(
                        width: 168,
                        height: 168,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [Color(0x33EF4444), Colors.transparent],
                            stops: [0, 0.75],
                          ),
                        ),
                        child: Image.asset(
                          'assets/images/logo_white.png',
                          width: 132,
                          height: 132,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _textFade,
                    child: Column(
                      children: [
                        Text(
                          'TulMaster',
                          style: TulTextStyles.splashTitle(color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'MASTER EVERY PATTERN',
                          style: TulTextStyles.mono(
                            size: 12,
                            color: const Color(0xFFA3A3A8),
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom page dots
          Positioned(
            left: 0,
            right: 0,
            bottom: 60,
            child: FadeTransition(
              opacity: _textFade,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final isActive = i == 0;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFEF4444)
                          : Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Welcome ───────────────────────────────────────────────────────────────────

class _WelcomeView extends StatelessWidget {
  const _WelcomeView({required this.onGetStarted, required this.onLogin});
  final VoidCallback onGetStarted;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return Scaffold(
      backgroundColor: palette.stage,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              // Logo with red bloom
              Center(
                child: Container(
                  width: 168,
                  height: 168,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0x29EF4444), Colors.transparent],
                      stops: [0, 0.75],
                    ),
                  ),
                  child: Image.asset(
                    'assets/images/logo_white.png',
                    width: 124,
                    height: 124,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              GradientText(
                'TulMaster',
                gradient: TulGradients.brand,
                style: TulTextStyles.splashTitle(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Text(
                'auth.welcomeDesc'.tr(),
                textAlign: TextAlign.center,
                style: TulTextStyles.subtitle(color: palette.text2)
                    .copyWith(height: 1.55),
              ),
              const Spacer(),
              TulPrimaryButton(
                label: 'auth.getStarted'.tr(),
                onPressed: onGetStarted,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onLogin,
                child: Text.rich(
                  TextSpan(
                    text: '${'auth.haveAccount'.tr()}  ',
                    style: TulTextStyles.small(color: palette.text2),
                    children: [
                      TextSpan(
                        text: 'auth.login'.tr(),
                        style: TulTextStyles.smallStrong(color: palette.primary),
                      ),
                    ],
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
    final palette = context.tul;
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
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: TulGradients.brand,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(LucideIcons.award, size: 28, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'auth.loginTitle'.tr(),
                    style: TulTextStyles.h2(color: palette.text),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'auth.loginSubtitle'.tr(),
                    style: TulTextStyles.small(color: palette.text2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            _AuthField(
              ctrl: usernameCtrl,
              label: 'auth.username'.tr(),
              hint: 'auth.usernameHint'.tr(),
              icon: LucideIcons.user,
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
                child: Text(
                  'auth.forgotPassword'.tr(),
                  style: TulTextStyles.small(color: palette.primary),
                ),
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
    final palette = context.tul;
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
            Text(
              _roleSelectPrefix('auth.roleSelectTitle'.tr()),
              style: TulTextStyles.title(color: palette.text),
            ),
            GradientText(
              _roleSelectSuffix('auth.roleSelectTitle'.tr()),
              gradient: TulGradients.brand,
              style: TulTextStyles.title(),
            ),
            const SizedBox(height: 6),
            Text(
              'auth.roleSelectSubtitle'.tr(),
              style: TulTextStyles.small(color: palette.text2),
            ),
            const SizedBox(height: 28),
            _RoleCard(
              selected: role == 'student',
              icon: LucideIcons.bookOpen,
              accentColor: palette.primary,
              title: 'auth.roleStudent'.tr(),
              desc: 'auth.roleStudentDesc'.tr(),
              onTap: () => onRoleChanged('student'),
            ),
            const SizedBox(height: 12),
            _RoleCard(
              selected: role == 'instructor',
              icon: LucideIcons.award,
              accentColor: palette.secondary,
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

  static String _roleSelectPrefix(String s) =>
      s.split(' ').take(2).join(' ');
  static String _roleSelectSuffix(String s) =>
      s.split(' ').skip(2).join(' ');
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
    final palette = context.tul;
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
            Text('Create your', style: TulTextStyles.title(color: palette.text)),
            GradientText(
              'account',
              gradient: TulGradients.brand,
              style: TulTextStyles.title(),
            ),
            const SizedBox(height: 8),
            Text(
              'auth.registerSubtitle'.tr(),
              style: TulTextStyles.small(color: palette.text2),
            ),
            const SizedBox(height: 28),
            _AuthField(
              ctrl: usernameCtrl,
              label: 'auth.username'.tr(),
              hint: 'auth.usernameHint'.tr(),
              action: TextInputAction.next,
              onChanged: (_) => onChanged(),
              helperText: 'auth.usernameHint'.tr(),
            ),
            const SizedBox(height: 14),
            _AuthField(
              ctrl: nameCtrl,
              label: 'auth.displayName'.tr(),
              hint: 'auth.displayNameHint'.tr(),
              action: TextInputAction.next,
              onChanged: (_) => onChanged(),
            ),
            const SizedBox(height: 14),
            _AuthField(
              ctrl: emailCtrl,
              label: 'auth.email'.tr(),
              hint: 'auth.emailHint'.tr(),
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
              helperText: confirmCtrl.text.isNotEmpty &&
                      passCtrl.text == confirmCtrl.text
                  ? '✓  Passwords match.'
                  : null,
              helperColor: palette.green,
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
    final palette = context.tul;
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
            Text('Set up your', style: TulTextStyles.title(color: palette.text)),
            GradientText(
              'profile',
              gradient: TulGradients.brand,
              style: TulTextStyles.title(),
            ),
            const SizedBox(height: 8),
            Text(
              'auth.studentProfileSubtitle'.tr(),
              style: TulTextStyles.small(color: palette.text2),
            ),
            const SizedBox(height: 28),
            // Belt dropdown
            Container(
              decoration: BoxDecoration(
                color: palette.stripe,
                borderRadius: TulRadius.brMd,
              ),
              child: DropdownButtonFormField<String>(
                initialValue: beltLevel,
                decoration: InputDecoration(
                  labelText: 'auth.currentBelt'.tr(),
                  labelStyle: TulTextStyles.small(color: palette.text2),
                  prefixIcon: Icon(LucideIcons.award, color: palette.text2, size: 18),
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: TulRadius.brMd,
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: TulRadius.brMd,
                    borderSide: BorderSide.none,
                  ),
                ),
                dropdownColor: palette.card,
                style: TextStyle(color: palette.text, fontSize: 14),
                iconEnabledColor: palette.text2,
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
              icon: LucideIcons.calendar,
              keyboardType: TextInputType.number,
              action: TextInputAction.next,
              isOptional: true,
            ),
            const SizedBox(height: 14),
            _AuthField(
              ctrl: inviteCodeCtrl,
              label: 'auth.inviteCode'.tr(),
              hint: 'auth.inviteCodeHint'.tr(),
              icon: LucideIcons.qrCode,
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
    final palette = context.tul;
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
            Text('Set up your', style: TulTextStyles.title(color: palette.text)),
            GradientText(
              'dojang',
              gradient: TulGradients.instructor,
              style: TulTextStyles.title(),
            ),
            const SizedBox(height: 8),
            Text(
              'auth.instructorProfileSubtitle'.tr(),
              style: TulTextStyles.small(color: palette.text2),
            ),
            const SizedBox(height: 28),
            _AuthField(
              ctrl: dojoNameCtrl,
              label: 'auth.dojoName'.tr(),
              hint: 'auth.dojoNameHint'.tr(),
              icon: LucideIcons.building2,
              action: TextInputAction.next,
            ),
            const SizedBox(height: 14),
            _AuthField(
              ctrl: danRankCtrl,
              label: 'auth.danRank'.tr(),
              hint: 'auth.danRankHint'.tr(),
              icon: LucideIcons.trophy,
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
    final palette = context.tul;
    final enabled = onTap != null;
    return GestureDetector(
      onTap: enabled ? () => onTap!() : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 54,
        decoration: BoxDecoration(
          gradient: enabled ? TulGradients.brand : null,
          color: enabled ? null : palette.muted,
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
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: enabled ? Colors.white : palette.text2,
                  ),
                ),
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
    final palette = context.tul;
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onBack,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: palette.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: palette.border),
              ),
              child: Center(
                child: Text(
                  'Back',
                  style: TulTextStyles.bodyMd(color: palette.text),
                ),
              ),
            ),
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
    final palette = context.tul;
    return GestureDetector(
      onTap: onBack,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: palette.border),
        ),
        child: Icon(LucideIcons.chevronLeft, color: palette.text, size: 18),
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
    final palette = context.tul;
    return Row(
      children: [
        for (int i = 0; i < total; i++) ...[
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 3,
              decoration: BoxDecoration(
                gradient: i <= current ? TulGradients.brand : null,
                color: i <= current ? null : palette.track,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (i < total - 1) const SizedBox(width: 4),
        ],
        const SizedBox(width: 12),
        Text(
          'STEP ${current + 1} / $total',
          style: TulTextStyles.mono(
            size: 11,
            color: palette.text2,
            letterSpacing: 1.5,
          ),
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
    this.helperText,
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
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    final displayLabel = isOptional ? '$label  (optional)' : label;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(displayLabel, style: TulTextStyles.smallStrong(color: palette.text2)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          textInputAction: action,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          onChanged: onChanged,
          style: TextStyle(fontSize: 14, color: palette.text),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TulTextStyles.small(color: palette.text3),
            filled: true,
            fillColor: palette.card,
            border: OutlineInputBorder(
              borderRadius: TulRadius.brMd,
              borderSide: BorderSide(color: palette.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: TulRadius.brMd,
              borderSide: BorderSide(color: palette.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: TulRadius.brMd,
              borderSide: BorderSide(color: palette.primary, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(helperText!, style: TulTextStyles.tiny(color: palette.text3)),
        ],
      ],
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
    this.helperText,
    this.helperColor,
  });

  final TextEditingController ctrl;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;
  final TextInputAction action;
  final void Function(String)? onSubmit;
  final void Function(String)? onChanged;
  final String? helperText;
  final Color? helperColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TulTextStyles.smallStrong(color: palette.text2)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          obscureText: obscure,
          textInputAction: action,
          onSubmitted: onSubmit,
          onChanged: onChanged,
          style: TextStyle(fontSize: 14, color: palette.text),
          decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? LucideIcons.eye : LucideIcons.eyeOff,
                size: 18,
                color: palette.text2,
              ),
              onPressed: onToggle,
            ),
            filled: true,
            fillColor: palette.card,
            border: OutlineInputBorder(
              borderRadius: TulRadius.brMd,
              borderSide: BorderSide(color: palette.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: TulRadius.brMd,
              borderSide: BorderSide(color: palette.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: TulRadius.brMd,
              borderSide: BorderSide(color: palette.primary, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText!,
            style: TulTextStyles.tiny(color: helperColor ?? palette.text3),
          ),
        ],
      ],
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
    final palette = context.tul;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected
              ? accentColor.withValues(alpha: 0.07)
              : palette.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? accentColor : palette.border,
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
                  size: 24, color: selected ? accentColor : palette.text2),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TulTextStyles.bodyStrong(
                      color: selected ? accentColor : palette.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TulTextStyles.small(color: palette.text2)
                        .copyWith(height: 1.4),
                  ),
                ],
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              Icon(LucideIcons.checkCircle, color: accentColor, size: 20),
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
    final palette = context.tul;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.alertCircle, color: palette.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TulTextStyles.small(color: palette.primary)
                  .copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
