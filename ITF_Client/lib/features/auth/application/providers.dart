import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/backend_client.dart';
import '../../settings/application/providers.dart';
import '../../settings/domain/entities/belt_level.dart';
import 'auth_state.dart';

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    _load();
    return const AuthState(isLoading: true);
  }

  BackendClient get _client => ref.read(backendClientProvider);

  Future<void> _load() async {
    final loggedIn = await _client.isLoggedIn;
    if (!loggedIn) {
      state = const AuthState(isLoading: false, isLoggedIn: false);
      return;
    }
    try {
      final me = await _client.getMe();
      state = _stateFromMe(me);
      await _syncBeltLevel(me['belt_level'] as String? ?? 'white');
    } catch (_) {
      await _client.clearTokens();
      state = const AuthState(isLoading: false, isLoggedIn: false);
    }
  }

  Future<void> _syncBeltLevel(String beltStr) async {
    final belt = BeltLevel.values.firstWhere(
      (b) => b.name == beltStr,
      orElse: () => BeltLevel.white,
    );
    try {
      await ref.read(settingsControllerProvider.notifier).setBeltLevel(belt);
    } catch (_) {}
  }

  AuthState _stateFromMe(Map<String, dynamic> me) => AuthState(
        isLoading: false,
        isLoggedIn: true,
        username: me['username'] as String,
        displayName: me['display_name'] as String,
        role: me['role'] as String? ?? 'student',
        dojoConnected: me['dojo_connected'] as bool? ?? false,
        instructorName: me['instructor_name'] as String? ?? '',
        homeworkText: me['homework_text'] as String? ?? '',
        joinedAt: me['created_at'] != null
            ? DateTime.tryParse(me['created_at'] as String)
            : null,
        dojoName: me['dojo_name'] as String? ?? '',
        danRank: me['dan_rank'] as String? ?? '',
        dojoPlan: me['dojo_plan'] as String? ?? 'free',
        studentPlan: me['student_plan'] as String? ?? 'free',
        trainingStartYear: me['training_start_year'] as int?,
        avatarUrl: me['avatar_url'] as String? ?? '',
      );

  Future<void> register({
    required String username,
    required String displayName,
    required String password,
    String role = 'student',
    String? email,
    String? beltLevel,
    int? trainingStartYear,
    String? dojoName,
    String? danRank,
    String? inviteCode,
  }) async {
    await _client.register(
      username: username,
      displayName: displayName,
      password: password,
      role: role,
      email: email,
      beltLevel: beltLevel,
      trainingStartYear: trainingStartYear,
      dojoName: dojoName,
      danRank: danRank,
    );
    // apply invite code after registration if provided
    if (inviteCode != null && inviteCode.isNotEmpty) {
      try {
        await _client.useInviteCode(inviteCode);
      } catch (_) {
        // silently ignore invalid code — user can connect later in settings
      }
    }
    final me = await _client.getMe();
    state = _stateFromMe(me);
    await _syncBeltLevel(me['belt_level'] as String? ?? 'white');
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    await _client.login(username: username, password: password);
    final me = await _client.getMe();
    state = _stateFromMe(me);
    await _syncBeltLevel(me['belt_level'] as String? ?? 'white');
  }

  Future<void> updateDisplayName(String name) async {
    await _client.updateMe(displayName: name);
    state = state.copyWith(displayName: name);
  }

  Future<void> uploadAvatar(Uint8List bytes) async {
    final url = await _client.uploadAvatar(bytes);
    if (url != null) {
      state = state.copyWith(avatarUrl: url);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _client.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<void> logout() async {
    await _client.clearTokens();
    state = const AuthState(isLoading: false, isLoggedIn: false);
  }

  Future<void> refresh() async {
    final me = await _client.getMe();
    state = _stateFromMe(me);
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
