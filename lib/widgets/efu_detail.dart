import 'package:flutter/material.dart';

class EfuDetailPage extends StatelessWidget {
  // efu.dartからの全体情報
  final Map<String, dynamic> processingConditions;
  // タップされたブロックの情報
  final Map<String, dynamic> blockInfo;
  // 表示を元に戻すためのコールバック
  final VoidCallback onBack;

  const EfuDetailPage({
    super.key,
    required this.processingConditions,
    required this.blockInfo,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '■ 加工条件詳細',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('戻る'),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            const Text('全体情報:', style: TextStyle(fontWeight: FontWeight.bold)),
            // processingConditionsの情報を表示
            ...processingConditions.entries.map((entry) => Text('${entry.key}: ${entry.value}')),
            const Divider(height: 20, thickness: 1),
            const Text('ブロック詳細:', style: TextStyle(fontWeight: FontWeight.bold)),
            // blockInfoの情報を表示
            ...blockInfo.entries.map((entry) => Text('${entry.key}: ${entry.value}')),
          ],
        ),
      ),
    );
  }
}
