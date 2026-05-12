import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class FiveTenetsPage extends StatelessWidget {
  const FiveTenetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: _tenets.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) => _TenetCard(tenet: _tenets[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.chevron_left, size: 28),
            color: AppColors.text,
          ),
          Text(
            'learn.fiveSpirits'.tr(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _TenetCard extends StatelessWidget {
  const _TenetCard({required this.tenet});

  final _Tenet tenet;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final desc = locale == 'ko' ? tenet.descKo : tenet.descEn;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tenet.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(
                  child: Text(
                    tenet.han[0],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: tenet.color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tenet.english,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      '${tenet.korean} · ${tenet.han}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textDisabled,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data ───────────────────────────────────────────────────────────────────────

class _Tenet {
  const _Tenet({
    required this.english,
    required this.korean,
    required this.han,
    required this.color,
    required this.descKo,
    required this.descEn,
  });

  final String english;
  final String korean;
  final String han;
  final Color color;
  final String descKo;
  final String descEn;
}

const _tenets = [
  _Tenet(
    english: 'Courtesy',
    korean: '예의',
    han: '禮儀',
    color: AppColors.primary,
    descKo:
        '상대방을 존중하고 예의 바르게 행동하는 것. '
        '도장 안팎에서 인사를 철저히 하고, '
        '스승과 선배를 공경하며 후배를 아끼는 마음가짐.',
    descEn:
        'Respect senior and junior students; bow on entering the dojang.',
  ),
  _Tenet(
    english: 'Integrity',
    korean: '염치',
    han: '廉恥',
    color: AppColors.secondary,
    descKo:
        '옳고 그름을 알고 부끄러운 행동을 하지 않는 것. '
        '양심에 따라 행동하고 거짓이나 부정직함을 멀리하는 자세.',
    descEn:
        'Know what is right; have the will to live by it.',
  ),
  _Tenet(
    english: 'Perseverance',
    korean: '인내',
    han: '忍耐',
    color: AppColors.accent,
    descKo:
        '어떤 어려움에도 포기하지 않고 꾸준히 나아가는 것. '
        '훈련의 고통과 실패를 이겨내고 목표를 향해 끝까지 나아가는 정신.',
    descEn:
        'Patience and persistence overcome every obstacle.',
  ),
  _Tenet(
    english: 'Self-Control',
    korean: '극기',
    han: '克己',
    color: AppColors.primary,
    descKo:
        '자신의 감정과 행동을 스스로 다스리는 것. '
        '분노, 두려움, 욕심을 절제하고 흔들리지 않는 마음을 갖는 훈련.',
    descEn:
        'Master your impulses, both in training and outside.',
  ),
  _Tenet(
    english: 'Indomitable Spirit',
    korean: '백절불굴',
    han: '百折不屈',
    color: AppColors.secondary,
    descKo:
        '백 번 꺾여도 굴하지 않는 불굴의 의지. '
        '정의를 위해 강한 자 앞에서도 굴복하지 않고, '
        '역경을 이겨내는 강인한 정신력.',
    descEn:
        'Stand firm in the face of any adversity.',
  ),
];
