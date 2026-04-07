
import 'package:animuse/models/project.dart';
import 'package:animuse/services/api_service.dart';

class ProjectService {
  ProjectService({ApiService? apiService})
      : _api = apiService ?? ApiService();

  final ApiService _api;

  /// Creates a new project with the given parameters.
  Future<Project> createProject({
    required String topic,
    required String title,
    String? tone,
    String? audience,
    String? visualStyle,
    String? voicePreset,
    String? videoObjective,
    int targetDurationSec = 900,
  }) async {
    final body = <String, dynamic>{
      'topic': topic,
      'title': title,
      'target_duration_sec': targetDurationSec,
      if (tone != null) 'tone': tone,
      if (audience != null) 'audience': audience,
      if (visualStyle != null) 'visual_style': visualStyle,
      if (voicePreset != null) 'voice_preset': voicePreset,
      if (videoObjective != null) 'video_objective': videoObjective,
    };
    return _api.createProject(body);
  }

  /// Fetches a project by ID.
  Future<Project> getProject(String projectId) async {
    return _api.getProject(projectId);
  }

  /// Starts the generation pipeline for a project.
  Future<Project> generateProject(String projectId) async {
    return _api.generateProject(projectId);
  }

  /// Triggers a full regeneration of an existing project.
  Future<Project> regenerateProject(String projectId) async {
    return _api.regenerateProject(projectId);
  }
}