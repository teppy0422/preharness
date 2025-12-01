import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:preharness/features/import_export/data/shield_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class QrPrintPreview extends StatelessWidget {
  final String pNumber;
  final String engChange;
  final List<ShieldQrData> qrDataList;

  const QrPrintPreview({
    super.key,
    required this.pNumber,
    required this.engChange,
    required this.qrDataList,
  });

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

    // 1ページに6列×N行でQRコードを配置
    const itemsPerPage = 24; // 6列 × 4行
    final pageCount = (qrDataList.length / itemsPerPage).ceil();

    for (int pageIndex = 0; pageIndex < pageCount; pageIndex++) {
      final startIndex = pageIndex * itemsPerPage;
      final endIndex = (startIndex + itemsPerPage > qrDataList.length)
          ? qrDataList.length
          : startIndex + itemsPerPage;
      final pageItems = qrDataList.sublist(startIndex, endIndex);

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
                        '$pNumber $engChange',
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
                      'P/N: $pNumber | ENG: $engChange',
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

            // QRコード数の表示
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    '合計 ${qrDataList.length} 個のQRコードを印刷します',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // QRコード一覧
            Expanded(
              child: qrDataList.isEmpty
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
                      itemCount: qrDataList.length,
                      itemBuilder: (context, index) {
                        final qrData = qrDataList[index];
                        return _QrCodeCard(qrData: qrData, index: index + 1);
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
  const _QrCodeCard({required this.qrData, required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // YBM表示
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
