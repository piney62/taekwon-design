import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/pattern_image_provider.dart';
import '../../domain/entities/pattern.dart';

const _directions = ['front', 'back', 'left', 'right'];

String _dirLabel(String d) =>
    'learn.dir${d[0].toUpperCase()}${d.substring(1)}'.tr();

class PatternDetailScreen extends ConsumerStatefulWidget {
  const PatternDetailScreen({
    super.key,
    required this.pattern,
    required this.index,
  });

  final ItfPattern pattern;
  final int index;

  @override
  ConsumerState<PatternDetailScreen> createState() => _PatternDetailScreenState();
}

class _PatternDetailScreenState extends ConsumerState<PatternDetailScreen> {
  // 0 = 준비동작, 1~N = 동작 번호
  int _moveIndex = 0;
  String _direction = 'front';
  bool _showVideo = false;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToMove(int move) {
    final clamped = move.clamp(0, widget.pattern.moves);
    setState(() => _moveIndex = clamped);
    _pageController.animateToPage(
      clamped,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final badgeText = _moveIndex == 0
        ? 'learn.moveReady'.tr()
        : 'learn.badgeTextFmt'.tr(namedArgs: {'no': _moveIndex.toString(), 'total': widget.pattern.moves.toString()});
    final navLabel = _moveIndex == 0
        ? 'learn.preparationMove'.tr()
        : 'learn.moveNumberFmt'.tr(namedArgs: {'no': _moveIndex.toString()});

    final faction = ref.watch(currentFactionProvider);
    final versionsAsync = ref.watch(patternVersionsProvider(faction));
    final version = versionsAsync.maybeWhen(
      data: (v) => v[widget.pattern.slug] ?? 1,
      orElse: () => 1,
    );

    final totalPages = widget.pattern.moves + 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          '${widget.index}. ${widget.pattern.name} (${widget.pattern.korean})',
          style: const TextStyle(fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          // 탭 선택
          _TabBar(
            showVideo: _showVideo,
            onToggle: (v) => setState(() => _showVideo = v),
          ),

          // 이미지 뷰어 / 동영상 플레이어
          Expanded(
            flex: 5,
            child: _showVideo
                ? _VideoSection(
                    slug: widget.pattern.slug,
                    faction: faction,
                  )
                : Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: totalPages,
                        onPageChanged: (i) => setState(() => _moveIndex = i),
                        itemBuilder: (context, i) {
                          final url = patternImageUrl(
                            widget.pattern.slug, i, _direction, version,
                            faction: faction,
                          );
                          final cacheKey = patternImageCacheKey(
                            widget.pattern.slug, i, _direction, version,
                            faction: faction,
                          );
                          return _MoveImage(url: url, cacheKey: cacheKey);
                        },
                      ),
                      // 동작 번호 뱃지
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      // 전체화면 버튼
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          onPressed: () {
                            final url = patternImageUrl(
                              widget.pattern.slug, _moveIndex, _direction, version,
                              faction: faction,
                            );
                            final cacheKey = patternImageCacheKey(
                              widget.pattern.slug, _moveIndex, _direction, version,
                              faction: faction,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => _FullscreenImagePage(
                                  url: url,
                                  cacheKey: cacheKey,
                                  label: navLabel,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.fullscreen, size: 28),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),

          // 이미지 탭일 때만 방향 선택 / 동작 네비게이션 표시
          if (!_showVideo) ...[
            _DirectionBar(
              selected: _direction,
              onSelect: (d) => setState(() => _direction = d),
            ),
            _MoveNavBar(
              label: navLabel,
              canPrev: _moveIndex > 0,
              canNext: _moveIndex < widget.pattern.moves,
              onPrev: () => _goToMove(_moveIndex - 1),
              onNext: () => _goToMove(_moveIndex + 1),
            ),
          ],

        ],
      ),
    );
  }
}

// ─── 탭 선택 바 ──────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  const _TabBar({required this.showVideo, required this.onToggle});

  final bool showVideo;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(child: _TabButton(label: 'learn.imageStudy'.tr(), selected: !showVideo, onTap: () => onToggle(false))),
          const SizedBox(width: 8),
          Expanded(child: _TabButton(label: 'learn.videoStudy'.tr(), selected: showVideo, onTap: () => onToggle(true))),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.itfRed : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.itfRed : AppColors.outline,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ─── 동영상 섹션 ──────────────────────────────────────────────────────────────

class _VideoSection extends StatefulWidget {
  const _VideoSection({required this.slug, required this.faction});

  final String slug;
  final String faction;

  @override
  State<_VideoSection> createState() => _VideoSectionState();
}

class _VideoSectionState extends State<_VideoSection> {
  VideoPlayerController? _vpController;
  ChewieController? _chewieController;
  bool _loading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    final url = patternVideoUrl(widget.slug, faction: widget.faction);
    final vpc = VideoPlayerController.networkUrl(Uri.parse(url));
    try {
      await vpc.initialize();
      if (!mounted) {
        vpc.dispose();
        return;
      }
      _vpController = vpc;
      _chewieController = ChewieController(
        videoPlayerController: vpc,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.itfRed,
          handleColor: AppColors.itfRed,
          bufferedColor: AppColors.itfRed.withValues(alpha: 0.3),
          backgroundColor: AppColors.outline,
        ),
      );
      setState(() => _loading = false);
    } catch (_) {
      vpc.dispose();
      if (mounted) setState(() { _loading = false; _hasError = true; });
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _vpController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.itfRed));
    }
    if (_hasError) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.videocam_off_outlined, size: 64, color: AppColors.textDisabled),
          const SizedBox(height: 8),
          Text('learn.videoLoading'.tr(), style: const TextStyle(color: AppColors.textDisabled, fontSize: 13)),
        ],
      );
    }
    return Chewie(controller: _chewieController!);
  }
}

// ─── 이미지 뷰어 ──────────────────────────────────────────────────────────────

class _MoveImage extends StatelessWidget {
  const _MoveImage({required this.url, required this.cacheKey});

  final String url;
  final String cacheKey;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 1.0,
      maxScale: 5.0,
      child: CachedNetworkImage(
        imageUrl: url,
        cacheKey: cacheKey,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(color: AppColors.itfRed),
        ),
        errorWidget: (context, url, error) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_not_supported_outlined,
                size: 64, color: AppColors.textDisabled),
            const SizedBox(height: 8),
            Text(
              'learn.imageLoading'.tr(),
              style: const TextStyle(color: AppColors.textDisabled, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 방향 탭 ──────────────────────────────────────────────────────────────────

class _DirectionBar extends StatelessWidget {
  const _DirectionBar({required this.selected, required this.onSelect});

  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _directions.map((d) {
          final isSelected = d == selected;
          return GestureDetector(
            onTap: () => onSelect(d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.itfRed : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.itfRed : AppColors.outline,
                ),
              ),
              child: Text(
                _dirLabel(d),
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── 동작 네비게이션 ──────────────────────────────────────────────────────────

class _MoveNavBar extends StatelessWidget {
  const _MoveNavBar({
    required this.label,
    required this.canPrev,
    required this.canNext,
    required this.onPrev,
    required this.onNext,
  });

  final String label;
  final bool canPrev;
  final bool canNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceVariant,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: canPrev ? onPrev : null,
            icon: const Icon(Icons.chevron_left, size: 32),
            color: canPrev ? AppColors.itfRed : AppColors.textDisabled,
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: canNext ? onNext : null,
            icon: const Icon(Icons.chevron_right, size: 32),
            color: canNext ? AppColors.itfRed : AppColors.textDisabled,
          ),
        ],
      ),
    );
  }
}

// ─── 전체화면 이미지 페이지 ───────────────────────────────────────────────────

class _FullscreenImagePage extends StatelessWidget {
  const _FullscreenImagePage({
    required this.url,
    required this.cacheKey,
    required this.label,
  });

  final String url;
  final String cacheKey;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 15)),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1.0,
          maxScale: 8.0,
          child: CachedNetworkImage(
            imageUrl: url,
            cacheKey: cacheKey,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
            placeholder: (context, url) =>
                const CircularProgressIndicator(color: AppColors.itfRed),
            errorWidget: (context, url, error) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.image_not_supported_outlined, size: 64, color: Colors.white38),
                const SizedBox(height: 8),
                Text('learn.imageLoading'.tr(), style: const TextStyle(color: Colors.white38, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
