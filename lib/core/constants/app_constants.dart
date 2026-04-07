
class AppConstants {
  AppConstants._();

  // API
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  // Polling
  static const Duration pollingInterval = Duration(seconds: 3);

  // Layout
  static const double leftPanelFlex = 0.60;
  static const double rightPanelFlex = 0.40;
  static const int storyboardCrossAxisCount = 3;

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Border radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;

  // Card
  static const double cardPadding = 24.0;
  static const double cardBorderWidth = 1.0;

  // Scene card
  static const double sceneCardAspectRatio = 16.0 / 9.0;
  static const double sceneCardMinHeight = 160.0;

  // Inspector panel
  static const double inspectorMinWidth = 320.0;
  static const double inspectorMaxWidth = 480.0;

  // Top bar
  static const double topBarHeight = 64.0;

  // Storyboard grid spacing
  static const double gridMainAxisSpacing = 16.0;
  static const double gridCrossAxisSpacing = 16.0;
  static const double gridPadding = 24.0;

  // Timeout durations
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Routes
  static const String routeLanding = '/';
  static const String routeCreate = '/create';
  static const String routeWorkspace = '/workspace/:projectId';
  static const String routeWorkspaceBase = '/workspace';
  static const String routeExport = '/export/:exportId';
  static const String routeExportBase = '/export';

  // API endpoints
  static const String endpointProjects = '/api/projects';
  static const String endpointScenes = '/api/scenes';
  static const String endpointExports = '/api/exports';

  // Tone presets
  static const List<String> tonePresets = [
    'Cinematic',
    'Documentary',
    'Educational',
    'Explainer',
    'Dramatic',
  ];

  // Voice presets
  static const List<String> voicePresets = [
    'Neutral',
    'Warm',
    'Authoritative',
    'Friendly',
  ];

  // Target duration
  static const int targetDurationSec = 900; // 15 minutes
}