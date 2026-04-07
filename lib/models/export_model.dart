
import 'package:flutter/foundation.dart';
import 'package:animuse/models/scene.dart';

enum ExportStatus {
  pending,
  processing,
  ready,
  failed,
}

extension ExportStatusExtension on ExportStatus {
  String get value {
    switch (this) {
      case ExportStatus.pending:
        return 'pending';
      case ExportStatus.processing:
        return 'processing';
      case ExportStatus.ready:
        return 'ready';
      case ExportStatus.failed:
        return 'failed';
    }
  }

  String get label {
    switch (this) {
      case ExportStatus.pending:
        return 'Pending';
      case ExportStatus.processing:
        return 'Processing';
      case ExportStatus.ready:
        return 'Ready';
      case ExportStatus.failed:
        return 'Failed';
    }
  }

  static ExportStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'processing':
        return ExportStatus.processing;
      case 'ready':
        return ExportStatus.ready;
      case 'failed':
        return ExportStatus.failed;
      case 'pending':
      default:
        return ExportStatus.pending;
    }
  }
}

@immutable
class ExportSceneEntry {
  final String sceneId;
  final int sceneIndex;
  final String title;
  final ExportStatus animationStatus;
  final ExportStatus narrationStatus;
  final String? animationUrl;
  final String? narrationUrl;

  const ExportSceneEntry({
    required this.sceneId,
    required this.sceneIndex,
    required this.title,
    required this.animationStatus,
    required this.narrationStatus,
    this.animationUrl,
    this.narrationUrl,
  });

  factory ExportSceneEntry.fromJson(Map<String, dynamic> json) {
    return ExportSceneEntry(
      sceneId: json['scene_id'] as String,
      sceneIndex: json['scene_index'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      animationStatus: ExportStatusExtension.fromString(
        json['animation_status'] as String? ?? 'pending',
      ),
      narrationStatus: ExportStatusExtension.fromString(
        json['narration_status'] as String? ?? 'pending',
      ),
      animationUrl: json['animation_url'] as String?,
      narrationUrl: json['narration_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scene_id': sceneId,
      'scene_index': sceneIndex,
      'title': title,
      'animation_status': animationStatus.value,
      'narration_status': narrationStatus.value,
      if (animationUrl != null) 'animation_url': animationUrl,
      if (narrationUrl != null) 'narration_url': narrationUrl,
    };
  }

  ExportSceneEntry copyWith({
    String? sceneId,
    int? sceneIndex,
    String? title,
    ExportStatus? animationStatus,
    ExportStatus? narrationStatus,
    String? animationUrl,
    String? narrationUrl,
  }) {
    return ExportSceneEntry(
      sceneId: sceneId ?? this.sceneId,
      sceneIndex: sceneIndex ?? this.sceneIndex,
      title: title ?? this.title,
      animationStatus: animationStatus ?? this.animationStatus,
      narrationStatus: narrationStatus ?? this.narrationStatus,
      animationUrl: animationUrl ?? this.animationUrl,
      narrationUrl: narrationUrl ?? this.narrationUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExportSceneEntry &&
          runtimeType == other.runtimeType &&
          sceneId == other.sceneId &&
          animationStatus == other.animationStatus &&
          narrationStatus == other.narrationStatus;

  @override
  int get hashCode =>
      sceneId.hashCode ^
      animationStatus.hashCode ^
      narrationStatus.hashCode;
}

@immutable
class ExportModel {
  final String id;
  final String projectId;
  final ExportStatus status;
  final int version;
  final DateTime createdAt;
  final List<ExportSceneEntry> scenes;
  final String? downloadUrl;

  const ExportModel({
    required this.id,
    required this.projectId,
    required this.status,
    required this.version,
    required this.createdAt,
    required this.scenes,
    this.downloadUrl,
  });

  factory ExportModel.fromJson(Map<String, dynamic> json) {
    final rawScenes = json['scenes'] as List<dynamic>? ?? [];
    final scenes = rawScenes
        .map((s) => ExportSceneEntry.fromJson(s as Map<String, dynamic>))
        .toList();

    // Sort scenes by sceneIndex ascending — never rely on server return order
    scenes.sort((a, b) => a.sceneIndex.compareTo(b.sceneIndex));

    return ExportModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      status: ExportStatusExtension.fromString(
        json['status'] as String? ?? 'pending',
      ),
      version: json['version'] as int? ?? 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      scenes: scenes,
      downloadUrl: json['download_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'status': status.value,
      'version': version,
      'created_at': createdAt.toIso8601String(),
      'scenes': scenes.map((s) => s.toJson()).toList(),
      if (downloadUrl != null) 'download_url': downloadUrl,
    };
  }

  ExportModel copyWith({
    String? id,
    String? projectId,
    ExportStatus? status,
    int? version,
    DateTime? createdAt,
    List<ExportSceneEntry>? scenes,
    String? downloadUrl,
  }) {
    return ExportModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      status: status ?? this.status,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      scenes: scenes ?? this.scenes,
      downloadUrl: downloadUrl ?? this.downloadUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExportModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          status == other.status;

  @override
  int get hashCode => id.hashCode ^ status.hashCode;

  @override
  String toString() =>
      'ExportModel(id: $id, projectId: $projectId, status: ${status.value}, version: $version)';
}