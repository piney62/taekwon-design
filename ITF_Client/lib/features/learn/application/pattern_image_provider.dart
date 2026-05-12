import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

const _baseUrl = 'http://localhost:8000';

/// 현재 기본 파: ITF-Vienna
/// 추후 설정 화면에서 사용자가 선택 가능하도록 확장 예정
const kDefaultFaction = 'vienna';

/// 봉사기에서 지원하는 파 목록
class ItfFaction {
  const ItfFaction({required this.id, required this.name, required this.active});
  final String id;
  final String name;
  final bool active;
}

/// 현재 선택된 파 (추후 설정 연동 시 StateProvider로 교체)
final currentFactionProvider = Provider<String>((ref) => kDefaultFaction);

/// 해당 파의 패턴 버전 정보 (slug → version)
final patternVersionsProvider =
    FutureProvider.family<Map<String, int>, String>((ref, faction) async {
  try {
    final res = await http
        .get(Uri.parse('$_baseUrl/api/v1/patterns/versions?faction=$faction'))
        .timeout(const Duration(seconds: 5));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return (data['versions'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, v as int));
    }
  } catch (_) {}
  // 봉사기 미연결 시 모두 version 1로 처리
  return {};
});

/// 이미지 URL 생성
/// 경로: /static/patterns/{faction}/{slug}/{move}_{direction}.webp?v={version}
String patternImageUrl(
  String slug,
  int moveIndex,
  String direction,
  int version, {
  String faction = kDefaultFaction,
}) {
  final move = moveIndex.toString().padLeft(2, '0');
  return '$_baseUrl/static/patterns/$faction/$slug/${move}_$direction.jpg?v=$version';
}

/// 동영상 URL: /static/videos/{faction}/{slug}.mp4
String patternVideoUrl(String slug, {String faction = kDefaultFaction}) {
  return '$_baseUrl/static/videos/$faction/$slug.mp4';
}

/// cacheKey: faction + slug + move + direction + version
/// 파가 바뀌거나 버전이 바뀌면 새로 다운로드
String patternImageCacheKey(
  String slug,
  int moveIndex,
  String direction,
  int version, {
  String faction = kDefaultFaction,
}) {
  final move = moveIndex.toString().padLeft(2, '0');
  return '${faction}_${slug}_${move}_${direction}_v$version';
}
