
import 'package:flutter/foundation.dart';

enum SceneAssetType {
  image,
  audio,
  animation,
}

extension SceneAssetTypeExtension on SceneAssetType {
  String get value {
    switch (this) {
      case SceneAssetType.image:
        return 'image';
      case SceneAssetType.audio:
        return 'audio';
      case SceneAssetType.animation:
        return 'animation';
    }
  }

  static SceneAssetType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'audio':
        return SceneAssetType.audio;
      case 'animation':
        return SceneAssetType.animation;
      case 'image':
      default:
        return SceneAssetType.image;
    }
  }
}

enum SceneAssetStatus {
  pending,
  generating,
  ready,
  failed,
}

extension SceneAssetStatusExtension on SceneAssetStatus {
  String get value {
    switch (this) {
      case SceneAssetStatus.pending:
        return 'pending';
      case SceneAssetStatus.generating:
        return 'generating';
      case SceneAssetStatus.ready:
        return 'ready';
      case SceneAssetStatus.failed:
        return 'failed';
    }
  }

  static SceneAssetStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'generating':
        return SceneAssetStatus.generating;
      case 'ready':
        return SceneAssetStatus.ready;
      case 'failed':
        return SceneAssetStatus.failed;
      case 'pending':
      default:
        return SceneAssetStatus.pending;
    }
  }
}

@immutable
class SceneAsset {
  final String id;
  final String sceneId;
  final SceneAssetType type;
  final String url;
  final SceneAssetStatus status;

  const SceneAsset({
    required this.id,
    required this.sceneId,
    required this.type,
    required this.url,
    required this.status,
  });

  factory SceneAsset.fromJson(Map<String, dynamic> json) {
    return SceneAsset(
      id: json['id'] as String,
      sceneId: json['scene_id'] as String,
      type: SceneAssetTypeExtension.fromString(
        json['type'] as String? ?? 'image',
      ),
      url: json['url'] as String? ?? '',
      status: SceneAssetStatusExtension.fromString(
        json['status'] as String? ?? 'pending',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scene_id': sceneId,
      'type': type.value,
      'url': url,
      'status': status.value,
    };
  }

  SceneAsset copyWith({
    String? id,
    String? sceneId,
    SceneAssetType? type,
    String? url,
    SceneAssetStatus? status,
  }) {
    return SceneAsset(
      id: id ?? this.id,
      sceneId: sceneId ?? this.sceneId,
      type: type ?? this.type,
      url: url ?? this.url,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SceneAsset &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          status == other.status;

  @override
  int get hashCode => id.hashCode ^ status.hashCode;

  @override
  String toString() =>
      'SceneAsset(id: $id, sceneId: $sceneId, type: ${type.value}, status: ${status.value})';
}