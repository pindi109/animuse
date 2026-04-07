
import 'package:animuse/models/scene.dart';
import 'package:animuse/services/api_service.dart';

class SceneService {
  SceneService({ApiService? apiService})
      : _api = apiService ?? ApiService();

  final ApiService _api;

  /// Fetches all scenes for a project, sorted by sceneIndex ascending.
  Future<List<Scene>> getScenes(String projectId) async {
    return _api.getScenes(projectId);
  }

  /// Patches a scene with the given fields.
  Future<Scene> updateScene(
    String sceneId,
    Map<String, dynamic> patch,
  ) async {
    return _api.updateScene(sceneId, patch);
  }

  /// Convenience method to update narration text only.
  Future<Scene> updateNarration(String sceneId, String narrationText) async {
    return _api.updateScene(sceneId, {'narration_text': narrationText});
  }

  /// Convenience method to update image prompt only.
  Future<Scene> updateImagePrompt(String sceneId, String imagePrompt) async {
    return _api.updateScene(sceneId, {'image_prompt': imagePrompt});
  }

  /// Convenience method to update animation prompt only.
  Future<Scene> updateAnimationPrompt(
    String sceneId,
    String animationPrompt,
  ) async {
    return _api.updateScene(sceneId, {'animation_prompt': animationPrompt});
  }

  /// Triggers regeneration of the scene image.
  Future<Scene> regenerateImage(String sceneId) async {
    return _api.regenerateSceneImage(sceneId);
  }

  /// Triggers regeneration of the scene text content.
  Future<Scene> regenerateText(String sceneId) async {
    return _api.regenerateSceneText(sceneId);
  }

  /// Approves a scene, marking it ready for export.
  Future<Scene> approveScene(String sceneId) async {
    return _api.approveScene(sceneId);
  }

  /// Locks a scene, preventing further edits.
  Future<Scene> lockScene(String sceneId) async {
    return _api.lockScene(sceneId);
  }
}