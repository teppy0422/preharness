import 'package:flutter/material.dart';
import 'package:preharness/features/import_export/data/shield_service.dart';
import 'package:preharness/features/import_export/qr_print_preview.dart';

class QrPrintShieldModal extends StatefulWidget {
  const QrPrintShieldModal({super.key});

  @override
  State<QrPrintShieldModal> createState() => _QrPrintShieldModalState();
}

class _QrPrintShieldModalState extends State<QrPrintShieldModal> {
  List<ShieldGroup> _groups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() {
      _isLoading = true;
    });

    final groups = await ShieldService.getShieldGroups();

    setState(() {
      _groups = groups;
      _isLoading = false;
    });
  }

  void _onGroupTapped(ShieldGroup group) async {
    // QRデータを取得
    final qrDataList = await ShieldService.getShieldQrData(
      group.pNumber,
      group.engChange,
    );

    if (!mounted) return;

    // QR印刷プレビュー画面を表示
    showDialog(
      context: context,
      builder: (context) => QrPrintPreview(
        pNumber: group.pNumber,
        engChange: group.engChange,
        qrDataList: qrDataList,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Shield QRコード印刷',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),

            // コンテンツエリア
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _groups.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.inbox,
                                size: 100,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'データがありません',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _groups.length,
                          itemBuilder: (context, index) {
                            final group = _groups[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.qr_code_2,
                                  color: Colors.blue,
                                ),
                                title: Text(
                                  group.pNumber,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text('ENG Change: ${group.engChange}'),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () => _onGroupTapped(group),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
