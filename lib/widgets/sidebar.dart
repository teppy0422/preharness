import 'package:flutter/material.dart';

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
      default:
        return 'home';
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getSelectedIndex();

    // 折りたたみ表示（横幅ゼロで他のレイアウトに影響させない）
    if (isCollapsed) {
      return Container(
        width: 60, // ← 最小限の横幅を確保
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

    // 展開表示
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        final key = _getPageKeyByIndex(index);
        widget.onItemSelected(key);
      },
      labelType: NavigationRailLabelType.selected,
      groupAlignment: -1.0, // ← 上寄せ
      leading: Column(
        children: [
          const SizedBox(height: 8),
          const Text(
            'メニュー',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'メニューを閉じる',
            onPressed: () {
              setState(() {
                isCollapsed = true;
              });
            },
          ),
        ],
      ),
      destinations: const [
        NavigationRailDestination(
          padding: EdgeInsets.symmetric(vertical: 4),
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('ホーム'),
        ),
        NavigationRailDestination(
          padding: EdgeInsets.symmetric(vertical: 4),
          icon: Icon(Icons.build_outlined),
          selectedIcon: Icon(Icons.build),
          label: Text('圧着'),
        ),
        NavigationRailDestination(
          padding: EdgeInsets.symmetric(vertical: 4),
          icon: Icon(Icons.file_upload_outlined),
          selectedIcon: Icon(Icons.file_upload),
          label: Text('出荷'),
        ),
        NavigationRailDestination(
          padding: EdgeInsets.symmetric(vertical: 4),
          icon: Icon(Icons.upload_file_outlined),
          selectedIcon: Icon(Icons.upload_file),
          label: Text('インポート'),
        ),
        NavigationRailDestination(
          padding: EdgeInsets.symmetric(vertical: 4),
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: Text('設定'),
        ),
      ],
    );
  }
}
