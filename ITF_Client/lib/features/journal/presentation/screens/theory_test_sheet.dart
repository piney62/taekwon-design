import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/backend_client.dart';
import '../../../../core/theme/app_colors.dart';

const int _kPassScore = 70;

// ── Entry point ────────────────────────────────────────────────────────────

Future<void> showTheoryTestSheet(
    BuildContext context, WidgetRef ref, String beltLevel,
    {void Function(int score)? onPassed}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _TheoryTestSheet(beltLevel: beltLevel, onPassed: onPassed),
  );
}

// ── State ──────────────────────────────────────────────────────────────────

enum _Phase { loading, questions, submitting, result, error }

class _Q {
  _Q({required this.question, required this.expectedAnswer});
  final String question;
  final String expectedAnswer;
  String userAnswer = '';
}

// ── Sheet ──────────────────────────────────────────────────────────────────

class _TheoryTestSheet extends ConsumerStatefulWidget {
  const _TheoryTestSheet({required this.beltLevel, this.onPassed});
  final String beltLevel;
  final void Function(int score)? onPassed;

  @override
  ConsumerState<_TheoryTestSheet> createState() => _TheoryTestSheetState();
}

class _TheoryTestSheetState extends ConsumerState<_TheoryTestSheet> {
  _Phase _phase = _Phase.loading;
  List<_Q> _questions = [];
  int _currentIdx = 0;
  String _resultText = '';
  String _errorText = '';
  int _score = 0;
  final _answerCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _answerCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() => _phase = _Phase.loading);
    try {
      final beltLabel = _beltLabel(widget.beltLevel);
      final prompt = '''
You are an ITF Taekwondo examiner. Generate exactly 5 theory test questions suitable for a $beltLabel student.
Return ONLY a JSON array like this (no other text, no markdown):
[
  {"q": "Question text here?", "a": "Expected answer here"},
  ...
]
Topics: ITF tenets, patterns (tuls), history, terminology, etiquette, techniques.
''';
      final reply = await ref.read(backendClientProvider).chat([
        {'role': 'user', 'content': prompt},
      ]);

      final parsed = _parseQuestions(reply);
      if (parsed.isEmpty) throw Exception('Failed to parse questions');

      setState(() {
        _questions = parsed;
        _currentIdx = 0;
        _answerCtrl.clear();
        _phase = _Phase.questions;
      });
    } catch (e) {
      setState(() {
        _errorText = e.toString();
        _phase = _Phase.error;
      });
    }
  }

  List<_Q> _parseQuestions(String raw) {
    try {
      final start = raw.indexOf('[');
      final end = raw.lastIndexOf(']');
      if (start == -1 || end == -1) return [];
      final jsonStr = raw.substring(start, end + 1);
      final list = jsonDecode(jsonStr) as List;
      return list.map((item) {
        final m = item as Map<String, dynamic>;
        return _Q(
          question: m['q'] as String? ?? m['question'] as String? ?? '',
          expectedAnswer: m['a'] as String? ?? m['answer'] as String? ?? '',
        );
      }).where((q) => q.question.isNotEmpty).toList();
    } catch (_) {
      return [];
    }
  }

  void _saveAnswer() {
    _questions[_currentIdx].userAnswer = _answerCtrl.text.trim();
  }

  void _goNext() {
    _saveAnswer();
    if (_currentIdx < _questions.length - 1) {
      setState(() {
        _currentIdx++;
        _answerCtrl.text = _questions[_currentIdx].userAnswer;
      });
    } else {
      _submitAnswers();
    }
  }

  Future<void> _submitAnswers() async {
    _saveAnswer();
    setState(() => _phase = _Phase.submitting);
    try {
      final qaPairs = _questions.asMap().entries.map((e) {
        final i = e.key + 1;
        final q = e.value;
        return 'Q$i: ${q.question}\nStudent answer: ${q.userAnswer.isEmpty ? "(no answer)" : q.userAnswer}\nExpected: ${q.expectedAnswer}';
      }).join('\n\n');

      final evalPrompt = '''
You are an ITF Taekwondo examiner. Evaluate the following student answers for a ${_beltLabel(widget.beltLevel)} theory test.

$qaPairs

For each question, give a brief verdict (Correct / Partially correct / Incorrect) and a short explanation.
At the end, give a brief overall summary.
On the very last line, write exactly this format (nothing else on that line):
SCORE: XX
where XX is the numeric overall score from 0 to 100.
''';

      final result = await ref.read(backendClientProvider).chat([
        {'role': 'user', 'content': evalPrompt},
      ]);

      final score = _parseScore(result);
      if (score >= _kPassScore) {
        widget.onPassed?.call(score);
      }

      setState(() {
        _resultText = result;
        _score = score;
        _phase = _Phase.result;
      });
    } catch (e) {
      setState(() {
        _errorText = e.toString();
        _phase = _Phase.error;
      });
    }
  }

  static int _parseScore(String text) {
    // primary: "SCORE: XX" on its own line
    final m1 = RegExp(r'SCORE:\s*(\d+)', caseSensitive: false).firstMatch(text);
    if (m1 != null) return (int.tryParse(m1.group(1)!) ?? 0).clamp(0, 100);
    // fallback: "XX/100"
    final m2 = RegExp(r'(\d+)\s*/\s*100').firstMatch(text);
    if (m2 != null) return (int.tryParse(m2.group(1)!) ?? 0).clamp(0, 100);
    return 0;
  }

  static String _beltLabel(String beltLevel) {
    return switch (beltLevel) {
      'white'  => 'White Belt',
      'yellow' => 'Yellow Belt',
      'green'  => 'Green Belt',
      'blue'   => 'Blue Belt',
      'red'    => 'Red Belt',
      'black'  => 'Black Belt',
      _        => beltLevel,
    };
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradMain,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.bolt_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'journal.theoryTestResult'.tr(),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close_rounded,
                        color: AppColors.textMuted, size: 22),
                  ),
                ],
              ),
            ),
            Divider(color: AppColors.border, height: 24),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return switch (_phase) {
      _Phase.loading    => _LoadingView(label: 'journal.theoryTestLoading'.tr()),
      _Phase.submitting => _LoadingView(label: 'journal.theoryTestEvaluating'.tr()),
      _Phase.error      => _ErrorView(message: _errorText, onRetry: _loadQuestions),
      _Phase.questions  => _QuestionsView(
          questions: _questions,
          currentIdx: _currentIdx,
          controller: _answerCtrl,
          onNext: _goNext,
        ),
      _Phase.result => _ResultView(
          resultText: _resultText,
          score: _score,
          passed: _score >= _kPassScore,
          onRetry: _loadQuestions,
          onClose: () => Navigator.pop(context),
        ),
    };
  }
}

// ── Sub-views ──────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 20),
            Text(label,
                style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                color: AppColors.primary, size: 48),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppColors.gradMain,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('journal.theoryTestRetry'.tr(),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionsView extends StatelessWidget {
  const _QuestionsView({
    required this.questions,
    required this.currentIdx,
    required this.controller,
    required this.onNext,
  });

  final List<_Q> questions;
  final int currentIdx;
  final TextEditingController controller;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final q = questions[currentIdx];
    final isLast = currentIdx == questions.length - 1;
    final progress = (currentIdx + 1) / questions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'journal.theoryTestQuestion'.tr(namedArgs: {
                'no': '${currentIdx + 1}',
                'total': '${questions.length}',
              }),
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const Spacer(),
            Text(
              '${((progress) * 100).round()}%',
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: AppColors.muted,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.gradSoft,
            borderRadius: BorderRadius.circular(18),
            border:
                Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Text(
            q.question,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600, height: 1.5),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          maxLines: 5,
          style: const TextStyle(fontSize: 14, height: 1.5),
          decoration: InputDecoration(
            hintText: '답변을 입력하세요...',
            hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: onNext,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: AppColors.gradMain,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                isLast
                    ? 'journal.theoryTestSubmit'.tr()
                    : 'journal.theoryTestNext'.tr(),
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.resultText,
    required this.score,
    required this.passed,
    required this.onRetry,
    required this.onClose,
  });

  final String resultText;
  final int score;
  final bool passed;
  final VoidCallback onRetry;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Score banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: passed
                ? AppColors.success.withValues(alpha: 0.12)
                : AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: passed
                  ? AppColors.success.withValues(alpha: 0.35)
                  : AppColors.primary.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: passed
                      ? AppColors.success.withValues(alpha: 0.2)
                      : AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  passed
                      ? Icons.emoji_events_rounded
                      : Icons.replay_rounded,
                  color: passed ? AppColors.success : AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      passed
                          ? 'journal.theoryTestPassedBanner'
                              .tr(namedArgs: {'score': '$score'})
                          : 'journal.theoryTestFailedBanner'
                              .tr(namedArgs: {'score': '$score'}),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color:
                            passed ? AppColors.success : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      passed
                          ? 'journal.theoryTestPassedDesc'.tr()
                          : 'journal.theoryTestFailedDesc'
                              .tr(namedArgs: {'pass': '$_kPassScore'}),
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Detail text
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: SelectableText(
            // strip the "SCORE: XX" line from display
            resultText
                .replaceAll(RegExp(r'SCORE:\s*\d+\s*', caseSensitive: false), '')
                .trim(),
            style:
                TextStyle(fontSize: 14, color: AppColors.text, height: 1.6),
          ),
        ),
        const SizedBox(height: 20),

        if (!passed) ...[
          GestureDetector(
            onTap: onRetry,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.gradMain,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  'journal.theoryTestRetry'.tr(),
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],

        GestureDetector(
          onTap: onClose,
          child: Container(
            height: passed ? 52 : 48,
            decoration: BoxDecoration(
              gradient: passed ? AppColors.gradMain : null,
              color: passed ? null : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: passed ? null : Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Text(
                'journal.theoryTestClose'.tr(),
                style: TextStyle(
                  fontSize: passed ? 15 : 14,
                  fontWeight: FontWeight.w600,
                  color: passed ? Colors.white : AppColors.textMuted,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
