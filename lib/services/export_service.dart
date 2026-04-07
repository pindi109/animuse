
import 'package:animuse/models/export_model.dart';
import 'package:animuse/services/api_service.dart';

class ExportService {
  ExportService({ApiService? apiService})
      : _api = apiService ?? ApiService();

  final ApiService _api;

  /// Initiates an export for the given project.
  Future<ExportModel> createExport(String projectId) async {
    return _api.createExport(projectId);
  }

  /// Fetches the current state of an export by ID.
  Future<ExportModel> getExport(String exportId) async {
    return _api.getExport(exportId);
  }

  /// Returns true if the export is in a terminal state (ready or failed).
  bool isExportComplete(ExportModel export) {
    return export.status == ExportStatus.ready ||
        export.status == ExportStatus.failed;
  }

  /// Returns true if the export package is available for download.
  bool isDownloadAvailable(ExportModel export) {
    return export.status == ExportStatus.ready &&
        export.downloadUrl != null &&
        export.downloadUrl!.isNotEmpty;
  }
}