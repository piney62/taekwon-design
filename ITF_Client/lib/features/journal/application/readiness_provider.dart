import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/backend_client.dart';
import '../domain/entities/readiness_data.dart';

class ReadinessNotifier extends AsyncNotifier<ReadinessData> {
  @override
  Future<ReadinessData> build() async {
    final client = ref.watch(backendClientProvider);
    final json = await client.getReadiness();
    return ReadinessData.fromJson(json);
  }

  Future<void> save(ReadinessData data) async {
    final client = ref.read(backendClientProvider);
    state = const AsyncLoading();
    final json = await client.updateReadiness(data.toJson());
    state = AsyncData(ReadinessData.fromJson(json));
  }
}

final readinessProvider =
    AsyncNotifierProvider<ReadinessNotifier, ReadinessData>(
  ReadinessNotifier.new,
);
