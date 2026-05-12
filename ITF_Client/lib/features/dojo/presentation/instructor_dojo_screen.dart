import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart' show Share;

import '../../../core/network/backend_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/grad_header_text.dart';
import '../application/dojo_providers.dart';
import 'student_detail_screen.dart';

class InstructorDojoScreen extends ConsumerStatefulWidget {
  const InstructorDojoScreen({super.key});

  @override
  ConsumerState<InstructorDojoScreen> createState() =>
      _InstructorDojoScreenState();
}

class _InstructorDojoScreenState extends ConsumerState<InstructorDojoScreen> {
  final _groupHwCtrl = TextEditingController();
  DateTime? _groupHwDue;
  bool _isAssigningGroup = false;

  @override
  void dispose() {
    _groupHwCtrl.dispose();
    super.dispose();
  }

  Future<void> _assignGroupHomework() async {
    final text = _groupHwCtrl.text.trim();
    if (text.isEmpty || _groupHwDue == null) return;
    setState(() => _isAssigningGroup = true);
    try {
      final result = await ref
          .read(backendClientProvider)
          .createGroupHomework(text, _groupHwDue!);
      _groupHwCtrl.clear();
      setState(() => _groupHwDue = null);
      ref.invalidate(dojoMembersProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('dojo.groupHwAssignedFmt'.tr(namedArgs: {'count': result['assigned_count'].toString()})),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isAssigningGroup = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final codesAsync = ref.watch(inviteCodesProvider);
    final membersAsync = ref.watch(dojoMembersProvider);

    return Scaffold(
      appBar: AppBar(
        title: GradHeaderText('dojo.title'.tr(), fontSize: 20),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(inviteCodesProvider);
              ref.invalidate(dojoMembersProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(inviteCodesProvider);
          ref.invalidate(dojoMembersProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── 학생 초대 코드 섹션 ─────────────────────────────────────
            _InviteCodeSection(codesAsync: codesAsync),
            const SizedBox(height: 24),

            // ── 전체 숙제 지정 ──────────────────────────────────────────
            Text('dojo.groupHomework'.tr(),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'dojo.groupHwDesc'.tr(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _groupHwCtrl,
                      maxLength: 200,
                      maxLines: 2,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: 'dojo.homeworkHint'.tr(),
                        border: const OutlineInputBorder(),
                        isDense: true,
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate:
                                  DateTime.now().add(const Duration(days: 3)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 90)),
                            );
                            if (picked != null) {
                              setState(() => _groupHwDue = picked);
                            }
                          },
                          icon: const Icon(Icons.calendar_today_outlined,
                              size: 16),
                          label: Text(
                            _groupHwDue != null
                                ? 'dojo.dueDateSet'.tr(namedArgs: {'month': _groupHwDue!.month.toString(), 'day': _groupHwDue!.day.toString()})
                                : 'dojo.selectDueDate'.tr(),
                          ),
                        ),
                        const Spacer(),
                        FilledButton(
                          onPressed: _isAssigningGroup
                              ? null
                              : _assignGroupHomework,
                          child: _isAssigningGroup
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : Text('dojo.assignAll'.tr()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── 학생 목록 ───────────────────────────────────────────────
            Text(
              'dojo.totalStudents'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            membersAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('${'common.error'.tr()}: $e')),
              data: (members) => members.isEmpty
                  ? Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'dojo.noStudents'.tr(),
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                    )
                  : Column(
                      children: members
                          .map((m) => _StudentListCard(
                                member: m,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) => StudentDetailScreen(
                                      studentId: m['student_id'] as int,
                                    ),
                                  ),
                                ).then((_) =>
                                    ref.invalidate(dojoMembersProvider)),
                                onDisconnect: () async {
                                  final ok = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text('dojo.disconnect'.tr()),
                                      content:
                                          Text('dojo.disconnectConfirm'.tr()),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child:
                                              Text('journal.cancel'.tr()),
                                        ),
                                        FilledButton(
                                          style: FilledButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.itfRed),
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child:
                                              Text('dojo.disconnect'.tr()),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (ok == true) {
                                    await ref
                                        .read(backendClientProvider)
                                        .removeMember(m['student_id'] as int);
                                    ref.invalidate(dojoMembersProvider);
                                  }
                                },
                              ))
                          .toList(),
                    ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ── 초대 코드 섹션 ────────────────────────────────────────────────────────────

class _InviteCodeSection extends ConsumerWidget {
  const _InviteCodeSection({required this.codesAsync});

  final AsyncValue<List<Map<String, dynamic>>> codesAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'dojo.myCodes'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            FilledButton.icon(
              onPressed: () => _generateCode(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: Text('dojo.inviteBtn'.tr()),
            ),
          ],
        ),
        const SizedBox(height: 8),
        codesAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('${'common.error'.tr()}: $e'),
          data: (codes) {
            final active = codes
                .where((c) => c['status'] == 'active')
                .toList();
            if (active.isEmpty) {
              return Text(
                'dojo.noActiveCodes'.tr(),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              );
            }
            return Column(
              children: active
                  .map((c) => _InviteCodeCard(
                        code: c,
                        onRevoke: () async {
                          await ref
                              .read(backendClientProvider)
                              .revokeInviteCode(c['code'] as String);
                          ref.invalidate(inviteCodesProvider);
                        },
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Future<void> _generateCode(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(backendClientProvider).createInviteCode();
      ref.invalidate(inviteCodesProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
}

// ── 초대 코드 카드 ────────────────────────────────────────────────────────────

class _InviteCodeCard extends StatelessWidget {
  const _InviteCodeCard({required this.code, required this.onRevoke});

  final Map<String, dynamic> code;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    final codeStr = code['code'] as String? ?? '';
    final expiresAt = code['expires_at'] as String? ?? '';
    String expiryFmt = '';
    try {
      final dt = DateTime.parse(expiresAt).toLocal();
      expiryFmt = 'dojo.codeExpiryFmt'.tr(namedArgs: {
        'month': dt.month.toString(),
        'day': dt.day.toString(),
        'hour': dt.hour.toString().padLeft(2, '0'),
        'minute': dt.minute.toString().padLeft(2, '0'),
      });
    } catch (_) {}

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // QR 코드
            GestureDetector(
              onTap: () => _showQrDialog(context, codeStr),
              child: QrImageView(
                data: codeStr,
                version: QrVersions.auto,
                size: 64,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    codeStr,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          letterSpacing: 4,
                          color: AppColors.itfRed,
                        ),
                  ),
                  Text(
                    expiryFmt,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            // 공유 / 복사 / 삭제
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  tooltip: 'dojo.share'.tr(),
                  onPressed: () => Share.share(
                    'dojo.shareMessageFmt'.tr(namedArgs: {'code': codeStr}),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_outlined),
                  tooltip: 'dojo.copy'.tr(),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: codeStr));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('dojo.copied'.tr())),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.itfRed),
                  tooltip: 'dojo.revokeCode'.tr(),
                  onPressed: onRevoke,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showQrDialog(BuildContext context, String codeStr) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: codeStr,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              codeStr,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 6,
                color: AppColors.itfRed,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'dojo.codeExpiry'.tr(),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('common.close'.tr()),
          ),
        ],
      ),
    );
  }
}

// ── 학생 목록 카드 ────────────────────────────────────────────────────────────

class _StudentListCard extends StatelessWidget {
  const _StudentListCard({
    required this.member,
    required this.onTap,
    required this.onDisconnect,
  });

  final Map<String, dynamic> member;
  final VoidCallback onTap;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    final name = member['display_name'] as String? ?? '';
    final belt = member['belt_level'] as String? ?? 'white';

    final beltLabel = 'belt.$belt'.tr();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.itfRed,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(name),
        subtitle: Text(beltLabel),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'disconnect') onDisconnect();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'disconnect',
                  child: Text(
                    'dojo.disconnect'.tr(),
                    style: const TextStyle(color: AppColors.itfRed),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
