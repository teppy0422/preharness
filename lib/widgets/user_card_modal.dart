import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr/qr.dart';
import 'package:http/http.dart' as http;

class UserLoginCardModal extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserLoginCardModal({super.key, required this.user});

  // QRコードをUint8List画像として生成
  Future<Uint8List> _generateQrImage(String data) async {
    final qrValidationResult = QrValidator.validate(
      data: data,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.H,
    );
    final qrCode = qrValidationResult.qrCode!;

    final painter = QrPainter.withQr(
      qr: qrCode,
      gapless: true,
      color: const Color(0xFF000000),
      emptyColor: const Color(0xFFFFFFFF),
    );

    final picData = await painter.toImageData(200);
    return picData!.buffer.asUint8List();
  }

  // URLから画像取得
  Future<Uint8List?> _fetchImageBytes(String url) async {
    try {
      debugPrint('画像取得開始: $url');
      final response = await http.get(Uri.parse(url));
      debugPrint('画像取得ステータス: ${response.statusCode}');
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        debugPrint('画像取得失敗: ステータスコード ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("画像取得失敗: $e");
    }
    return null;
  }

  // 印刷処理
  Future<void> _printCard() async {
    final doc = pw.Document();
    final qrId = user['id'].toString();
    final username = user['username'];
    final iconPath = user['iconPath']?.toString();
    final hasIcon = iconPath != null && iconPath.isNotEmpty;

    final fontData = await rootBundle.load(
      'assets/fonts/NotoSansJP-Regular.ttf',
    );
    final ttf = pw.Font.ttf(fontData);

    final qrBytes = await _generateQrImage(qrId);
    pw.ImageProvider? profileImage;

    if (hasIcon) {
      final imageBytes = await _fetchImageBytes(iconPath);
      if (imageBytes != null) {
        profileImage = pw.MemoryImage(imageBytes);
      }
    }

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.applyMargin(
          left: 10,
          top: 10,
          right: 10,
          bottom: 10,
        ),
        build: (context) {
          return pw.Center(
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text(
                  'ログインカード',
                  style: pw.TextStyle(fontSize: 18, font: ttf),
                ),
                pw.SizedBox(height: 8),
                pw.Text('ID: $qrId', style: pw.TextStyle(font: ttf)),
                pw.Text('名前: $username', style: pw.TextStyle(font: ttf)),
                pw.SizedBox(height: 10),
                pw.Container(
                  decoration: pw.BoxDecoration(border: pw.Border.all()),
                  child: pw.Image(
                    pw.MemoryImage(qrBytes),
                    width: 80,
                    height: 80,
                  ),
                ),
                if (profileImage != null) ...[
                  pw.Container(
                    width: 80,
                    height: 80,
                    child: pw.Image(profileImage),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async {
        return doc.save();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // backgroundColor: Colors.white, // ダークモードでも白
      title: const Text("ログインカード"),
      content: SizedBox(
        width: 300,
        height: 250,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("ID: ${user['id']}"),
            Text("名前: ${user['username']}"),
            const SizedBox(height: 10),
            QrImageView(
              data: user['id'].toString(),
              version: QrVersions.auto,
              size: 100,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 10),
            if (user['iconPath'] != null)
              Image.network(
                'http://${user["nasIp"]}:3000/uploads/${user["iconPath"].toString().split(RegExp(r"[\\/]")).last}',
                width: 40,
                height: 40,
                errorBuilder: (c, e, s) {
                  return const Icon(Icons.error, size: 40);
                },
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _printCard, child: const Text("印刷")),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("閉じる"),
        ),
      ],
    );
  }
}
