
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:animuse/models/project.dart';
import 'package:animuse/providers/project_provider.dart';
import 'package:animuse/providers/scene_provider.dart';

/// Manages a polling timer for a given projectId.
/// Call [startPolling] after kicking off generation.
/// The timer automatically cancels when project reaches 'review' or 'failed'.
final pollingProvider =
    NotifierProviderFamily<PollingNotifier, PollingState, String>(
  PollingNotifier.new,
);

class PollingState {
  final bool isPolling;

  const PollingState({this.isPolling = false});

  PollingState copyWith({bool? isPolling}) {
    return PollingState(isPolling: isPolling ?? this.isPolling);
  }
}

class PollingNotifier extends FamilyNotifier<PollingState, String> {
  Timer? _timer;

  @override
  PollingState build(String arg) {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return const PollingState();
  }

  void startPolling() {
    if (_timer != null) return;
    state = state.copyWith(isPolling: true);
    _timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await _tick();
    });
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(isPolling: false);
  }

  Future<void> _tick() async {
    final projectId = arg;

    // Refresh scene list
    try {
      await ref.read(sceneProvider(projectId).notifier).refresh();
    } catch (_) {}

    // Refresh project and check status
    try {
      await ref.read(projectProvider(projectId).notifier).updateStatus();
      final project = ref.read(projectProvider(projectId)).valueOrNull;
      if (project != null) {
        final terminal = project.status == ProjectStatus.review ||
            project.status == ProjectStatus.failed ||
            project.status == ProjectStatus.completed;
        if (terminal) {
          stopPolling();
        }
      }
    } catch (_) {}
  }
}