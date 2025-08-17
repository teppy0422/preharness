// lib/widgets/responsive_scaffold.dart
import 'package:flutter/material.dart';
import 'package:preharness/main.dart'; // themeNotifier 参照用
import 'package:flutter/services.dart';
import "package:preharness/widgets/user_icon_button.dart";
import "package:preharness/widgets/nas_status_icon.dart";

class ResponsiveScaffold extends StatefulWidget {
  final String title;
  final String currentPage;
  final Widget child;

  const ResponsiveScaffold({
    super.key,
    required this.title,
    required this.currentPage,
    required this.child,
  });

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  bool isSidebarCollapsed = false;

  void _navigate(String page) {
    Navigator.pushReplacementNamed(context, '/$page');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              // Sidebar幅は折りたたみ時に狭く、それ以外は広い
              SizedBox(
                width: isSidebarCollapsed ? 0 : 55, // 200は例
                child: isSidebarCollapsed
                    ? null
                    : Sidebar(
                        selectedPage: widget.currentPage,
                        onItemSelected: (page) {
                          _navigate(page);
                        },
                      ),
              ),
              VerticalDivider(
                width: isSidebarCollapsed ? 0 : 1,
                color: isSidebarCollapsed ? Colors.transparent : Colors.grey,
              ),
              Expanded(child: widget.child),
            ],
          ),

          // 折りたたみ時に画面左上に表示するメニューアイコン
          if (isSidebarCollapsed)
            Positioned(
              top: 18,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.menu),
                tooltip: 'メニューを開く',
                onPressed: () {
                  setState(() {
                    isSidebarCollapsed = false;
                    updateSystemUI(false);
                  });
                },
              ),
            ),

          // 折りたたみ時以外はSidebar内に閉じるボタンを表示するなども可能
          if (!isSidebarCollapsed)
            Positioned(
              top: 18,
              left: 2,
              child: IconButton(
                icon: const Icon(Icons.chevron_left),
                tooltip: 'メニューを閉じる',
                onPressed: () {
                  setState(() {
                    isSidebarCollapsed = true;
                    updateSystemUI(true);
                  });
                },
              ),
            ),
          Positioned(
            top: 16,
            right: 8, // ← UserIconButton より左へ
            child: Row(
              children: const [
                // Nasステータス
                NasStatusIcon(),
                SizedBox(width: 12),
                // ユーザーログインアイコン
                UserIconButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void updateSystemUI(bool isCollapsed) {
    if (isCollapsed) {
      // ステータスバーとナビゲーションバーを非表示に
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    } else {
      // 両方表示に戻す
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    }
  }
}

class Sidebar extends StatefulWidget {
  final void Function(String) onItemSelected;
  final String selectedPage;

  const Sidebar({
    super.key,
    required this.onItemSelected,
    required this.selectedPage,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool isCollapsed = false;

  int _getSelectedIndex() {
    final page = widget.selectedPage.replaceFirst('/', '');
    switch (page) {
      case 'home':
        return 0;
      case 'work40':
        return 1;
      case 'temp':
        return 2;
      case 'import':
        return 3;
      case 'settings':
        return 4;
      case 'debug':
        return 5;
      default:
        return 0;
    }
  }

  String _getPageKeyByIndex(int index) {
    switch (index) {
      case 0:
        return 'home';
      case 1:
        return 'work40';
      case 2:
        return 'temp';
      case 3:
        return 'import';
      case 4:
        return 'settings';
      case 5:
        return 'debug';
      default:
        return 'home';
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getSelectedIndex();

    final destinations = [
      const NavigationRailDestination(
        padding: EdgeInsets.symmetric(vertical: 4),
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: Text(
          'ホーム',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
        ),
      ),
      const NavigationRailDestination(
        padding: EdgeInsets.symmetric(vertical: 4),
        icon: Icon(Icons.build_outlined),
        selectedIcon: Icon(Icons.build),
        label: Text(
          '圧着',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
        ),
      ),
      const NavigationRailDestination(
        padding: EdgeInsets.symmetric(vertical: 4),
        icon: Icon(Icons.file_upload_outlined),
        selectedIcon: Icon(Icons.file_upload),
        label: Text(
          '出荷',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
        ),
      ),
      const NavigationRailDestination(
        padding: EdgeInsets.symmetric(vertical: 4),
        icon: Icon(Icons.cloud_outlined),
        selectedIcon: Icon(Icons.cloud),
        label: Text(
          'サーバー',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
        ),
      ),
      const NavigationRailDestination(
        padding: EdgeInsets.symmetric(vertical: 8),
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: Text(
          '設定',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
        ),
      ),
    ];

    // if (kDebugMode) {
    destinations.add(
      const NavigationRailDestination(
        padding: EdgeInsets.symmetric(vertical: 8),
        icon: Icon(Icons.bug_report_outlined),
        selectedIcon: Icon(Icons.bug_report),
        label: Text(
          'デバッグ',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
        ),
      ),
    );
    // }

    if (isCollapsed) {
      return Container(
        color: Colors.transparent,
        child: Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'メニューを開く',
            onPressed: () {
              setState(() {
                isCollapsed = false;
              });
            },
          ),
        ),
      );
    }

    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        final key = _getPageKeyByIndex(index);
        widget.onItemSelected(key);
      },
      labelType: NavigationRailLabelType.selected,
      groupAlignment: -1.0,
      leading: Column(
        children: const [
          SizedBox(height: 20),
          Text(
            'Menu',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      destinations: destinations,
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (context, mode, _) {
                final platformDark =
                    MediaQuery.of(context).platformBrightness ==
                    Brightness.dark;
                final isDark =
                    mode == ThemeMode.dark ||
                    (mode == ThemeMode.system && platformDark);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.rotate(
                      angle: -1.57079632679, // -90 degrees in radians
                      child: Transform.scale(
                        scale: 0.9,
                        child: Switch(
                          value: isDark,
                          onChanged: (val) {
                            themeNotifier.value = val
                                ? ThemeMode.dark
                                : ThemeMode.light;
                          },
                          thumbIcon: WidgetStateProperty.resolveWith<Icon?>((
                            states,
                          ) {
                            if (states.contains(WidgetState.selected)) {
                              // Dark mode (selected)
                              return const Icon(Icons.dark_mode);
                            }
                            // Light mode (unselected)
                            return const Icon(Icons.light_mode);
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isDark ? 'ダーク' : 'ライト',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
