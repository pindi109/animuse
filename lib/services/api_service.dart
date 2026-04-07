
import 'package:dio/dio.dart';
import 'package:animuse/core/constants/app_constants.dart';
import 'package:animuse/models/project.dart';
import 'package:animuse/models/scene.dart';
import 'package:animuse/models/export_model.dart';

class ApiService {
  ApiService._internal();
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio = _buildDio();

  Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => _log(obj.toString()),
      ),
    );

    return dio;
  }

  void _log(String message) {
    // ignore: avoid_print
    print('[ApiService] $message');
  }

  // ─── Projects ──────────────────────────────────────────────────────────────

  /// POST /api/projects
  Future<Project> createProject(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/projects',
        data: body,
      );
      return Project.fromJson(response.data!);
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/projects'),
        error: e,
        message: 'Unexpected error creating project: $e',
      );
    }
  }

  /// GET /api/projects/:id
  Future<Project> getProject(String projectId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/projects/$projectId',
      );
      return Project.fromJson(response.data!);
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/projects/$projectId'),
        error: e,
        message: 'Unexpected error fetching project: $e',
      );
    }
  }

  /// POST /api/projects/:id/generate
  Future<Project> generateProject(String projectId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/projects/$projectId/generate',
      );
      return Project.fromJson(response.data!);
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions:
            RequestOptions(path: '/api/projects/$projectId/generate'),
        error: e,
        message: 'Unexpected error starting generation: $e',
      );
    }
  }

  /// POST /api/projects/:id/regenerate
  Future<Project> regenerateProject(String projectId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/projects/$projectId/regenerate',
      );
      return Project.fromJson(response.data!);
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions:
            RequestOptions(path: '/api/projects/$projectId/regenerate'),
        error: e,
        message: 'Unexpected error regenerating project: $e',
      );
    }
  }

  // ─── Scenes ────────────────────────────────────────────────────────────────

  /// GET /api/projects/:id/scenes  (inferred — list scenes for project)
  Future<List<Scene>> getScenes(String projectId) async {
    try {
      final response = await _dio.get<dynamic>(
        '/api/projects/$projectId/scenes',
      );
      final data = response.data;
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data.containsKey('scenes')) {
        list = data['scenes'] as List<dynamic>;
      } else {
        list = [];
      }
      final scenes = list
          .map((s) => Scene.fromJson(s as Map<String, dynamic>))
          .toList();
      // Always sort by sceneIndex ascending — never rely on server return order
      scenes.sort((a, b) => a.sceneIndex.compareTo(b.sceneIndex));
      return scenes;
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions:
            RequestOptions(path: '/api/projects/$projectId/scenes'),
        error: e,
        message: 'Unexpected error fetching scenes: $e',
      );
    }
  }

  /// PATCH /api/scenes/:id
  Future<Scene> updateScene(
    String sceneId,
    Map<String, dynamic> patch,
  ) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/api/scenes/$sceneId',
        data: patch,
      );
      return Scene.fromJson(response.data!);
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/scenes/$sceneId'),
        error: e,
        message: 'Unexpected error updating scene: $e',
      );
    }
  }

  /// POST /api/scenes/:id/regenerate-image
  Future<Scene> regenerateSceneImage(String sceneId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/scenes/$sceneId/regenerate-image',
      );
      return Scene.fromJson(response.data!);
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions:
            RequestOptions(path: '/api/scenes/$sceneId/regenerate-image'),
        error: e,
        message: 'Unexpected error regenerating scene image: $e',
      );
    }
  }

  /// POST /api/scenes/:id/regenerate-text
  Future<Scene> regenerateSceneText(String sceneId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/scenes/$sceneId/regenerate-text',
      );
      return Scene.fromJson(response.data!);
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions:
            RequestOptions(path: '/api/scenes/$sceneId/regenerate-text'),
        error: e,
        message: 'Unexpected error regenerating scene text: $e',
      );
    }
  }

  /// POST /api/scenes/:id/approve
  Future<Scene> approveScene(String sceneId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/scenes/$sceneId/approve',
      );
      return Scene.fromJson(response.data!);
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions:
            RequestOptions(path: '/api/scenes/$sceneId/approve'),
        error: e,
        message: 'Unexpected error approving scene: $e',
      );
    }
  }

  /// POST /api/scenes/:id/lock  (inferred from spec locked status)
  Future<Scene> lockScene(String sceneId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/scenes/$sceneId/lock',
      );
      return Scene.fromJson(response.data!);
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions:
            RequestOptions(path: '/api/scenes/$sceneId/lock'),
        error: e,
        message: 'Unexpected error locking scene: $e',
      );
    }
  }

  // ─── Exports ───────────────────────────────────────────────────────────────

  /// POST /api/projects/:id/export
  Future<ExportModel> createExport(String projectId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/projects/$projectId/export',
      );
      return ExportModel.fromJson(response.data!);
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions:
            RequestOptions(path: '/api/projects/$projectId/export'),
        error: e,
        message: 'Unexpected error creating export: $e',
      );
    }
  }

  /// GET /api/exports/:id
  Future<ExportModel> getExport(String exportId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/exports/$exportId',
      );
      return ExportModel.fromJson(response.data!);
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/exports/$exportId'),
        error: e,
        message: 'Unexpected error fetching export: $e',
      );
    }
  }
}