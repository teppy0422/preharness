import 'package:flutter/widgets.dart';
import 'package:preharness/pages/home_page.dart';
import 'package:preharness/pages/settings_page.dart';
import 'package:preharness/pages/import_page.dart';
import 'package:preharness/pages/work40_page.dart';
import 'package:preharness/pages/temp_page.dart';

class AppRoutes {
  static const home = '/home';
  static const settings = '/settings';
  static const import = '/import';
  static const work40 = '/work40';
  static const temp = '/temp';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomePage(),
    settings: (context) => const SettingsPage(),
    import: (context) => const ImportPage(),
    work40: (context) => const Work40Page(),
    temp: (context) => const TempPage(),
  };
}
