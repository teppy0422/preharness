import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'package:preharness/core/core.dart'; // コア機能をインポート
// Added for Hive
import 'package:hive_flutter/hive_flutter.dart'; // Added for Hive

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

Future<void> main() async {
  // Made main() async
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is initialized
  await Hive.initFlutter(); // Initialize Hive
  Hive.registerAdapter(ColorAdapter()); // Register ColorAdapter
  Hive.registerAdapter(ColorEntryAdapter()); // Register ColorEntryAdapter

  runApp(
    ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return MyApp(themeMode: currentMode);
      },
    ),
  );
}

class MyApp extends StatefulWidget {
  final ThemeMode themeMode;
  const MyApp({super.key, required this.themeMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<String, dynamic>? loggedInUser;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final user = await UserLoginManager.getLoggedInUser();
    if (user != null) {
      setState(() {
        loggedInUser = user;
      });
      debugPrint("ログイン復元：${user['username']}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PreHarnessPro',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: widget.themeMode,
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
    );
  }
}
