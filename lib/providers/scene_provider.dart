
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:animuse/models/scene.dart';
import 'package:animuse/services/api_service.dart';

final sceneProvider =
    AsyncNotifierProviderFamily<SceneNotifier, List<Scene>, String>(
  SceneNotifier.new,
);

class SceneNotifier extends FamilyAsyncNotifier<List<Scene>, String> {
  @override
  Future<List<Scene>> build(String arg) async {
    if (arg.isEmpty) return [];
    return loadScenes(arg);
  }

  Future<List<Scene>> loadScenes(String projectId) async {
    try {
      final scenes = await ApiService.instance.getScenes(projectId);
      return _sortedScenes(scenes);
    } catch (e) {
      return [];
    }
  }

  Future<void> refresh() async {
    final projectId = arg;
    if (projectId.isEmpty) return;
    try {
      final scenes = await ApiService.instance.getScenes(projectId);
      state = AsyncData(_sortedScenes(scenes));
    } catch (e) {
      // Keep existing state on error
    }
  }

  Future<void> approveScene(String sceneId) async {
    try {
      final updated = await ApiService.instance.approveScene(sceneId);
      _replaceScene(updated);
    } catch (e) {
      // Handle error silently; UI should show failed state
    }
  }

  Future<void> lockScene(String sceneId) async {
    try {
      final updated = await ApiService.instance.lockScene(sceneId);
      _replaceScene(updated);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> regenerateImage(String sceneId) async {
    try {
      final updated = await ApiService.instance.regenerateSceneImage(sceneId);
      _replaceScene(updated);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> regenerateText(String sceneId) async {
    try {
      final updated = await ApiService.instance.regenerateSceneText(sceneId);
      _replaceScene(updated);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> updateScene(String sceneId, Map<String, dynamic> patch) async {
    try {
      final updated = await ApiService.instance.patchScene(sceneId, patch);
      _replaceScene(updated);
    } catch (e) {
      // Handle error silently
    }
  }

  void _replaceScene(Scene updated) {
    final current = state.valueOrNull ?? [];
    final newList = current.map((s) {
      return s.id == updated.id ? updated : s;
    }).toList();
    state = AsyncData(_sortedScenes(newList));
  }

  List<Scene> _sortedScenes(List<Scene> scenes) {
    final copy = List<Scene>.from(scenes);
    copy.sort((a, b) => a.sceneIndex.compareTo(b.sceneIndex));
    return copy;
  }
}