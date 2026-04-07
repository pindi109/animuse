
import 'package:flutter/foundation.dart';

enum JobStatus {
  pending,
  running,
  done,
  failed,
}

extension JobStatusExtension on JobStatus {
  String get value {
    switch (this) {
      case JobStatus.pending:
        return 'pending';
      case JobStatus.running:
        return 'running';
      case JobStatus.done:
        return 'done';
      case JobStatus.failed:
        return 'failed';
    }
  }

  String get label {
    switch (this) {
      case JobStatus.pending:
        return 'Pending';
      case JobStatus.running:
        return 'Running';
      case JobStatus.done:
        return 'Done';
      case JobStatus.failed:
        return 'Failed';
    }
  }

  bool get isTerminal {
    return this == JobStatus.done || this == JobStatus.failed;
  }

  static JobStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'running':
        return JobStatus.running;
      case 'done':
        return JobStatus.done;
      case 'failed':
        return JobStatus.failed;
      case 'pending':
      default:
        return JobStatus.pending;
    }
  }
}

@immutable
class Job {
  final String id;
  final String type;
  final JobStatus status;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final String? errorMessage;

  const Job({
    required this.id,
    required this.type,
    required this.status,
    required this.payload,
    required this.createdAt,
    this.errorMessage,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as String,
      type: json['type'] as String? ?? '',
      status: JobStatusExtension.fromString(
        json['status'] as String? ?? 'pending',
      ),
      payload: json['payload'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
      errorMessage: json['error_message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'status': status.value,
      'payload': payload,
      'created_at': createdAt.toIso8601String(),
      if (errorMessage != null) 'error_message': errorMessage,
    };
  }

  Job copyWith({
    String? id,
    String? type,
    JobStatus? status,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
    String? errorMessage,
  }) {
    return Job(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Job &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          status == other.status;

  @override
  int get hashCode => id.hashCode ^ status.hashCode;

  @override
  String toString() =>
      'Job(id: $id, type: $type, status: ${status.value})';
}