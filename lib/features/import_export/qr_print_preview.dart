import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:preharness/features/import_export/data/shield_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class QrPrintPreview extends StatefulWidget {
  final String pNumber;
  final String engChange;
  final List<ShieldQrData> qrDataList;

  const QrPrintPreview({
    super.key,
    required this.pNumber,
    required this.engChange,
    required this.qrDataList,
  });

  @override
  State<QrPrintPreview> createState() => _QrPrintPreviewState();
}

class _QrPrintPreviewState extends State<QrPrintPreview> {
  // 各QRコードの数量を管理（index -> 数量）
  final Map<int, int> _quantities = {};

  // 合計数量を計算
  int _getTotalQuantity() {
    int total = 0;
    for (int i = 0; i < widget.qrDataList.length; i++) {
      total += _quantities[i] ?? 1;
    }
    return total;
  }

  // 数量入力ダイアログを表示
  Future<void> _showQuantityDialog(int index) async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) =>
          _QuantityInputDialog(currentQuantity: _quantities[index] ?? 1),
    );

    if (result != null) {
      setState(() {
        _quantities[index] = result;
      });
    }
  }

  // 全てのQRコードに一括で数量を設定
  Future<void> _showBulkQuantityDialog() async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => const _QuantityInputDialog(currentQuantity: 1),
    );

    if (result != null) {
      setState(() {
        for (int i = 0; i < widget.qrDataList.length; i++) {
          _quantities[i] = result;
        }
      });
    }
  }

  Future<void> _handlePrint(BuildContext context) async {
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => _generatePdf(format),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('印刷エラー: $e')));
      }
    }
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    // 数量を考慮してQRコードリストを展開
    final List<ShieldQrData> expandedList = [];
    for (int i = 0; i < widget.qrDataList.length; i++) {
      final quantity = _quantities[i] ?? 1;
      for (int j = 0; j < quantity; j++) {
        expandedList.add(widget.qrDataList[i]);
      }
    }

    // 1ページに6列×N行でQRコードを配置
    const itemsPerPage = 24; // 6列 × 4行
    final pageCount = (expandedList.length / itemsPerPage).ceil();

    for (int pageIndex = 0; pageIndex < pageCount; pageIndex++) {
      final startIndex = pageIndex * itemsPerPage;
      final endIndex = (startIndex + itemsPerPage > expandedList.length)
          ? expandedList.length
          : startIndex + itemsPerPage;
      final pageItems = expandedList.sublist(startIndex, endIndex);

      pdf.addPage(
        pw.Page(
          pageFormat: format,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // ヘッダー
                pw.Container(
                  padding: const pw.EdgeInsets.only(bottom: 20),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Shield QRコード',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '${widget.pNumber} ${widget.engChange}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                pw.Divider(),
                pw.SizedBox(height: 20),

                // QRコードグリッド
                pw.Expanded(
                  child: pw.GridView(
                    crossAxisCount: 6,
                    childAspectRatio: 1,
                    children: pageItems.map((qrData) {
                      return pw.Container(
                        padding: const pw.EdgeInsets.all(2),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          border: pw.Border.all(color: PdfColors.grey300),
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            // YBMバッジ
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.blue,
                                borderRadius: pw.BorderRadius.circular(12),
                              ),
                              child: pw.Text(
                                qrData.ybm,
                                style: pw.TextStyle(
                                  color: PdfColors.white,
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 2),
                            // QRコード
                            pw.Expanded(
                              child: pw.BarcodeWidget(
                                barcode: pw.Barcode.qrCode(),
                                data: qrData.toQrString(),
                              ),
                            ),
                            pw.SizedBox(height: 2),
                            // QRコード内容
                            pw.Text(
                              qrData.toQrString(),
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // ページ番号
                pw.Container(
                  padding: const pw.EdgeInsets.only(top: 10),
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'Page ${pageIndex + 1} of $pageCount',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 900,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'QRコード印刷プレビュー',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'P/N: ${widget.pNumber} | ENG: ${widget.engChange}',
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _handlePrint(context),
                      icon: const Icon(Icons.print),
                      label: const Text('印刷'),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),

            // QRコード数の表示と一括設定ボタン
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '合計 ${_getTotalQuantity()} 個のQRコードを印刷します (${widget.qrDataList.length} 種類)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _showBulkQuantityDialog,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('数量を一括設定'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // QRコード一覧
            Expanded(
              child: widget.qrDataList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.qr_code,
                            size: 150,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'QRコードデータがありません',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            crossAxisSpacing: 1,
                            mainAxisSpacing: 1,
                            childAspectRatio: 0.8,
                          ),
                      itemCount: widget.qrDataList.length,
                      itemBuilder: (context, index) {
                        final qrData = widget.qrDataList[index];
                        return _QrCodeCard(
                          qrData: qrData,
                          index: index + 1,
                          quantity: _quantities[index] ?? 1,
                          onQuantityTap: () => _showQuantityDialog(index),
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

class _QrCodeCard extends StatelessWidget {
  final ShieldQrData qrData;
  final int index;
  final int quantity;
  final VoidCallback onQuantityTap;

  const _QrCodeCard({
    required this.qrData,
    required this.index,
    required this.quantity,
    required this.onQuantityTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // YBM表示と数量
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    qrData.ybm,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onQuantityTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$quantity本',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // QRコード
            Expanded(
              child: QrImageView(
                data: qrData.toQrString(),
                version: QrVersions.auto,
                gapless: false,
              ),
            ),
            const SizedBox(height: 1),

            // QRコード内容
            Text(
              qrData.toQrString(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// 数量入力ダイアログ
class _QuantityInputDialog extends StatefulWidget {
  final int currentQuantity;

  const _QuantityInputDialog({required this.currentQuantity});

  @override
  State<_QuantityInputDialog> createState() => _QuantityInputDialogState();
}

class _QuantityInputDialogState extends State<_QuantityInputDialog> {
  late String _inputValue;
  final List<int> _presets = [1, 10, 50, 100, 200, 300, 400, 500];

  @override
  void initState() {
    super.initState();
    _inputValue = widget.currentQuantity.toString();
  }

  void _onNumberTap(String number) {
    setState(() {
      if (_inputValue == '0') {
        _inputValue = number;
      } else {
        _inputValue += number;
      }
    });
  }

  void _onClear() {
    setState(() {
      _inputValue = '0';
    });
  }

  void _onBackspace() {
    setState(() {
      if (_inputValue.length > 1) {
        _inputValue = _inputValue.substring(0, _inputValue.length - 1);
      } else {
        _inputValue = '0';
      }
    });
  }

  void _onConfirm() {
    final quantity = int.tryParse(_inputValue);
    if (quantity != null && quantity > 0) {
      Navigator.of(context).pop(quantity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // タイトル
            const Text(
              'QRコードの数量を設定',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),

            // 現在の入力値表示
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _inputValue,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // プリセットとテンキーを横並びに配置
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左側: プリセット
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('プリセット', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 4),
                    ..._presets.map((preset) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 0),
                        child: SizedBox(
                          width: 80,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _inputValue = preset.toString();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 0),
                            ),
                            child: Text(
                              preset.toString(),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(width: 16),

                // 右側: テンキー
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('テンキー', style: TextStyle(fontSize: 14)),
                      const SizedBox(height: 4),
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 2,
                        children: [
                          ...[1, 2, 3, 4, 5, 6, 7, 8, 9].map((number) {
                            return ElevatedButton(
                              onPressed: () => _onNumberTap(number.toString()),
                              child: Text(
                                number.toString(),
                                style: const TextStyle(fontSize: 20),
                              ),
                            );
                          }),
                          ElevatedButton(
                            onPressed: _onClear,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text(
                              'C',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _onNumberTap('0'),
                            child: const Text(
                              '0',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _onBackspace,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                            child: const Icon(Icons.backspace),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 確定・キャンセルボタン
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('キャンセル'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('確定'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
