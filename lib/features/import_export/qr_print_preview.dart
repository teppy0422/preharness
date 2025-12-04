import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:preharness/core/constants/app_colors.dart';
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

  // 数量入力ダイアログを表示
  Future<void> _showQuantityDialog(int index) async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) =>
          _QuantityInputDialog(currentQuantity: _quantities[index] ?? 100),
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
      builder: (context) => const _QuantityInputDialog(currentQuantity: 100),
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
    await showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.getCardColor(context),
            foregroundColor: AppColors.getLineColor(context),
            title: const Text('印刷プレビュー'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: '閉じる',
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.print),
                onPressed: () async {
                  try {
                    await Printing.layoutPdf(
                      onLayout: (PdfPageFormat format) async =>
                          _generatePdf(format),
                    );
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('印刷エラー: $e')));
                    }
                  }
                },
                tooltip: '印刷',
              ),
            ],
          ),
          body: PdfPreview(
            build: (format) => _generatePdf(format),
            allowSharing: false,
            allowPrinting: false,
            canChangePageFormat: false,
            canChangeOrientation: false,
            canDebug: false,
          ),
        ),
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    // 日本語フォントをassetsから読み込み
    final fontData = await rootBundle.load(
      'assets/fonts/NotoSansJP-Regular.ttf',
    );
    final font = pw.Font.ttf(fontData);

    final fontBoldData = await rootBundle.load(
      'assets/fonts/NotoSansJP-Bold.ttf',
    );
    final fontBold = pw.Font.ttf(fontBoldData);

    // PDFドキュメントに日本語フォントをデフォルトテーマとして設定
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(base: font, bold: fontBold),
    );

    // QRコードデータを準備
    final List<Map<String, dynamic>> itemsToPrint = [];
    for (int i = 0; i < widget.qrDataList.length; i++) {
      final quantity = _quantities[i] ?? 100;
      final qrData = widget.qrDataList[i];
      final qrDataString = '${qrData.toQrString()}-$quantity';
      itemsToPrint.add({
        'data': qrData,
        'quantity': quantity,
        'qrText': qrDataString,
      });
    }

    // 1ページに6列×N行でQRコードを配置
    const itemsPerPage = 24; // 6列 × 4行
    final pageCount = (itemsToPrint.length / itemsPerPage).ceil();

    for (int pageIndex = 0; pageIndex < pageCount; pageIndex++) {
      final startIndex = pageIndex * itemsPerPage;
      final endIndex = (startIndex + itemsPerPage > itemsToPrint.length)
          ? itemsToPrint.length
          : startIndex + itemsPerPage;
      final pageItems = itemsToPrint.sublist(startIndex, endIndex);

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
                          font: fontBold,
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '${widget.pNumber} ${widget.engChange}',
                        style: pw.TextStyle(font: font, fontSize: 12),
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
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.8,
                    children: pageItems.map((item) {
                      final qrData = item['data'] as ShieldQrData;
                      final quantity = item['quantity'] as int;
                      final qrDataString = item['qrText'] as String;

                      return pw.Container(
                        padding: const pw.EdgeInsets.all(2),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                            color: PdfColors.black,
                            width: 1,
                          ),
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Column(
                          mainAxisSize: pw.MainAxisSize.min,
                          children: [
                            // YBMと数量
                            pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(
                                  qrData.ybm,
                                  style: pw.TextStyle(
                                    font: fontBold,
                                    fontSize: 8,
                                  ),
                                ),
                                pw.Text(
                                  '$quantity本',
                                  style: pw.TextStyle(
                                    font: fontBold,
                                    fontSize: 8,
                                  ),
                                ),
                              ],
                            ),
                            // QRコード
                            pw.Expanded(
                              child: pw.Center(
                                child: pw.BarcodeWidget(
                                  barcode: pw.Barcode.qrCode(),
                                  data: qrDataString,
                                  width: 60,
                                  height: 60,
                                  drawText: false,
                                ),
                              ),
                            ),
                            // QRテキスト
                            pw.Text(
                              qrDataString,
                              style: pw.TextStyle(font: fontBold, fontSize: 6),
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
                    style: pw.TextStyle(font: font, fontSize: 10),
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
    final buttonColor = AppColors.getHighLightColor(context);
    final cardColor = AppColors.getCardColor(context);
    final errorColor = AppColors.getErrorColor(context);
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
                      '${widget.pNumber}  ${widget.engChange}',
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: cardColor, // Custom foreground
                      ),
                    ),
                    const SizedBox(width: 18),
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                // color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: errorColor),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${widget.qrDataList.length} 種類のQRコードを印刷します',
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
                      backgroundColor: AppColors.getHighLightColor(context),
                      foregroundColor: AppColors.getCardColor(context),
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
                          quantity: _quantities[index] ?? 100,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(
          color: isDark ? AppColors.paperWhite : AppColors.black,
          width: 1,
        ),
      ),

      child: Padding(
        padding: const EdgeInsets.only(top: 4, right: 2, bottom: 4, left: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // YBM表示と数量
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 2,
                    ),
                    child: Text(
                      qrData.ybm,
                      style: const TextStyle(
                        color: AppColors.paperWhite,
                        fontSize: 14,
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
                        color: AppColors.getHighLightColor(context),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$quantity本',
                        style: TextStyle(
                          color: AppColors.getCardColor(context),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 1),

            // QRコード
            Expanded(
              child: QrImageView(
                data: '${qrData.toQrString()}-$quantity',
                version: QrVersions.auto,
                gapless: false,
                foregroundColor: AppColors.getLineColor(
                  context,
                ), // Conditional color
                backgroundColor: Colors.transparent, // Ensure transparency
              ),
            ),
            const SizedBox(height: 1),
            // QRコード内容
            Text(
              '${qrData.toQrString()}-$quantity',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.getLineColor(context),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBackgroundColor = isDark ? AppColors.paperBlack : Colors.white;
    final textColor = isDark ? AppColors.paperWhite : AppColors.paperBlack;

    return Dialog(
      backgroundColor: dialogBackgroundColor,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // タイトル
            Text(
              'QRコードの数量を設定',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),

            // 現在の入力値表示
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.getHighLightColor(context),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _inputValue,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'プリセット',
                      style: TextStyle(fontSize: 14, color: textColor),
                    ),
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
                              elevation: 1,
                              backgroundColor: AppColors.getCardColor(context),
                              foregroundColor: AppColors.getLineColor(context),
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            child: Text(
                              preset.toString(),
                              style: const TextStyle(fontSize: 16),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'テンキー',
                        style: TextStyle(fontSize: 14, color: textColor),
                      ),
                      const SizedBox(height: 4),
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio:
                            1.4, // Changed from 2 to 1 for square buttons
                        children: [
                          ...[1, 2, 3, 4, 5, 6, 7, 8, 9].map((number) {
                            return ElevatedButton(
                              onPressed: () => _onNumberTap(number.toString()),
                              style: ElevatedButton.styleFrom(
                                fixedSize: const Size.square(
                                  80,
                                ), // Adjust size here
                                shape: const CircleBorder(), // Make it circular
                                backgroundColor: Colors
                                    .transparent, // Remove background color
                                side: BorderSide(
                                  color: textColor,
                                  width: 1.5,
                                ), // Add border
                                elevation: 0, // Remove shadow
                                shadowColor: Colors
                                    .transparent, // Ensure no shadow color
                              ),
                              child: Text(
                                number.toString(),
                                style: TextStyle(
                                  fontSize: 24,
                                  color: textColor,
                                ),
                              ),
                            );
                          }),
                          ElevatedButton(
                            onPressed: _onClear,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              foregroundColor:
                                  Colors.red, // Set icon color here
                              fixedSize: const Size.square(
                                80,
                              ), // Adjust size here
                              shape: const CircleBorder(), // Make it circular
                              side: BorderSide(color: Colors.red, width: 2),
                            ),
                            child: const Text(
                              'C',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _onNumberTap('0'),
                            style: ElevatedButton.styleFrom(
                              fixedSize: const Size.square(
                                80,
                              ), // Adjust size here
                              shape: const CircleBorder(), // Make it circular
                              backgroundColor:
                                  Colors.transparent, // Remove background color
                              side: BorderSide(
                                color: textColor,
                                width: 1.5,
                              ), // Add border
                              elevation: 0, // Remove shadow
                              shadowColor:
                                  Colors.transparent, // Ensure no shadow color
                            ),
                            child: Text(
                              '0',
                              style: TextStyle(fontSize: 20, color: textColor),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _onBackspace,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              foregroundColor:
                                  Colors.orange, // Set icon color here
                              fixedSize: const Size.square(
                                80,
                              ), // Adjust size here
                              shape: const CircleBorder(), // Make it circular
                              side: BorderSide(
                                color: Colors.orange,
                                width: 2,
                              ), // Add border with orange color
                            ),
                            child: const Icon(Icons.backspace, size: 28),
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
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.getHighLightColor(
                      context,
                    ), // Example conditional color
                  ),
                  child: const Text('キャンセル'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.getHighLightColor(context),
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
