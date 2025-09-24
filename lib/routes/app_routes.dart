import 'package:flutter/widgets.dart';
import 'package:preharness/features/home/home_page.dart';
import 'package:preharness/features/settings/settings_page.dart';
import 'package:preharness/features/import_export/import_page.dart';
import 'package:preharness/features/work40/work40.dart';
import 'package:preharness/features/temp/temp_page.dart';
import 'package:preharness/features/rhythm_game/rhythm_game_page.dart';
import 'package:preharness/features/debug/debug_page.dart';
import 'package:preharness/features/debug/api_test_page.dart';
import 'package:preharness/features/shared_prefs/shared_prefs_viewer_page.dart';

class AppRoutes {
  static const home = '/home';
  static const settings = '/settings';
  static const import = '/import';
  static const work40 = '/work40';
  static const temp = '/temp';
  static const rhythmGame = '/rhythm_game'; // 新しいルート
  static const debug = '/debug';
  static const apiTest = '/api_test'; // Add new route for API Test Page
  static const sharedPrefsViewer = '/shared_prefs_viewer';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomePage(),
    settings: (context) => const SettingsPage(),
    import: (context) => const ImportPage(),
    work40: (context) => const Work40Page(),
    temp: (context) => const TempPage(),
    rhythmGame: (context) => const RhythmGamePage(), // 新しいマッピング
    debug: (context) => const DebugPage(),
    apiTest: (context) => const ApiTestPage(), // Add mapping for API Test Page
    sharedPrefsViewer: (context) => const SharedPrefsViewerPage(),
  };
}
