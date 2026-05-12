import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class TerminologyPage extends StatefulWidget {
  const TerminologyPage({super.key});

  @override
  State<TerminologyPage> createState() => _TerminologyPageState();
}

class _TerminologyPageState extends State<TerminologyPage> {
  String _cat = 'stance';
  String _query = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_Term> get _filtered {
    final list = _data[_cat] ?? [];
    if (_query.isEmpty) return list;
    final q = _query.toLowerCase();
    return list
        .where((t) =>
            t.korean.contains(q) ||
            t.romanized.toLowerCase().contains(q) ||
            t.english.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context),
            _buildChips(),
            _buildSearchBar(),
            Expanded(child: _buildList()),
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
            'learn.terminology'.tr(),
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

  Widget _buildChips() {
    final cats = [
      ('stance', 'Stances'),
      ('block', 'Blocks'),
      ('kick', 'Kicks'),
      ('strike', 'Strikes'),
    ];
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
        children: cats.map((c) {
          final selected = _cat == c.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _cat = c.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  c.$2,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color:
                        selected ? Colors.white : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _query = v),
          style: const TextStyle(color: AppColors.text, fontSize: 13),
          decoration: const InputDecoration(
            hintText: 'Search Korean or English...',
            hintStyle:
                TextStyle(color: AppColors.textDisabled, fontSize: 13),
            prefixIcon: Icon(Icons.search_rounded,
                size: 18, color: AppColors.textDisabled),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    final items = _filtered;
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No results',
          style: const TextStyle(color: AppColors.textDisabled, fontSize: 14),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _TermCard(term: items[i]),
    );
  }
}

class _TermCard extends StatelessWidget {
  const _TermCard({required this.term});

  final _Term term;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  term.korean,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ),
              if (term.romanized.isNotEmpty)
                Text(
                  term.romanized,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textDisabled,
                    fontFamily: 'monospace',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            term.english,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          if (term.desc.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              term.desc,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  height: 1.5),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Data ───────────────────────────────────────────────────────────────────────

class _Term {
  const _Term(this.korean, this.romanized, this.english, [this.desc = '']);

  final String korean;
  final String romanized;
  final String english;
  final String desc;
}

const _data = <String, List<_Term>>{
  'stance': [
    _Term('차렷 서기', 'Charyot Sogi', 'Attention Stance'),
    _Term('앞서기', 'Ap Sogi', 'Walking Stance (short)'),
    _Term('앞굽이', 'Ap Kubi', 'Walking Stance (long)',
        'Front leg bent, back leg straight.'),
    _Term('뒤굽이', 'Niunja Sogi', 'L-Stance',
        '70% weight on back leg, foot at 90°.'),
    _Term('기마 서기', 'Gima Sogi', 'Sitting Stance',
        'Equal weight, knees bent outward.'),
    _Term('모아 서기', 'Moa Sogi', 'Close Stance'),
    _Term('나란히 서기', 'Narani Sogi', 'Parallel Stance'),
    _Term('학다리 서기', 'Hakdari Sogi', 'One-Leg Stance'),
    _Term('꼬아 서기', 'Gyotdarim Sogi', 'X-Stance'),
  ],
  'block': [
    _Term('아래막기', 'Najunde Makgi', 'Low Block',
        'Forearm sweeps downward across body.'),
    _Term('몸통막기', 'Kaunde Makgi', 'Middle Block'),
    _Term('얼굴막기', 'Nopunde Makgi', 'High Block',
        'Forearm rises above forehead.'),
    _Term('안팔목 안에서 바깥막기', '', 'Inner Forearm Outward Block'),
    _Term('바깥팔목 안막기', '', 'Outer Forearm Inward Block'),
    _Term('손날막기', 'Sonnal Makgi', 'Knife-hand Block'),
    _Term('쌍수막기', 'Ssangsu Makgi', 'Twin Forearm Block'),
    _Term('연거푸막기', 'Yonkeo Makgi', 'Consecutive Block'),
  ],
  'kick': [
    _Term('앞차기', 'Ap Chagi', 'Front Kick',
        'Knee chambers, foot snaps forward.'),
    _Term('옆차기', 'Yop Chagi', 'Side Kick'),
    _Term('돌려차기', 'Dollyo Chagi', 'Turning Kick',
        'Hip rotates, instep strikes target.'),
    _Term('뒤차기', 'Dwitcha Gi', 'Back Kick'),
    _Term('반달차기', 'Bandal Chagi', 'Crescent Kick'),
    _Term('비틀어차기', 'Bituro Chagi', 'Twisting Kick'),
    _Term('내려차기', 'Naeryo Chagi', 'Downward Kick'),
    _Term('후려차기', 'Huryeo Chagi', 'Hooking Kick'),
  ],
  'strike': [
    _Term('지르기', 'Jireugi', 'Punch',
        'Fist drives in straight line to target.'),
    _Term('몸통 지르기', 'Kaunde Jireugi', 'Middle Punch'),
    _Term('얼굴 지르기', 'Nopunde Jireugi', 'High Punch'),
    _Term('아래 지르기', 'Najunde Jireugi', 'Low Punch'),
    _Term('찌르기', 'Tulgi', 'Thrust'),
    _Term('치기', 'Chigi', 'Strike'),
    _Term('손날치기', 'Sonnal Chigi', 'Knife-hand Strike',
        'Edge of open hand strikes outward.'),
    _Term('등주먹치기', 'Dungjumok Chigi', 'Back Fist Strike'),
  ],
};
