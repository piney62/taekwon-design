import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../storage/secure_storage_service.dart';
import 'http_client_provider.dart';

class BackendClient {
  BackendClient({required this.secureStorage, required this.httpClient});

  final SecureStorageService secureStorage;
  final http.Client httpClient;

  static const _base = 'http://localhost:8000/api/v1';
  static const _kAccess = 'auth.access_token';
  static const _kRefresh = 'auth.refresh_token';

  Future<bool> get isLoggedIn => secureStorage.contains(_kAccess);

  Future<Map<String, String>> _headers() async {
    final token = await secureStorage.read(_kAccess);
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> _saveTokens(Map<String, dynamic> json) async {
    await secureStorage.write(_kAccess, json['access_token'] as String);
    await secureStorage.write(_kRefresh, json['refresh_token'] as String);
  }

  Future<void> clearTokens() async {
    await secureStorage.delete(_kAccess);
    await secureStorage.delete(_kRefresh);
  }

  Future<void> _doRefresh() async {
    final token = await secureStorage.read(_kRefresh);
    if (token == null) {
      await clearTokens();
      throw Exception('unauthorized:no_refresh_token');
    }
    final res = await httpClient.post(
      Uri.parse('$_base/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': token}),
    );
    if (res.statusCode != 200) {
      await clearTokens();
      throw Exception('unauthorized:refresh_failed');
    }
    await _saveTokens(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<T> _withRefresh<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } catch (e) {
      if (!e.toString().startsWith('unauthorized:')) rethrow;
      await _doRefresh();
      return fn();
    }
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<void> register({
    required String username,
    required String displayName,
    required String password,
    String role = 'student',
    String? email,
    String? beltLevel,
    int? trainingStartYear,
    String? dojoName,
    String? danRank,
  }) async {
    final res = await httpClient.post(
      Uri.parse('$_base/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'display_name': displayName,
        'password': password,
        'role': role,
        if (email != null && email.isNotEmpty) 'email': email,
        if (beltLevel != null) 'belt_level': beltLevel,
        if (trainingStartYear != null) 'training_start_year': trainingStartYear,
        if (dojoName != null) 'dojo_name': dojoName,
        if (danRank != null) 'dan_rank': danRank,
      }),
    );
    _check(res, 201);
    await _saveTokens(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    final res = await httpClient.post(
      Uri.parse('$_base/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    _check(res, 200);
    await _saveTokens(jsonDecode(res.body) as Map<String, dynamic>);
  }

  // ── User ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getMe() => _withRefresh(() async {
        final res = await httpClient.get(
          Uri.parse('$_base/users/me'),
          headers: await _headers(),
        );
        _check(res, 200);
        return jsonDecode(res.body) as Map<String, dynamic>;
      });

  Future<void> updateMe({String? displayName, String? beltLevel}) =>
      _withRefresh(() async {
        final res = await httpClient.put(
          Uri.parse('$_base/users/me'),
          headers: await _headers(),
          body: jsonEncode({
            if (displayName != null) 'display_name': displayName,
            if (beltLevel != null) 'belt_level': beltLevel,
          }),
        );
        _check(res, 200);
      });

  Future<String?> uploadAvatar(Uint8List bytes) async {
    final token = await secureStorage.read(_kAccess);
    final uri = Uri.parse('$_base/users/me/avatar');
    final request = http.MultipartRequest('POST', uri);
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(http.MultipartFile.fromBytes(
      'file', bytes,
      filename: 'avatar.jpg',
    ));
    final streamed = await httpClient.send(request);
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as Map<String, dynamic>)['avatar_url']
          as String?;
    }
    return null;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      _withRefresh(() async {
        final res = await httpClient.put(
          Uri.parse('$_base/users/me/password'),
          headers: await _headers(),
          body: jsonEncode({
            'current_password': currentPassword,
            'new_password': newPassword,
          }),
        );
        _check(res, 200);
      });

  // ── Journal ───────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getSessions() => _withRefresh(() async {
        final res = await httpClient.get(
          Uri.parse('$_base/journal/sessions'),
          headers: await _headers(),
        );
        _check(res, 200);
        return (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
      });

  Future<Map<String, dynamic>> addSession(Map<String, dynamic> data) =>
      _withRefresh(() async {
        final res = await httpClient.post(
          Uri.parse('$_base/journal/sessions'),
          headers: await _headers(),
          body: jsonEncode(data),
        );
        _check(res, 201);
        return jsonDecode(res.body) as Map<String, dynamic>;
      });

  Future<Map<String, dynamic>> updateSession(
          int id, Map<String, dynamic> data) =>
      _withRefresh(() async {
        final res = await httpClient.put(
          Uri.parse('$_base/journal/sessions/$id'),
          headers: await _headers(),
          body: jsonEncode(data),
        );
        _check(res, 200);
        return jsonDecode(res.body) as Map<String, dynamic>;
      });

  Future<void> deleteSession(int id) => _withRefresh(() async {
        final res = await httpClient.delete(
          Uri.parse('$_base/journal/sessions/$id'),
          headers: await _headers(),
        );
        _check(res, 204);
      });

  // ── Weakness & Readiness ──────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getWeaknesses() => _withRefresh(() async {
        final res = await httpClient.get(
          Uri.parse('$_base/journal/weaknesses'),
          headers: await _headers(),
        );
        _check(res, 200);
        return (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
      });

  Future<Map<String, dynamic>> getReadiness() => _withRefresh(() async {
        final res = await httpClient.get(
          Uri.parse('$_base/journal/readiness'),
          headers: await _headers(),
        );
        _check(res, 200);
        return jsonDecode(res.body) as Map<String, dynamic>;
      });

  Future<Map<String, dynamic>> updateReadiness(Map<String, dynamic> data) =>
      _withRefresh(() async {
        final res = await httpClient.put(
          Uri.parse('$_base/journal/readiness'),
          headers: await _headers(),
          body: jsonEncode(data),
        );
        _check(res, 200);
        return jsonDecode(res.body) as Map<String, dynamic>;
      });

  // ── Coach ─────────────────────────────────────────────────────────────────

  Future<String> chat(List<Map<String, dynamic>> messages) =>
      _withRefresh(() async {
        final res = await httpClient.post(
          Uri.parse('$_base/coach/chat'),
          headers: await _headers(),
          body: jsonEncode({'messages': messages}),
        );
        _check(res, 200);
        return (jsonDecode(res.body) as Map<String, dynamic>)['reply'] as String;
      });

  // ── Coach — Pose Analysis ─────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getTulList() => _withRefresh(() async {
        final res = await httpClient.get(
          Uri.parse('$_base/coach/tul-list'),
          headers: await _headers(),
        );
        _check(res, 200);
        return (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
      });

  Future<Map<String, dynamic>> analyzePose({
    required Uint8List studentImageBytes,
    required String studentFileName,
    required String tulName,
    required int movementNo,
    String language = 'ko',
  }) =>
      _withRefresh(() async {
        final token = await secureStorage.read(_kAccess);
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('$_base/coach/analyze-pose'),
        );
        if (token != null) request.headers['Authorization'] = 'Bearer $token';

        request.files.add(http.MultipartFile.fromBytes(
          'student_image',
          studentImageBytes,
          filename: studentFileName,
        ));
        request.fields['tul_name']    = tulName;
        request.fields['movement_no'] = movementNo.toString();
        request.fields['language']    = language;

        final streamed = await request.send();
        final res = await http.Response.fromStream(streamed);
        _check(res, 200);
        return jsonDecode(res.body) as Map<String, dynamic>;
      });

  // ── Dojo — Invite codes ───────────────────────────────────────────────────

  Future<Map<String, dynamic>> createInviteCode() => _withRefresh(() async {
        final res = await httpClient.post(
          Uri.parse('$_base/dojo/invite-codes'),
          headers: await _headers(),
        );
        _check(res, 201);
        return jsonDecode(res.body) as Map<String, dynamic>;
      });

  Future<List<Map<String, dynamic>>> listInviteCodes() => _withRefresh(() async {
        final res = await httpClient.get(
          Uri.parse('$_base/dojo/invite-codes'),
          headers: await _headers(),
        );
        _check(res, 200);
        return (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
      });

  Future<void> revokeInviteCode(String code) => _withRefresh(() async {
        final res = await httpClient.delete(
          Uri.parse('$_base/dojo/invite-codes/$code'),
          headers: await _headers(),
        );
        _check(res, 204);
      });

  Future<Map<String, dynamic>> useInviteCode(String code) =>
      _withRefresh(() async {
        final res = await httpClient.post(
          Uri.parse('$_base/dojo/invite-codes/$code/use'),
          headers: await _headers(),
        );
        _check(res, 200);
        return jsonDecode(res.body) as Map<String, dynamic>;
      });

  // ── Dojo — Members ────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> listMembers() => _withRefresh(() async {
        final res = await httpClient.get(
          Uri.parse('$_base/dojo/members'),
          headers: await _headers(),
        );
        _check(res, 200);
        return (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
      });

  Future<Map<String, dynamic>> getMemberDetail(int studentId) =>
      _withRefresh(() async {
        final res = await httpClient.get(
          Uri.parse('$_base/dojo/members/$studentId'),
          headers: await _headers(),
        );
        _check(res, 200);
        return jsonDecode(res.body) as Map<String, dynamic>;
      });

  Future<Map<String, dynamic>> getStudentJournal(int studentId) =>
      _withRefresh(() async {
        final res = await httpClient.get(
          Uri.parse('$_base/dojo/members/$studentId/journal'),
          headers: await _headers(),
        );
        _check(res, 200);
        return jsonDecode(res.body) as Map<String, dynamic>;
      });

  Future<void> removeMember(int studentId) => _withRefresh(() async {
        final res = await httpClient.delete(
          Uri.parse('$_base/dojo/members/$studentId'),
          headers: await _headers(),
        );
        _check(res, 204);
      });

  Future<void> leaveDojo() => _withRefresh(() async {
        final res = await httpClient.delete(
          Uri.parse('$_base/dojo/connection'),
          headers: await _headers(),
        );
        _check(res, 204);
      });

  // ── Dojo — Comments ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>> createComment(int studentId, String content) =>
      _withRefresh(() async {
        final res = await httpClient.post(
          Uri.parse('$_base/dojo/comments'),
          headers: await _headers(),
          body: jsonEncode({'student_id': studentId, 'content': content}),
        );
        _check(res, 201);
        return jsonDecode(res.body) as Map<String, dynamic>;
      });

  Future<List<Map<String, dynamic>>> listComments(int studentId) =>
      _withRefresh(() async {
        final res = await httpClient.get(
          Uri.parse('$_base/dojo/comments/student/$studentId'),
          headers: await _headers(),
        );
        _check(res, 200);
        return (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
      });

  Future<void> deleteComment(int commentId) => _withRefresh(() async {
        final res = await httpClient.delete(
          Uri.parse('$_base/dojo/comments/$commentId'),
          headers: await _headers(),
        );
        _check(res, 204);
      });

  // ── Dojo — Homework ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>> createHomework(
    int studentId,
    String content,
    DateTime dueDate,
  ) =>
      _withRefresh(() async {
        final res = await httpClient.post(
          Uri.parse('$_base/dojo/homework'),
          headers: await _headers(),
          body: jsonEncode({
            'student_id': studentId,
            'content': content,
            'due_date': dueDate.toIso8601String(),
          }),
        );
        _check(res, 201);
        return jsonDecode(res.body) as Map<String, dynamic>;
      });

  Future<Map<String, dynamic>> createGroupHomework(
    String content,
    DateTime dueDate,
  ) =>
      _withRefresh(() async {
        final res = await httpClient.post(
          Uri.parse('$_base/dojo/homework/group'),
          headers: await _headers(),
          body: jsonEncode({
            'student_id': 0,
            'content': content,
            'due_date': dueDate.toIso8601String(),
          }),
        );
        _check(res, 201);
        return jsonDecode(res.body) as Map<String, dynamic>;
      });

  Future<List<Map<String, dynamic>>> getMyHomework() =>
      _withRefresh(() async {
        final res = await httpClient.get(
          Uri.parse('$_base/dojo/homework/mine'),
          headers: await _headers(),
        );
        _check(res, 200);
        return (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
      });

  Future<List<Map<String, dynamic>>> getDojoStats({
    String? startDate,
    String? endDate,
  }) =>
      _withRefresh(() async {
        final params = <String, String>{
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
        };
        final uri = Uri.parse('$_base/dojo/stats').replace(queryParameters: params.isEmpty ? null : params);
        final res = await httpClient.get(uri, headers: await _headers());
        _check(res, 200);
        return (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
      });

  Future<Map<String, dynamic>> getHomeworkStats() => _withRefresh(() async {
        final res = await httpClient.get(
          Uri.parse('$_base/dojo/homework-stats'),
          headers: await _headers(),
        );
        _check(res, 200);
        return jsonDecode(res.body) as Map<String, dynamic>;
      });

  Future<List<Map<String, dynamic>>> listPendingHomework(int studentId) =>
      _withRefresh(() async {
        final res = await httpClient.get(
          Uri.parse('$_base/dojo/homework/pending/$studentId'),
          headers: await _headers(),
        );
        _check(res, 200);
        return (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
      });

  Future<void> completeHomework(int homeworkId) => _withRefresh(() async {
        final res = await httpClient.patch(
          Uri.parse('$_base/dojo/homework/$homeworkId/complete'),
          headers: await _headers(),
        );
        _check(res, 200);
      });

  // ── Pose Analysis Records ─────────────────────────────────────────────────

  Future<Map<String, dynamic>> getPoseRecords({
    String? tulName,
    int? movementNo,
    String? startDate,
    String? endDate,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) =>
      _withRefresh(() async {
        final params = <String, String>{
          'page': '$page',
          'page_size': '$pageSize',
          if (tulName != null) 'tul_name': tulName,
          if (movementNo != null) 'movement_no': '$movementNo',
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
          if (search != null && search.isNotEmpty) 'search': search,
        };
        final uri = Uri.parse('$_base/coach/pose-records')
            .replace(queryParameters: params);
        final res = await httpClient.get(uri, headers: await _headers());
        _check(res, 200);
        return jsonDecode(res.body) as Map<String, dynamic>;
      });

  Future<void> deletePoseRecord(int id) =>
      _withRefresh(() async {
        final res = await httpClient.delete(
          Uri.parse('$_base/coach/pose-records/$id'),
          headers: await _headers(),
        );
        _check(res, 204);
      });

  Future<void> savePoseRecord({
    required String tulName,
    required int movementNo,
    required String movementName,
    required int score,
    required String feedback,
  }) =>
      _withRefresh(() async {
        final res = await httpClient.post(
          Uri.parse('$_base/coach/pose-records'),
          headers: {
            ...await _headers(),
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'tul_name': tulName,
            'movement_no': movementNo,
            'movement_name': movementName,
            'score': score,
            'feedback': feedback,
          }),
        );
        _check(res, 201);
      });

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _check(http.Response res, int expected) {
    if (res.statusCode == expected) return;
    String detail;
    try {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      detail = json['detail']?.toString() ?? res.body;
    } catch (_) {
      detail = res.body;
    }
    if (res.statusCode == 401) throw Exception('unauthorized:$detail');
    if (res.statusCode == 400) throw Exception('bad_request:$detail');
    if (res.statusCode == 409) throw Exception('conflict:$detail');
    throw Exception('server_error:${res.statusCode}:$detail');
  }
}

final backendClientProvider = Provider<BackendClient>((ref) {
  return BackendClient(
    secureStorage: ref.watch(secureStorageProvider),
    httpClient: ref.watch(httpClientProvider),
  );
});
