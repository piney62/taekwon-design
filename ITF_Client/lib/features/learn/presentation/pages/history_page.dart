import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: _events.length,
                itemBuilder: (context, i) => _TimelineItem(
                  event: _events[i],
                  isLast: i == _events.length - 1,
                ),
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
            'learn.history'.tr(),
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

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.event, required this.isLast});

  final _Event event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final title = locale == 'ko' ? event.titleKo : event.titleEn;
    final desc = locale == 'ko' ? event.descKo : event.descEn;
    final dotColor =
        event.isHighlight ? AppColors.primary : AppColors.textDisabled;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // timeline column
          SizedBox(
            width: 24,
            child: Column(
              children: [
                const SizedBox(height: 6),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: event.isHighlight
                      ? AppColors.primary.withValues(alpha: 0.08)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: event.isHighlight
                        ? AppColors.primary.withValues(alpha: 0.25)
                        : AppColors.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.year,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: event.isHighlight
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      desc,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data ───────────────────────────────────────────────────────────────────────

class _Event {
  const _Event({
    required this.year,
    required this.titleKo,
    required this.titleEn,
    required this.descKo,
    required this.descEn,
    this.isHighlight = false,
  });

  final String year;
  final String titleKo;
  final String titleEn;
  final String descKo;
  final String descEn;
  final bool isHighlight;
}

const _events = [
  _Event(
    year: '1955',
    titleKo: '태권도 명칭 제정',
    titleEn: 'Name "Taekwondo" Adopted',
    descKo: '최홍희 장군이 새로운 무술의 이름으로 "태권도"를 제안하여 공식 채택되었습니다.',
    descEn:
        'General Choi Hong-Hi proposed the name "Taekwondo" for the new '
        'Korean martial art, which was officially adopted.',
  ),
  _Event(
    year: '1959',
    titleKo: '대한태권도협회 창설',
    titleEn: 'Korea Taekwondo Association Founded',
    descKo:
        '최홍희 장군이 초대 회장으로 대한태권도협회를 창설하고 태권도 보급에 앞장섰습니다.',
    descEn:
        'General Choi Hong-Hi became the first president of the '
        'Korea Taekwondo Association, driving the spread of Taekwondo.',
  ),
  _Event(
    year: '1966',
    titleKo: 'ITF(국제태권도연맹) 창설',
    titleEn: 'ITF Founded',
    descKo:
        '최홍희 장군이 서울에서 국제태권도연맹(ITF)을 창설하였습니다. '
        '이것이 현재 전 세계에 보급된 ITF 태권도의 시작입니다.',
    descEn:
        'General Choi Hong-Hi founded the International Taekwon-Do Federation '
        '(ITF) in Seoul — the official birth of ITF Taekwon-Do as practiced worldwide.',
    isHighlight: true,
  ),
  _Event(
    year: '1972',
    titleKo: 'ITF 본부 캐나다 이전',
    titleEn: 'ITF Headquarters Moved to Canada',
    descKo: '정치적 이유로 ITF 본부가 캐나다 토론토로 이전되었습니다.',
    descEn:
        'Due to political reasons, the ITF headquarters was relocated to Toronto, Canada.',
  ),
  _Event(
    year: '1983',
    titleKo: '태권도 백과사전 출판',
    titleEn: 'Taekwon-Do Encyclopedia Published',
    descKo:
        '최홍희 장군이 15권으로 구성된 "태권도 백과사전"을 출판하여 '
        'ITF 태권도의 기술과 철학을 체계적으로 정립하였습니다.',
    descEn:
        'General Choi published the 15-volume "Taekwon-Do Encyclopedia", '
        'systematically documenting all techniques and philosophy of ITF Taekwon-Do.',
  ),
  _Event(
    year: '2002',
    titleKo: '최홍희 장군 별세',
    titleEn: 'General Choi Passes Away',
    descKo:
        'ITF 태권도의 창시자 최홍희 장군이 별세하였습니다. '
        '그의 유산은 전 세계 수백만 명의 수련생들을 통해 계속 이어지고 있습니다.',
    descEn:
        'General Choi Hong-Hi, the founder of ITF Taekwon-Do, passed away. '
        'His legacy continues through millions of practitioners worldwide.',
  ),
  _Event(
    year: 'Today',
    titleKo: 'ITF 태권도의 세계 보급',
    titleEn: 'ITF Taekwon-Do Worldwide',
    descKo:
        'ITF 태권도는 현재 전 세계 100여 개국에 보급되어 있으며, '
        '전통 무술로서의 가치와 스포츠로서의 발전을 함께 추구하고 있습니다.',
    descEn:
        'ITF Taekwon-Do is now practiced in over 100 countries worldwide, '
        'preserving its value as a traditional martial art while continuing to grow.',
  ),
];
