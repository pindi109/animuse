
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:animuse/models/export_model.dart';
import 'package:animuse/services/api_service.dart';

final exportProvider =
    AsyncNotifierProviderFamily<ExportNotifier, ExportModel?, String>(
  ExportNotifier.new,
);

class ExportNotifier extends FamilyAsyncNotifier<ExportModel?, String> {
  @override
  Future<ExportModel?> build(String arg) async {
    if (arg.isEmpty) return null;
    return loadExport(arg);
  }

  Future<ExportModel?> loadExport(String exportId) async {
    if (exportId.isEmpty) return null;
    try {
      final export = await ApiService.instance.getExport(exportId);
      return export;
    } catch (e) {
      return null;
    }
  }

  Future<ExportModel?> startExport(String projectId) async {
    state = const AsyncLoading();
    try {
      final export = await ApiService.instance.startExport(projectId);
      state = AsyncData(export);
      return export;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<void> refresh() async {
    final current = state.valueOrNull;
    if (current == null) return;
    try {
      final export = await ApiService.instance.getExport(current.id);
      state = AsyncData(export);
    } catch (e) {
      // Keep existing state on error
    }
  }
}