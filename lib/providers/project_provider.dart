
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:animuse/models/project.dart';
import 'package:animuse/services/api_service.dart';

final projectProvider =
    AsyncNotifierProviderFamily<ProjectNotifier, Project?, String>(
  ProjectNotifier.new,
);

class ProjectNotifier extends FamilyAsyncNotifier<Project?, String> {
  Timer? _pollingTimer;

  @override
  Future<Project?> build(String arg) async {
    ref.onDispose(() {
      _pollingTimer?.cancel();
    });
    return loadProject(arg);
  }

  Future<Project?> loadProject(String id) async {
    if (id.isEmpty) return null;
    try {
      final project = await ApiService.instance.getProject(id);
      _maybeStartPolling(project);
      return project;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateStatus() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    try {
      final project = await ApiService.instance.getProject(currentState.id);
      state = AsyncData(project);
      _maybeStartPolling(project);
    } catch (e) {
      // Keep existing state on error
    }
  }

  void _maybeStartPolling(Project? project) {
    if (project == null) return;

    final shouldPoll = project.status == ProjectStatus.planning ||
        project.status == ProjectStatus.storyboarding;

    if (shouldPoll && _pollingTimer == null) {
      _startPolling();
    } else if (!shouldPoll) {
      _stopPolling();
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await updateStatus();
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }
}