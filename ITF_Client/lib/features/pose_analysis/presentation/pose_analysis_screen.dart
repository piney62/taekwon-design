import 'dart:convert';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/backend_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/grad_header_text.dart';
import 'web_camera.dart';

// ─── State ────────────────────────────────────────────
class _PoseState {
  final List<Map<String, dynamic>> tulList;
  final String? selectedTul;
  final int? selectedMovement;
  final Uint8List? studentBytes;
  final String? studentName;
  final bool loading;
  final Map<String, dynamic>? result;
  final String? error;
  final bool saved;
  final bool saving;

  const _PoseState({
    this.tulList = const [],
    this.selectedTul,
    this.selectedMovement,
    this.studentBytes,
    this.studentName,
    this.loading = false,
    this.result,
    this.error,
    this.saved = false,
    this.saving = false,
  });

  _PoseState copyWith({
    List<Map<String, dynamic>>? tulList,
    String? selectedTul,
    int? selectedMovement,
    Uint8List? studentBytes,
    String? studentName,
    bool? loading,
    Map<String, dynamic>? result,
    String? error,
    bool? saved,
    bool? saving,
    bool clearResult = false,
    bool clearError = false,
  }) =>
      _PoseState(
        tulList: tulList ?? this.tulList,
        selectedTul: selectedTul ?? this.selectedTul,
        selectedMovement: selectedMovement ?? this.selectedMovement,
        studentBytes: studentBytes ?? this.studentBytes,
        studentName: studentName ?? this.studentName,
        loading: loading ?? this.loading,
        result: clearResult ? null : (result ?? this.result),
        error: clearError ? null : (error ?? this.error),
        saved: clearResult ? false : (saved ?? this.saved),
        saving: saving ?? this.saving,
      );

  List<Map<String, dynamic>> get movements {
    final tul = tulList.where((t) => t['id'] == selectedTul).firstOrNull;
    if (tul == null) return [];
    return (tul['movements'] as List).cast<Map<String, dynamic>>();
  }

  bool get canAnalyze =>
      studentBytes != null &&
      selectedTul != null &&
      selectedMovement != null &&
      !loading;
}

// ─── Controller ───────────────────────────────────────
class _PoseNotifier extends StateNotifier<_PoseState> {
  _PoseNotifier(this._client) : super(const _PoseState()) {
    _loadTulList();
  }

  final BackendClient _client;
  final _picker = ImagePicker();

  Future<void> _loadTulList() async {
    try {
      final list = await _client.getTulList();
      if (list.isEmpty) return;
      final first = list.first;
      final movements =
          (first['movements'] as List).cast<Map<String, dynamic>>();
      state = state.copyWith(
        tulList: list,
        selectedTul: first['id'] as String,
        selectedMovement:
            movements.isNotEmpty ? movements.first['no'] as int : null,
      );
    } catch (_) {}
  }

  void selectTul(String tul) {
    final tobj = state.tulList.where((t) => t['id'] == tul).firstOrNull;
    final movements = tobj != null
        ? (tobj['movements'] as List).cast<Map<String, dynamic>>()
        : <Map<String, dynamic>>[];
    state = state.copyWith(
      selectedTul: tul,
      selectedMovement:
          movements.isNotEmpty ? movements.first['no'] as int : null,
      clearResult: true,
    );
  }

  void selectMovement(int no) =>
      state = state.copyWith(selectedMovement: no, clearResult: true);

  Future<void> pickFromGallery() async {
    final file =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    state =
        state.copyWith(studentBytes: bytes, studentName: file.name, clearResult: true);
  }

  Future<void> pickFromCamera() async {
    final file =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    state =
        state.copyWith(studentBytes: bytes, studentName: file.name, clearResult: true);
  }

  void setStudentPhoto(Uint8List bytes, String name) =>
      state = state.copyWith(
          studentBytes: bytes, studentName: name, clearResult: true);

  Future<void> analyze(String language) async {
    if (!state.canAnalyze) return;
    state = state.copyWith(loading: true, clearError: true, clearResult: true);
    try {
      final res = await _client.analyzePose(
        studentImageBytes: state.studentBytes!,
        studentFileName: state.studentName ?? 'student.jpg',
        tulName: state.selectedTul!,
        movementNo: state.selectedMovement!,
        language: language,
      );
      state = state.copyWith(loading: false, result: res);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> saveResult() async {
    final result = state.result;
    if (result == null || state.saved || state.saving) return;
    state = state.copyWith(saving: true);
    try {
      final tul = state.selectedTul!;
      final movNo = state.selectedMovement!;
      final movObj = state.movements.where((m) => m['no'] == movNo).firstOrNull;
      final movName = movObj?['name'] as String? ?? '$movNo';
      await _client.savePoseRecord(
        tulName: tul,
        movementNo: movNo,
        movementName: movName,
        score: result['score'] as int? ?? 0,
        feedback: result['feedback'] as String? ?? '',
      );
      state = state.copyWith(saving: false, saved: true);
    } catch (e) {
      state = state.copyWith(saving: false);
      rethrow;
    }
  }
}

final _poseProvider =
    StateNotifierProvider.autoDispose<_PoseNotifier, _PoseState>((ref) {
  return _PoseNotifier(ref.watch(backendClientProvider));
});

// ─── Screen ───────────────────────────────────────────
class PoseAnalysisScreen extends ConsumerWidget {
  const PoseAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_poseProvider);
    final notifier = ref.read(_poseProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _TulSelector(state: state, notifier: notifier),
                  const SizedBox(height: 16),
                  _StudentPhotoSection(state: state, notifier: notifier),
                  const SizedBox(height: 16),
                  _AnalyzeButton(state: state, notifier: notifier),
                  const SizedBox(height: 16),
                  _InfoCard(),
                  if (state.error != null) ...[
                    const SizedBox(height: 16),
                    _ErrorCard(message: state.error!),
                  ],
                  if (state.result != null) ...[
                    const SizedBox(height: 24),
                    _ResultSection(
                      result: state.result!,
                      saved: state.saved,
                      saving: state.saving,
                      onSave: () async {
                        try {
                          await notifier.saveResult();
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        }
                      },
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GradHeaderText('pose.screenTitle'.tr()),
              const SizedBox(height: 6),
              Text(
                'pose.subtitle'.tr(),
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // History icon button
        Tooltip(
          message: 'pose.recordsTitle'.tr(),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                  builder: (_) => const _PoseRecordsScreen()),
            ),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(Icons.history_rounded,
                  size: 20, color: AppColors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Tul / movement selector ──────────────────────────
class _TulSelector extends StatelessWidget {
  const _TulSelector({required this.state, required this.notifier});
  final _PoseState state;
  final _PoseNotifier notifier;

  @override
  Widget build(BuildContext context) {
    if (state.tulList.isEmpty) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.primary),
          ),
        ),
      );
    }
    final movements = state.movements;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _StyledDropdown<String>(
            label: 'pose.tulLabel'.tr(),
            value: state.selectedTul,
            items: state.tulList
                .map((t) => DropdownMenuItem(
                      value: t['id'] as String,
                      child: Text(t['name'] as String),
                    ))
                .toList(),
            onChanged: (v) => v != null ? notifier.selectTul(v) : null,
          ),
          if (movements.isNotEmpty) ...[
            const SizedBox(height: 12),
            _StyledDropdown<int>(
              label: 'pose.movementLabel'.tr(),
              value: state.selectedMovement,
              items: movements
                  .map((m) => DropdownMenuItem(
                        value: m['no'] as int,
                        child: Text('${m['no']}. ${m['name']}'),
                      ))
                  .toList(),
              onChanged: (v) => v != null ? notifier.selectMovement(v) : null,
            ),
          ],
        ],
      ),
    );
  }
}

class _StyledDropdown<T> extends StatelessWidget {
  const _StyledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textMuted, fontSize: 12),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        isDense: true,
      ),
      dropdownColor: AppColors.surface,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      iconEnabledColor: AppColors.textMuted,
      items: items,
      onChanged: onChanged,
    );
  }
}

// ─── Student photo section ────────────────────────────
class _StudentPhotoSection extends StatelessWidget {
  const _StudentPhotoSection({required this.state, required this.notifier});
  final _PoseState state;
  final _PoseNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Photo preview or placeholder
        if (state.studentBytes != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.memory(
              state.studentBytes!,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          )
        else
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.6),
                  width: 1.5,
                  strokeAlign: BorderSide.strokeAlignInside),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradSoft,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.qr_code_scanner_rounded,
                        size: 26, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  Text('pose.myPhoto'.tr(),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('pose.photoHint'.tr(),
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        // Gallery / Camera buttons
        Row(
          children: [
            Expanded(
              child: _MediaButton(
                icon: Icons.photo_library_outlined,
                label: 'pose.gallery'.tr(),
                color: AppColors.secondary,
                onTap: notifier.pickFromGallery,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MediaButton(
                icon: Icons.camera_alt_outlined,
                label: 'pose.camera'.tr(),
                color: AppColors.primary,
                onTap: () async {
                  if (kIsWeb) {
                    final bytes = await showWebCamera(context);
                    if (bytes != null) notifier.setStudentPhoto(bytes, 'camera.jpg');
                  } else {
                    notifier.pickFromCamera();
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'pose.masterPhotoNote'.tr(),
          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _MediaButton extends StatelessWidget {
  const _MediaButton(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 10),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

// ─── Analyze button ───────────────────────────────────
class _AnalyzeButton extends ConsumerWidget {
  const _AnalyzeButton({required this.state, required this.notifier});
  final _PoseState state;
  final _PoseNotifier notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = state.canAnalyze;
    return GestureDetector(
      onTap: enabled
          ? () => notifier.analyze(Localizations.localeOf(context).languageCode)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          gradient: enabled ? AppColors.gradMain : null,
          color: enabled ? null : AppColors.muted,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: state.loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.analytics_outlined,
                        size: 18,
                        color: enabled ? Colors.white : AppColors.textMuted),
                    const SizedBox(width: 8),
                    Text(
                      'pose.analyzeBtn'.tr(),
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: enabled ? Colors.white : AppColors.textMuted),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Info card ────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.gradSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.timeline_rounded,
                size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Compared to master reference',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  'Form, stance and technique scored against the ITF reference for this exact movement.',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Result section (compact) ─────────────────────────
class _ResultSection extends StatelessWidget {
  const _ResultSection({
    required this.result,
    required this.saved,
    required this.saving,
    required this.onSave,
  });
  final Map<String, dynamic> result;
  final bool saved;
  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final masterB64 = result['master_stick'] as String?;
    final studentB64 = result['student_stick'] as String?;
    final feedback = result['feedback'] as String? ?? '';
    final masterAngles =
        (result['master_angles'] as Map?)?.cast<String, dynamic>() ?? {};
    final studentAngles =
        (result['student_angles'] as Map?)?.cast<String, dynamic>() ?? {};
    final score = result['score'] as int? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Stick figure comparison
        if (masterB64 != null || studentB64 != null)
          Row(
            children: [
              if (studentB64 != null)
                Expanded(
                    child: _StickCard(
                        label: 'pose.studentLabel'.tr(),
                        b64: studentB64,
                        accentColor: AppColors.primary)),
              const SizedBox(width: 10),
              if (masterB64 != null)
                Expanded(
                    child: _StickCard(
                        label: 'pose.masterLabel'.tr(),
                        b64: masterB64,
                        accentColor: AppColors.secondary)),
            ],
          ),
        const SizedBox(height: 16),

        // Score card
        Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Text('pose.aiFeedback'.tr().toUpperCase(),
                  style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 0.12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              ShaderMask(
                shaderCallback: (b) => AppColors.gradMain.createShader(b),
                child: Text('$score',
                    style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: score / 100,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.06),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('0',
                      style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                          fontFamily: 'monospace')),
                  Text('50',
                      style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                          fontFamily: 'monospace')),
                  Text('100',
                      style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                          fontFamily: 'monospace')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Action buttons
        Row(
          children: [
            // Save button
            Expanded(
              child: GestureDetector(
                onTap: saved
                    ? null
                    : () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: AppColors.surface,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                            title: Text('pose.saveConfirmTitle'.tr(),
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                            content: Text('pose.saveConfirmBody'.tr(),
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary)),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(ctx).pop(false),
                                child: Text('pose.saveConfirmCancel'.tr(),
                                    style: TextStyle(
                                        color: AppColors.textMuted)),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(ctx).pop(true),
                                child: Text('pose.saveConfirmOk'.tr(),
                                    style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) onSave();
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: saved || saving ? null : AppColors.gradMain,
                    color: saved
                        ? AppColors.success.withValues(alpha: 0.15)
                        : saving
                            ? AppColors.muted
                            : null,
                    borderRadius: BorderRadius.circular(14),
                    border: saved
                        ? Border.all(
                            color: AppColors.success.withValues(alpha: 0.4))
                        : null,
                  ),
                  child: Center(
                    child: saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                saved
                                    ? Icons.check_circle_rounded
                                    : Icons.save_outlined,
                                size: 16,
                                color: saved
                                    ? AppColors.success
                                    : Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                saved
                                    ? 'pose.savedBtn'.tr()
                                    : 'pose.saveBtn'.tr(),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: saved
                                      ? AppColors.success
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // View Details button
            Expanded(
              child: GestureDetector(
                onTap: () => _showDetails(
                    context, feedback, masterAngles, studentAngles, score),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.article_outlined,
                            size: 16, color: AppColors.text),
                        const SizedBox(width: 6),
                        Text(
                          'pose.viewDetails'.tr(),
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showDetails(
    BuildContext context,
    String feedback,
    Map<String, dynamic> masterAngles,
    Map<String, dynamic> studentAngles,
    int score,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (_, controller) => Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Row(
                children: [
                  Text('pose.detailsTitle'.tr(),
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  ShaderMask(
                    shaderCallback: (b) => AppColors.gradMain.createShader(b),
                    child: Text('$score',
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                  ),
                ],
              ),
            ),
            Divider(color: AppColors.border, height: 1),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (masterAngles.isNotEmpty) ...[
                      _AngleTable(
                          masterAngles: masterAngles,
                          studentAngles: studentAngles),
                      const SizedBox(height: 16),
                    ],
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: SelectableText(
                        feedback,
                        style: TextStyle(
                            fontSize: 14,
                            color: AppColors.text,
                            height: 1.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickCard extends StatelessWidget {
  const _StickCard(
      {required this.label, required this.b64, required this.accentColor});
  final String label;
  final String b64;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final bytes = base64Decode(b64);
    return Column(
      children: [
        Text(label.toUpperCase(),
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: accentColor,
                letterSpacing: 0.08)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.memory(bytes, fit: BoxFit.contain),
        ),
      ],
    );
  }
}

class _AngleTable extends StatelessWidget {
  const _AngleTable(
      {required this.masterAngles, required this.studentAngles});
  final Map<String, dynamic> masterAngles;
  final Map<String, dynamic> studentAngles;

  @override
  Widget build(BuildContext context) {
    final keys = masterAngles.keys.toList();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('pose.jointAngles'.tr(),
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                flex: 3,
                child: Text('pose.jointCol'.tr(),
                    style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600))),
            Expanded(
                flex: 2,
                child: Text('pose.masterLabel'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600))),
            Expanded(
                flex: 2,
                child: Text('pose.studentLabel'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600))),
            Expanded(
                flex: 2,
                child: Text('pose.diffCol'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600))),
          ]),
          const SizedBox(height: 8),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          ...keys.map((k) {
            final mv = (masterAngles[k] as num).toDouble();
            final sv =
                (studentAngles[k] as num?)?.toDouble() ?? mv;
            final diff = sv - mv;
            final color = diff.abs() < 10
                ? const Color(0xFF10B981)
                : diff.abs() < 20
                    ? const Color(0xFFFACC15)
                    : AppColors.primary;
            final sign = diff >= 0 ? '+' : '';
            final translated = 'pose.angles.$k'.tr();
            final keyLabel = translated.startsWith('pose.angles.') ? k : translated;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                Expanded(
                    flex: 3,
                    child: Text(keyLabel,
                        style: TextStyle(
                            fontSize: 12, color: AppColors.text))),
                Expanded(
                    flex: 2,
                    child: Text('${mv.toStringAsFixed(1)}°',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary))),
                Expanded(
                    flex: 2,
                    child: Text('${sv.toStringAsFixed(1)}°',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary))),
                Expanded(
                    flex: 2,
                    child: Text('$sign${diff.toStringAsFixed(1)}°',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: color))),
              ]),
            );
          }),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: TextStyle(fontSize: 13, color: AppColors.text)),
          ),
        ],
      ),
    );
  }
}

// ─── Records screen ───────────────────────────────────
class _PoseRecordsScreen extends ConsumerStatefulWidget {
  const _PoseRecordsScreen();

  @override
  ConsumerState<_PoseRecordsScreen> createState() => _PoseRecordsScreenState();
}

class _PoseRecordsScreenState extends ConsumerState<_PoseRecordsScreen> {
  static const _pageSize = 7;

  String? _selectedTulId;
  int? _selectedMovementNo;
  int _page = 1;

  List<Map<String, dynamic>> _tulList = [];
  Map<String, dynamic>? _pageData;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTulList();
    _fetch();
  }

  Future<void> _loadTulList() async {
    try {
      final list = await ref.read(backendClientProvider).getTulList();
      if (mounted) setState(() => _tulList = list);
    } catch (_) {}
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ref.read(backendClientProvider).getPoseRecords(
            tulName: _selectedTulId,
            movementNo: _selectedMovementNo,
            page: _page,
            pageSize: _pageSize,
          );
      if (mounted) setState(() { _pageData = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _selectTul(String? tulId) {
    setState(() {
      _selectedTulId = tulId;
      _selectedMovementNo = null;
      _page = 1;
    });
    _fetch();
  }

  void _selectMovement(int? no) {
    setState(() { _selectedMovementNo = no; _page = 1; });
    _fetch();
  }

  List<Map<String, dynamic>> get _currentMovements {
    if (_selectedTulId == null) return [];
    final tul = _tulList.firstWhere(
      (t) => t['id'] == _selectedTulId,
      orElse: () => {},
    );
    return (tul['movements'] as List?)?.cast<Map<String, dynamic>>() ?? [];
  }

  String _chipLabel(String name) {
    final idx = name.indexOf('(');
    return idx > 0 ? name.substring(0, idx).trim() : name;
  }

  @override
  Widget build(BuildContext context) {
    final records =
        (_pageData?['records'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final totalPages = (_pageData?['total_pages'] as int?) ?? 1;
    final total = (_pageData?['total'] as int?) ?? 0;
    final rangeFrom = total == 0 ? 0 : (_page - 1) * _pageSize + 1;
    final rangeTo = (_page * _pageSize).clamp(0, total);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header ───────────────────────────────────
          Container(
            color: AppColors.stage,
            padding: const EdgeInsets.fromLTRB(16, 52, 16, 14),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
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
                ),
                const SizedBox(width: 12),
                Text('pose.recordsTitle'.tr(),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
          ),

          // ── Dropdown filter ───────────────────────────
          if (_tulList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Row(
                children: [
                  Expanded(
                    child: _RecordsDropdown<String?>(
                      value: _selectedTulId,
                      hint: 'pose.allPatterns'.tr(),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text('pose.allPatterns'.tr()),
                        ),
                        ..._tulList.map((t) => DropdownMenuItem(
                              value: t['id'] as String,
                              child: Text(_chipLabel(t['name'] as String)),
                            )),
                      ],
                      onChanged: (v) => _selectTul(v),
                    ),
                  ),
                  if (_selectedTulId != null && _currentMovements.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: _RecordsDropdown<int?>(
                        value: _selectedMovementNo,
                        hint: 'pose.allMovements'.tr(),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text('pose.allMovements'.tr()),
                          ),
                          ..._currentMovements.map((m) {
                            final no = m['no'] as int;
                            return DropdownMenuItem(
                              value: no,
                              child: Text('$no번  ${m['name'] ?? ''}'),
                            );
                          }),
                        ],
                        onChanged: (v) => _selectMovement(v),
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // ── List ─────────────────────────────────────
          Expanded(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : _error != null
                    ? Center(
                        child: Text(_error!,
                            style: TextStyle(color: AppColors.textMuted)))
                    : records.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.history_rounded,
                                    size: 48,
                                    color: AppColors.textMuted
                                        .withValues(alpha: 0.4)),
                                const SizedBox(height: 12),
                                Text('pose.noRecords'.tr(),
                                    style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 14)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                            itemCount: records.length,
                            itemBuilder: (context, i) {
                              final record = records[i];
                              final id = record['id'] as int;
                              return Dismissible(
                                key: ValueKey(id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(Icons.delete_outline_rounded,
                                      color: Colors.white, size: 22),
                                ),
                                confirmDismiss: (_) async {
                                  return await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      backgroundColor: AppColors.surface,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18)),
                                      title: Text(
                                          'pose.deleteConfirmTitle'.tr(),
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700)),
                                      content: Text(
                                          'pose.deleteConfirmBody'.tr(),
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: AppColors.textSecondary)),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(false),
                                          child: Text(
                                              'pose.deleteConfirmCancel'.tr(),
                                              style: TextStyle(
                                                  color: AppColors.textMuted)),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(true),
                                          child: Text(
                                              'pose.deleteConfirmOk'.tr(),
                                              style: TextStyle(
                                                  color: AppColors.primary,
                                                  fontWeight:
                                                      FontWeight.w700)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                onDismissed: (_) async {
                                  final messenger =
                                      ScaffoldMessenger.of(context);
                                  try {
                                    await ref
                                        .read(backendClientProvider)
                                        .deletePoseRecord(id);
                                    if (!mounted) return;
                                    setState(() {
                                      records.removeAt(i);
                                      if (records.isEmpty && _page > 1) {
                                        _page--;
                                        _fetch();
                                      }
                                    });
                                  } catch (e) {
                                    messenger.showSnackBar(
                                        SnackBar(content: Text(e.toString())));
                                    if (mounted) _fetch();
                                  }
                                },
                                child: _RecordCard(record: record),
                              );
                            },
                          ),
          ),

          // ── Pagination ────────────────────────────────
          if (!_loading && records.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PagBtn(
                    icon: Icons.chevron_left_rounded,
                    enabled: _page > 1,
                    onTap: () { setState(() => _page--); _fetch(); },
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_page / $totalPages',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '$rangeFrom–$rangeTo / $total',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  _PagBtn(
                    icon: Icons.chevron_right_rounded,
                    enabled: _page < totalPages,
                    onTap: () { setState(() => _page++); _fetch(); },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RecordsDropdown<T> extends StatelessWidget {
  const _RecordsDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });
  final T value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.surface,
          icon: Icon(Icons.expand_more_rounded,
              color: AppColors.textMuted, size: 18),
          style: TextStyle(fontSize: 13, color: AppColors.text),
          hint: Text(hint,
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              overflow: TextOverflow.ellipsis),
          onChanged: onChanged,
          items: items,
        ),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record});
  final Map<String, dynamic> record;

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.parse(record['created_at'] as String).toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final recordDay = DateTime(createdAt.year, createdAt.month, createdAt.day);

    String dayLabel;
    if (recordDay == today) {
      dayLabel = 'Today';
    } else if (recordDay == yesterday) {
      dayLabel = 'Yesterday';
    } else {
      dayLabel = DateFormat('MMM d').format(createdAt);
    }
    final timeFmt = DateFormat('HH:mm').format(createdAt);

    final tulDisplay = record['tul_display_name'] as String;
    final movNo = record['movement_no'] as int;
    final movName = record['movement_name'] as String;
    final score = record['score'] as int?;
    final feedback = record['feedback'] as String? ?? '';

    final shortTul = tulDisplay.contains('(')
        ? tulDisplay.substring(0, tulDisplay.indexOf('(')).trim()
        : tulDisplay;

    return GestureDetector(
      onTap: () => _showDetail(context, tulDisplay, movNo, movName,
          '$dayLabel · $timeFmt', feedback, score),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Thumbnail placeholder
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.gradSoft,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Text(
                  '$movNo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Title + date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$shortTul M$movNo',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$dayLabel · $timeFmt',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            // Score
            if (score != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ShaderMask(
                    shaderCallback: (b) => AppColors.gradMain.createShader(b),
                    child: Text(
                      '$score',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                  ),
                  Text('score',
                      style: TextStyle(
                          fontSize: 10, color: AppColors.textMuted)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, String tulDisplay, int movNo,
      String movName, String dateLabel, String feedback, int? score) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (_, controller) => Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$tulDisplay · $movNo. $movName',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(dateLabel,
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  if (score != null) ...[
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (b) =>
                              AppColors.gradMain.createShader(b),
                          child: Text('$score',
                              style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                        ),
                        Text('score',
                            style: TextStyle(
                                fontSize: 10, color: AppColors.textMuted)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Divider(color: AppColors.border, height: 1),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: SelectableText(
                  feedback,
                  style:
                      TextStyle(fontSize: 14, color: AppColors.text, height: 1.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pagination widgets ───────────────────────────────
class _PagBtn extends StatelessWidget {
  const _PagBtn(
      {required this.icon, required this.enabled, required this.onTap});
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: enabled ? AppColors.border : Colors.transparent),
        ),
        child: Icon(icon,
            size: 20,
            color: enabled ? AppColors.text : AppColors.textDisabled),
      ),
    );
  }
}

