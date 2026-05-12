import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/backend_client.dart';
import '../domain/entities/weakness_pattern.dart';

final weaknessPatternsProvider =
    FutureProvider<List<WeaknessPattern>>((ref) async {
  final client = ref.watch(backendClientProvider);
  final data = await client.getWeaknesses();
  return data.map(WeaknessPattern.fromJson).toList();
});
