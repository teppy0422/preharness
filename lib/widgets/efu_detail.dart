import 'package:flutter/material.dart';
import 'package:preharness/widgets/dial_selector_with_db.dart';
import 'package:preharness/widgets/measurement.dart';

class EfuDetailPage extends StatelessWidget {
  final Map<String, dynamic> processingConditions;
  final Map<String, dynamic> blockInfo;
  final VoidCallback onBack;
  final List<Map<String, dynamic>>? chListData;
  final bool isLoadingChList;
  final String? chListError;

  const EfuDetailPage({
    super.key,
    required this.processingConditions,
    required this.blockInfo,
    required this.onBack,
    this.chListData,
    this.isLoadingChList = false,
    this.chListError,
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
            const Divider(height: 20, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '■ 加工条件詳細',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('戻る'),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 20, thickness: 1),
                      Text('製品品番: ${processingConditions['p_number']}'),
                      Text('設変: ${processingConditions['eng_change']}'),
                      Text('構成No: ${processingConditions['cfg_no']}'),
                      Text('数量: ${processingConditions['wire_cnt']}'),
                      const Divider(height: 20, thickness: 1),

                      const Text(
                        'ブロック詳細:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('端子部品番号: ${blockInfo['terminals'][0]}'),
                      Text('付加部品: ${blockInfo['terminals'][1]}'),
                      const Divider(height: 20, thickness: 1),

                      DialSelectorWithDb(
                        processingConditions: processingConditions,
                        blockInfo: blockInfo,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    Text(
                      '${blockInfo['terminals'][0]}${processingConditions['wire_type']}/${processingConditions['wire_size']}',
                    ),
                    Measurement(chListData: chListData),
                  ],
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            const Text(
              'CH List Data:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (isLoadingChList)
              const CircularProgressIndicator()
            else if (chListError != null)
              Text('Error: $chListError')
            else if (chListData != null && chListData!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: chListData!
                    .map(
                      (item) => Text(item.toString()),
                    ) // Adjust display as needed
                    .toList(),
              )
            else
              const Text('No CH list data found.'),
          ],
        ),
      ),
    );
  }
}

void showCustomDialog(BuildContext context, Widget child) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    builder: (context) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: GestureDetector(onTap: () {}, child: child),
        ),
      );
    },
  );
}
