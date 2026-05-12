import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/backend_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/tul_buttons.dart';
import '../../../../shared/widgets/tul_modal_sheet.dart';
import '../../domain/entities/training_session.dart';
import '../../domain/entities/training_type.dart';

const _itfPatternsFallback = [
  '천지', '단군', '도산', '원효', '율곡', '중근', '퇴계', '화랑', '충무',
  '광개', '포은', '개백', '의암', '충장', '주체',
  '삼일', '유신', '최용', '연개', '을지', '문무', '서산', '세종', '통일',
];

class AddSessionSheet extends ConsumerStatefulWidget {
  const AddSessionSheet({super.key, this.existing});

  final TrainingSession? existing;

  @override
  ConsumerState<AddSessionSheet> createState() => _AddSessionSheetState();
}

class _AddSessionSheetState extends ConsumerState<AddSessionSheet> {
  late TrainingType _type;
  late int _score;
  late int _duration;
  late String _patternName;
  late final TextEditingController _notesController;
  late final TextEditingController _durationController;
  late DateTime _date;

  // Tul / movement state
  List<Map<String, dynamic>> _tulList = [];
  String? _selectedTulId;
  Set<int> _selectedMovements = {};
  bool _isLoadingTuls = true;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final s = widget.existing;
    _type = s?.type ?? TrainingType.pattern;
    _score = s?.score ?? 3;
    _duration = s?.durationMinutes ?? 60;
    _date = s?.date ?? DateTime.now();
    _patternName = s?.patternName ?? '';
    _notesController = TextEditingController(text: s?.notes ?? '');
    _durationController =
        TextEditingController(text: (s?.durationMinutes ?? 60).toString());
    _loadTulList();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _loadTulList() async {
    try {
      final list = await ref.read(backendClientProvider).getTulList();
      if (!mounted) return;

      String? tulId;
      Set<int> movements = {};

      if (list.isNotEmpty && _type == TrainingType.pattern) {
        final patternName = widget.existing?.patternName ?? '';
        if (patternName.isNotEmpty) {
          final match = list.firstWhere(
            (t) => t['name'] == patternName || t['id'] == patternName,
            orElse: () => <String, dynamic>{},
          );
          tulId = match.isEmpty
              ? list.first['id'] as String
              : match['id'] as String;
        } else {
          tulId = list.first['id'] as String;
        }

        final allMovs = _getMovementNos(list, tulId);
        final initMovs = widget.existing?.selectedMovements ?? [];
        movements = initMovs.isNotEmpty ? initMovs.toSet() : allMovs;
      }

      setState(() {
        _tulList = list;
        _selectedTulId = tulId;
        _selectedMovements = movements;
        _isLoadingTuls = false;
        if (tulId != null) {
          final tul = list.firstWhere(
            (t) => t['id'] == tulId,
            orElse: () => <String, dynamic>{},
          );
          if (tul.isNotEmpty) _patternName = tul['name'] as String;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingTuls = false);
    }
  }

  Set<int> _getMovementNos(List<Map<String, dynamic>> list, String tulId) {
    final tul = list.firstWhere(
      (t) => t['id'] == tulId,
      orElse: () => <String, dynamic>{},
    );
    if (tul.isEmpty) return {};
    return (tul['movements'] as List)
        .cast<Map<String, dynamic>>()
        .map((m) => m['no'] as int)
        .toSet();
  }

  List<Map<String, dynamic>> get _currentMovements {
    if (_selectedTulId == null || _tulList.isEmpty) return [];
    final tul = _tulList.firstWhere(
      (t) => t['id'] == _selectedTulId,
      orElse: () => <String, dynamic>{},
    );
    if (tul.isEmpty) return [];
    return (tul['movements'] as List).cast<Map<String, dynamic>>();
  }

  bool get _isAllSelected {
    final movs = _currentMovements;
    if (movs.isEmpty) return false;
    return _selectedMovements.length == movs.length;
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy.MM.dd').format(_date);
    final movements = _currentMovements;
    final isPattern = _type == TrainingType.pattern;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: TulModalSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title row
            Row(
              children: [
                Expanded(
                  child: Text(
                    _isEdit
                        ? 'journal.editSession'.tr()
                        : 'journal.addSession'.tr(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Scrollable form
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.60,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => _date = picked);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'journal.date'.tr(),
                        border: const OutlineInputBorder(),
                        suffixIcon:
                            const Icon(Icons.calendar_today, size: 18),
                      ),
                      child: Text(dateStr),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Training type
                  DropdownButtonFormField<TrainingType>(
                    value: _type,
                    decoration: InputDecoration(
                      labelText: 'journal.trainingType'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    items: TrainingType.values
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.i18nKey.tr()),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _type = v;
                        if (v == TrainingType.pattern &&
                            _selectedTulId == null &&
                            _tulList.isNotEmpty) {
                          _selectedTulId =
                              _tulList.first['id'] as String;
                          _patternName =
                              _tulList.first['name'] as String;
                          _selectedMovements =
                              _getMovementNos(_tulList, _selectedTulId!);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // ── 품새 섹션 ──────────────────────────────────────────
                  if (isPattern) ...[
                    // Tul dropdown
                    if (_isLoadingTuls)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: LinearProgressIndicator(),
                      )
                    else if (_tulList.isEmpty)
                      // Fallback: old-style Korean list, no movement select
                      DropdownButtonFormField<String>(
                        value: _patternName.isNotEmpty
                            ? _patternName
                            : _itfPatternsFallback.first,
                        decoration: InputDecoration(
                          labelText: 'journal.selectPattern'.tr(),
                          border: const OutlineInputBorder(),
                        ),
                        items: _itfPatternsFallback
                            .map((p) =>
                                DropdownMenuItem(value: p, child: Text(p)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _patternName = v ?? _patternName),
                      )
                    else
                      DropdownButtonFormField<String>(
                        value: _selectedTulId,
                        decoration: InputDecoration(
                          labelText: 'journal.selectPattern'.tr(),
                          border: const OutlineInputBorder(),
                        ),
                        items: _tulList
                            .map((t) => DropdownMenuItem(
                                  value: t['id'] as String,
                                  child: Text(t['name'] as String),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          final tul = _tulList
                              .firstWhere((t) => t['id'] == v);
                          setState(() {
                            _selectedTulId = v;
                            _patternName = tul['name'] as String;
                            _selectedMovements =
                                _getMovementNos(_tulList, v);
                          });
                        },
                      ),

                    // Movement selection chips
                    if (!_isLoadingTuls && movements.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        'journal.selectMovements'.tr(),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          // 전체 chip (always first)
                          FilterChip(
                            label: Text(
                              'journal.all'.tr(),
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                            selected: _isAllSelected,
                            selectedColor:
                                AppColors.itfRed.withValues(alpha: 0.18),
                            checkmarkColor: AppColors.itfRed,
                            onSelected: (v) {
                              setState(() {
                                _selectedMovements = v && _selectedTulId != null
                                    ? _getMovementNos(_tulList, _selectedTulId!)
                                    : {};
                              });
                            },
                          ),
                          // Individual movement chips
                          ...movements.map((m) {
                            final no = m['no'] as int;
                            return FilterChip(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              label: Text(
                                'journal.movementNo'
                                    .tr(namedArgs: {'no': '$no'}),
                                style: const TextStyle(fontSize: 11),
                              ),
                              selected: _selectedMovements.contains(no),
                              selectedColor:
                                  AppColors.itfRed.withValues(alpha: 0.12),
                              checkmarkColor: AppColors.itfRed,
                              onSelected: (v) {
                                setState(() {
                                  final next =
                                      Set<int>.from(_selectedMovements);
                                  if (v) {
                                    next.add(no);
                                  } else {
                                    next.remove(no);
                                  }
                                  _selectedMovements = next;
                                });
                              },
                            );
                          }),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                  ],

                  // Duration
                  TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'journal.duration'.tr(),
                      border: const OutlineInputBorder(),
                      suffixText: 'journal.min'.tr(),
                    ),
                    onChanged: (v) =>
                        _duration = int.tryParse(v) ?? _duration,
                  ),
                  const SizedBox(height: 12),

                  // Score
                  Text(
                    'journal.selfScore'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final star = i + 1;
                      return IconButton(
                        onPressed: () => setState(() => _score = star),
                        icon: Icon(
                          star <= _score ? Icons.star : Icons.star_border,
                          color: star <= _score
                              ? AppColors.itfRed
                              : AppColors.textSecondary,
                          size: 32,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),

                  // Notes
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'journal.notes'.tr(),
                      border: const OutlineInputBorder(),
                      hintText: 'journal.notesHint'.tr(),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

            const SizedBox(height: 8),

            // Save button
            TulPrimaryButton(
              label: _isEdit ? 'journal.update'.tr() : 'journal.save'.tr(),
              onPressed: () {
                final existing = widget.existing;
                final selectedMovs = isPattern
                    ? (_selectedMovements.toList()..sort())
                    : <int>[];
                final session = TrainingSession(
                  id: existing?.id ?? TrainingSession.generateId(),
                  date: _date,
                  durationMinutes:
                      int.tryParse(_durationController.text) ?? _duration,
                  type: _type,
                  score: _score,
                  notes: _notesController.text.trim(),
                  isAutoSaved: existing?.isAutoSaved ?? false,
                  instructorComment: existing?.instructorComment ?? '',
                  patternName: isPattern ? _patternName : '',
                  selectedMovements: selectedMovs,
                );
                Navigator.pop(context, session);
              },
            ),
          ],
        ),
      ),
    );
  }
}
