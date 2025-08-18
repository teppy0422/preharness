import 'package:flutter/material.dart';
import 'package:preharness/widgets/dial_selector_with_db.dart';

class EfuDetailPage extends StatelessWidget {
  final Map<String, dynamic> processingConditions;
  final Map<String, dynamic> blockInfo;
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
            DialSelectorWithDb(
              processingConditions: processingConditions,
              blockInfo: blockInfo,
            ),
            const Divider(height: 20, thickness: 1),
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
            Text('電線タイプ: ${processingConditions['wire_type']}'),
            Text('電線サイズ: ${processingConditions['wire_size']}'),
            Text('数量: ${processingConditions['wire_cnt']}'),
            const Divider(height: 20, thickness: 1),
            const Text(
              'ブロック詳細:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('端子部品番号: ${blockInfo['terminals'][0]}'),
            Text('付加部品: ${blockInfo['terminals'][2]}'),
          ],
        ),
      ),
    );
  }
}
