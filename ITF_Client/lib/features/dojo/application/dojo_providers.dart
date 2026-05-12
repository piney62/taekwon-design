import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/backend_client.dart';

// ── Invite codes ──────────────────────────────────────────────────────────────

final inviteCodesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(backendClientProvider).listInviteCodes();
});

// ── Members ───────────────────────────────────────────────────────────────────

final dojoMembersProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(backendClientProvider).listMembers();
});

final memberDetailProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, studentId) async {
  return ref.watch(backendClientProvider).getMemberDetail(studentId);
});

// ── Comments ──────────────────────────────────────────────────────────────────

final commentsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>((ref, studentId) async {
  return ref.watch(backendClientProvider).listComments(studentId);
});

// ── Student Journal (instructor view) ─────────────────────────────────────────

final studentJournalProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, studentId) async {
  return ref.watch(backendClientProvider).getStudentJournal(studentId);
});

// ── Homework ──────────────────────────────────────────────────────────────────

final pendingHomeworkProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>((ref, studentId) async {
  return ref.watch(backendClientProvider).listPendingHomework(studentId);
});
