import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/backend_client.dart';
import '../../auth/application/providers.dart';
import '../data/repositories/journal_repository_impl.dart';
import '../domain/entities/training_session.dart';
import '../domain/repositories/journal_repository.dart';
import 'journal_state.dart';

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepositoryImpl(ref.watch(backendClientProvider));
});

class JournalController extends Notifier<JournalState> {
  @override
  JournalState build() {
    final auth = ref.watch(authControllerProvider);
    if (!auth.isLoggedIn || auth.isLoading) {
      return const JournalState();
    }
    _load();
    return const JournalState(isLoading: true);
  }

  Future<void> _load() async {
    try {
      final repo = ref.read(journalRepositoryProvider);
      final sessions = await repo.loadAll();
      state = state.copyWith(sessions: sessions, isLoading: false);
    } catch (e, s) {
      debugPrint('JournalController._load error: $e\n$s');
      state = state.copyWith(sessions: [], isLoading: false);
    }
  }

  Future<void> addSession(TrainingSession session) async {
    final repo = ref.read(journalRepositoryProvider);
    await repo.add(session);
    await _load();
  }

  Future<void> updateSession(TrainingSession session) async {
    final repo = ref.read(journalRepositoryProvider);
    await repo.update(session);
    state = state.copyWith(
      sessions: state.sessions
          .map((s) => s.id == session.id ? session : s)
          .toList(),
    );
  }

  Future<void> deleteSession(String id) async {
    final repo = ref.read(journalRepositoryProvider);
    await repo.delete(id);
    state = state.copyWith(
      sessions: state.sessions.where((s) => s.id != id).toList(),
    );
  }
}

final journalControllerProvider =
    NotifierProvider<JournalController, JournalState>(JournalController.new);
