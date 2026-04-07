
import 'package:flutter/foundation.dart';

enum SceneStatus {
  pending,
  generating,
  ready,
  approved,
  locked,
  failed,
}

extension SceneStatusExtension on SceneStatus {
  String get value {
    switch (this) {
      case SceneStatus.pending:
        return 'pending';
      case SceneStatus.generating:
        return 'generating';
      case SceneStatus.ready:
        return 'ready';
      case SceneStatus.approved:
        return 'approved';
      case SceneStatus.locked:
        return 'locked';
      case SceneStatus.failed:
        return 'failed';
    }
  }

  String get label {
    switch (this) {
      case SceneStatus.pending:
        return 'Pending';
      case SceneStatus.generating:
        return 'Generating';
      case SceneStatus.ready:
        return 'Ready';
      case SceneStatus.approved:
        return 'Approved';
      case SceneStatus.locked:
        return 'Locked';
      case SceneStatus.failed:
        return 'Failed';
    }
  }

  static SceneStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'generating':
        return SceneStatus.generating;
      case 'ready':
        return SceneStatus.ready;
      case 'approved':
        return SceneStatus.approved;
      case 'locked':
        return SceneStatus.locked;
      case 'failed':
        return SceneStatus.failed;
      case 'pending':
      default:
        return SceneStatus.pending;
    }
  }
}

@immutable
class Scene {
  final String id;
  final String projectId;
  final int sceneIndex;
  final String title;
  final String? goal;
  final int durationSec;
  final String narrationText;
  final String imagePrompt;
  final String animationPrompt;
  final String? sfxText;
  final SceneStatus status;
  final bool isLocked;
  final String? imageUrl;

  const Scene({
    required this.id,
    required this.projectId,
    required this.sceneIndex,
    required this.title,
    this.goal,
    required this.durationSec,
    required this.narrationText,
    required this.imagePrompt,
    required this.animationPrompt,
    this.sfxText,
    required this.status,
    required this.isLocked,
    this.imageUrl,
  });

  factory Scene.fromJson(Map<String, dynamic> json) {
    return Scene(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      sceneIndex: json['scene_index'] as int,
      title: json['title'] as String,
      goal: json['goal'] as String?,
      durationSec: json['duration_sec'] as int? ?? 0,
      narrationText: json['narration_text'] as String? ?? '',
      imagePrompt: json['image_prompt'] as String? ?? '',
      animationPrompt: json['animation_prompt'] as String? ?? '',
      sfxText: json['sfx_text'] as String?,
      status: SceneStatusExtension.fromString(
        json['status'] as String? ?? 'pending',
      ),
      isLocked: json['is_locked'] as bool? ?? false,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'scene_index': sceneIndex,
      'title': title,
      if (goal != null) 'goal': goal,
      'duration_sec': durationSec,
      'narration_text': narrationText,
      'image_prompt': imagePrompt,
      'animation_prompt': animationPrompt,
      if (sfxText != null) 'sfx_text': sfxText,
      'status': status.value,
      'is_locked': isLocked,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }

  Scene copyWith({
    String? id,
    String? projectId,
    int? sceneIndex,
    String? title,
    String? goal,
    int? durationSec,
    String? narrationText,
    String? imagePrompt,
    String? animationPrompt,
    String? sfxText,
    SceneStatus? status,
    bool? isLocked,
    String? imageUrl,
  }) {
    return Scene(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      sceneIndex: sceneIndex ?? this.sceneIndex,
      title: title ?? this.title,
      goal: goal ?? this.goal,
      durationSec: durationSec ?? this.durationSec,
      narrationText: narrationText ?? this.narrationText,
      imagePrompt: imagePrompt ?? this.imagePrompt,
      animationPrompt: animationPrompt ?? this.animationPrompt,
      sfxText: sfxText ?? this.sfxText,
      status: status ?? this.status,
      isLocked: isLocked ?? this.isLocked,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Scene &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          status == other.status &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode => id.hashCode ^ status.hashCode ^ imageUrl.hashCode;

  @override
  String toString() =>
      'Scene(id: $id, index: $sceneIndex, title: $title, status: ${status.value})';
}