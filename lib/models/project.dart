
import 'package:flutter/foundation.dart';

enum ProjectStatus {
  draft,
  planning,
  storyboarding,
  review,
  exporting,
  completed,
  failed,
}

extension ProjectStatusExtension on ProjectStatus {
  String get value {
    switch (this) {
      case ProjectStatus.draft:
        return 'draft';
      case ProjectStatus.planning:
        return 'planning';
      case ProjectStatus.storyboarding:
        return 'storyboarding';
      case ProjectStatus.review:
        return 'review';
      case ProjectStatus.exporting:
        return 'exporting';
      case ProjectStatus.completed:
        return 'completed';
      case ProjectStatus.failed:
        return 'failed';
    }
  }

  String get label {
    switch (this) {
      case ProjectStatus.draft:
        return 'Draft';
      case ProjectStatus.planning:
        return 'Planning';
      case ProjectStatus.storyboarding:
        return 'Storyboarding';
      case ProjectStatus.review:
        return 'Review';
      case ProjectStatus.exporting:
        return 'Exporting';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.failed:
        return 'Failed';
    }
  }

  bool get isActive {
    return this == ProjectStatus.planning ||
        this == ProjectStatus.storyboarding;
  }

  static ProjectStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'planning':
        return ProjectStatus.planning;
      case 'storyboarding':
        return ProjectStatus.storyboarding;
      case 'review':
        return ProjectStatus.review;
      case 'exporting':
        return ProjectStatus.exporting;
      case 'completed':
        return ProjectStatus.completed;
      case 'failed':
        return ProjectStatus.failed;
      case 'draft':
      default:
        return ProjectStatus.draft;
    }
  }
}

@immutable
class Project {
  final String id;
  final String title;
  final String topic;
  final ProjectStatus status;
  final int targetDurationSec;
  final String? tone;
  final String? audience;
  final String? visualStyle;
  final String? voicePreset;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Project({
    required this.id,
    required this.title,
    required this.topic,
    required this.status,
    required this.targetDurationSec,
    this.tone,
    this.audience,
    this.visualStyle,
    this.voicePreset,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      title: json['title'] as String,
      topic: json['topic'] as String,
      status: ProjectStatusExtension.fromString(
        json['status'] as String? ?? 'draft',
      ),
      targetDurationSec: json['target_duration_sec'] as int? ?? 900,
      tone: json['tone'] as String?,
      audience: json['audience'] as String?,
      visualStyle: json['visual_style'] as String?,
      voicePreset: json['voice_preset'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'topic': topic,
      'status': status.value,
      'target_duration_sec': targetDurationSec,
      if (tone != null) 'tone': tone,
      if (audience != null) 'audience': audience,
      if (visualStyle != null) 'visual_style': visualStyle,
      if (voicePreset != null) 'voice_preset': voicePreset,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Project copyWith({
    String? id,
    String? title,
    String? topic,
    ProjectStatus? status,
    int? targetDurationSec,
    String? tone,
    String? audience,
    String? visualStyle,
    String? voicePreset,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      topic: topic ?? this.topic,
      status: status ?? this.status,
      targetDurationSec: targetDurationSec ?? this.targetDurationSec,
      tone: tone ?? this.tone,
      audience: audience ?? this.audience,
      visualStyle: visualStyle ?? this.visualStyle,
      voicePreset: voicePreset ?? this.voicePreset,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Project &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          status == other.status &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => id.hashCode ^ status.hashCode ^ updatedAt.hashCode;

  @override
  String toString() =>
      'Project(id: $id, title: $title, status: ${status.value})';
}