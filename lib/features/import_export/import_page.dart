// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:preharness/features/work40/data/api_service.dart';
import 'package:preharness/shared/widgets/responsive_scaffold.dart';
import 'package:preharness/routes/app_routes.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import "package:preharness/widgets/user_list_modal.dart";
import 'package:preharness/features/import_export/qr_print_shield_modal.dart';
import 'dart:async';

double? freeSpaceGB;

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  String? mainPath;
  String? path01;
  double? freeSpaceGB;
  double? totalSpaceGB;
  bool _isFetchingSpace = false;
  bool _isImporting = false;
  int _elapsedSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadPaths();
    await _fetchFreeSpace();
  }

  Future<void> _loadPaths() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      mainPath = prefs.getString('main_path') ?? '未設定';
      path01 = prefs.getString('path_01') ?? '未設定';
    });
  }

  Future<void> _fetchFreeSpace() async {
    setState(() {
      _isFetchingSpace = true;
    });

    if (mainPath == null || mainPath == '未設定') {
      setState(() {
        freeSpaceGB = null;
        totalSpaceGB = null;
        _isFetchingSpace = false;
      });
      return;
    }

    final regex = RegExp(r'\\\\([\d\.]+)');
    final match = regex.firstMatch(mainPath!);

    if (match == null) {
      setState(() {
        freeSpaceGB = null;
        totalSpaceGB = null;
        _isFetchingSpace = false;
      });
      return;
    }

    final ip = match.group(1);

    try {
      final response = await http.get(
        Uri.parse('http://$ip:3000/api/free-space'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          freeSpaceGB = _parseToDouble(data['freeGB']);
          totalSpaceGB = _parseToDouble(data['totalGB']);
        });
      } else {
        setState(() {
          freeSpaceGB = null;
          totalSpaceGB = null;
        });
      }
    } catch (e) {
      setState(() {
        freeSpaceGB = null;
        totalSpaceGB = null;
      });
    } finally {
      setState(() {
        _isFetchingSpace = false;
      });
    }
  }

  String _messageFromCode(int code) {
    switch (code) {
      case 0:
        return 'インポート成功しました';
      case 1:
        return '保存パスが設定されていません';
      case 2:
        return 'サーバーエラーが発生しました';
      case 3:
        return '通信エラーが発生しました';
      case 4:
        return 'インポートするファイルがありませんでした';
      default:
        return '不明なエラーが発生しました';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'import',
      currentPage: AppRoutes.import,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Main Path: ${mainPath ?? '読み込み中...'}'),
            Text(
              'NAS 容量: ${_isFetchingSpace ? '取得中...' : _formatSpace(freeSpaceGB, totalSpaceGB)}',
            ),
            if (freeSpaceGB != null && totalSpaceGB != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 20,
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final ratio = freeSpaceGB! / totalSpaceGB!;
                            return Container(
                              height: 20,
                              width: constraints.maxWidth * ratio,
                              decoration: BoxDecoration(
                                color: ratio > 0.2 ? Colors.blue : Colors.red,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(freeSpaceGB! / totalSpaceGB! * 100).toStringAsFixed(1)}% 空き',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Text('Path01: ${path01 ?? '読み込み中...'}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isImporting
                  ? null
                  : () async {
                      setState(() {
                        _isImporting = true;
                        _elapsedSeconds = 0;
                      });
                      _timer = Timer.periodic(const Duration(seconds: 1), (
                        timer,
                      ) {
                        setState(() {
                          _elapsedSeconds++;
                        });
                      });
                      try {
                        final code = await ApiService.sendPath01ToServer();
                        final message = _messageFromCode(code);

                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(message)));
                        }
                      } finally {
                        _timer?.cancel();
                        setState(() {
                          _isImporting = false;
                          _elapsedSeconds = 0;
                        });
                      }
                    },
              child: _isImporting
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        Text(
                          '$_elapsedSeconds s',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    )
                  : const Text('ファイルインポート実行'),
            ),

            Text("生産指示データ"),
            Text("kanban_*.txt or Rlg29*.txt→m_processing_confitions"),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("RLTF???Aファイルのインポート処理フロー"),
                    content: const SingleChildScrollView(
                      child: SizedBox(
                        width: 500,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ProcessStep(
                              number: "1",
                              title: "ファイル読み込み",
                              content:
                                  "対象: RLTF???A*.txt (7文字目がA)\n例: RLTF17AS_bunseki.txt",
                            ),
                            _ProcessStep(
                              number: "2",
                              title: "データ抽出 (processRltfFile関数)",
                              content:
                                  "固定長フォーマットから19フィールドを抽出:\n"
                                  "・p_number (1-15)\n"
                                  "・eng_change (19-21)\n"
                                  "・cfg_no (27-30)\n"
                                  "・wire_type (32-35)\n"
                                  "・wire_size (36-38)\n"
                                  "・wire_color (39-40)\n"
                                  "・circuit_1 (96-99)\n"
                                  "・circuit_2 (102-105)\n"
                                  "・cfg_no_sub (107-111)\n"
                                  "・ybm (117-123)\n"
                                  "・term_proc_inst_1 = \"Z\" (固定値)\n"
                                  "・term_proc_inst_2 = \"Z\" (固定値)\n"
                                  "・mark_color_1 (168-170)\n"
                                  "・mark_color_2 (172-174)\n"
                                  "・term_part_no_1 (175-184)\n"
                                  "・term_part_no_2 (275-284)\n"
                                  "・add_parts_1 (194-204)\n"
                                  "・add_parts_2 (294-304)\n"
                                  "・wire_len (条件付き)\n"
                                  "  - ybmあり → 148-152列目\n"
                                  "  - ybmなし → 64-68列目",
                            ),
                            _ProcessStep(
                              number: "3",
                              title: "ybm設定処理",
                              subtitle: "setYbmBasedOnCfgNoSub関数",
                              content:
                                  "【条件】ybmが空でない かつ cfg_no_sub ≠ \"0000\"\n\n"
                                  "例:\n"
                                  "行A: p_number=\"82122V1020\", eng_change=\"C01\",\n"
                                  "     cfg_no=\"0003\", cfg_no_sub=\"0005\", ybm=\"MU5\"\n\n"
                                  "↓ 一致する行を検索\n\n"
                                  "行B: p_number=\"82122V1010\" (同じ) ✓\n"
                                  "     eng_change=\"C01\" (同じ) ✓\n"
                                  "     cfg_no=\"0005\" (=cfg_no_sub) ✓\n\n"
                                  "→ 行Bのybmに \"MU5\" を設定",
                            ),
                            _ProcessStep(
                              number: "4",
                              title: "電線長共有処理",
                              subtitle: "shareWireLenWithinYbmGroup関数",
                              content:
                                  "【同じグループの定義】\n"
                                  "p_number, eng_change, ybm の3つが一致\n\n"
                                  "例:\n"
                                  "行A: p_number=\"82122V1010\", eng_change=\"C01\",\n"
                                  "     ybm=\"MU5\", wire_len=\"00710\" → 正規化 → \"710\"\n\n"
                                  "↓ 同じグループで wire_len=0 の行を検索\n\n"
                                  "行B: p_number=\"82122V1010\" (同じ) ✓\n"
                                  "     eng_change=\"C01\" (同じ) ✓\n"
                                  "     ybm=\"MU5\" (同じ) ✓\n"
                                  "     wire_len=\"00000\" → \"0\"\n\n"
                                  "→ 行Bのwire_lenに \"710\" を設定\n\n"
                                  "※全てのwire_lenを正規化 (00710→710, 00000→0)",
                            ),
                            _ProcessStep(
                              number: "5",
                              title: "データベース登録",
                              content:
                                  "INSERT INTO m_processing_shield\n"
                                  "(p_number, eng_change, cfg_no, wire_type, wire_size,\n"
                                  " wire_color, circuit_1, circuit_2, term_proc_inst_1,\n"
                                  " term_proc_inst_2, mark_color_1, mark_color_2,\n"
                                  " term_part_no_1, add_parts_1, term_part_no_2, add_parts_2,\n"
                                  " wire_len, cfg_no_sub, ybm)\n"
                                  "VALUES (...)\n\n"
                                  "処理済みの全レコードをINSERT",
                            ),
                            _ProcessStep(
                              number: "6",
                              title: "ファイル移動",
                              content:
                                  "INPUT_DIR/RLTF17AS_bunseki.txt\n"
                                  "  ↓\n"
                                  "INPUT_DIR/bak/RLTF17AS_bunseki_20251128061234.txt\n\n"
                                  "タイムスタンプ付きでbakフォルダへ移動",
                            ),
                            SizedBox(height: 16),
                            Text(
                              "主要な関数",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            _FunctionRow(
                              name: "processRltfFile()",
                              description: "メイン処理（データ抽出→処理→DB登録）",
                            ),
                            _FunctionRow(
                              name: "normalizeWireLen()",
                              description: "電線長を正規化（00710→710）",
                            ),
                            _FunctionRow(
                              name: "setYbmBasedOnCfgNoSub()",
                              description: "cfg_no_subを使ってybmを設定",
                            ),
                            _FunctionRow(
                              name: "shareWireLenWithinYbmGroup()",
                              description: "同じグループ内で電線長を共有",
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("閉じる"),
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                "RLTF??A*.txt *.txt→m_processing_shield",
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text("規格データ"),
            Text("ch*.txt→ch_list"),
            const SizedBox(height: 10),
            Text("色データ"),
            Text("color*.txt→color_list"),
            ElevatedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (context) => const UserListModal(),
                );
              },
              child: const Text('ユーザー一覧'),
            ),
            Text("図面QRの印刷"),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const QrPrintShieldModal(),
                );
              },
              child: const Text('Shield QR印刷'),
            ),
          ],
        ),
      ),
    );
  }
}

double? _parseToDouble(dynamic value) {
  if (value is int) return value.toDouble();
  if (value is double) return value;
  if (value is String) return double.tryParse(value);
  return null;
}

String _formatSpace(double? free, double? total) {
  if (free == null || total == null) return '取得不可';
  return '${free.toStringAsFixed(2)} GB / ${total.toStringAsFixed(2)} GB';
}

// ヘルパーウィジェット: 処理ステップ表示
class _ProcessStep extends StatelessWidget {
  final String number;
  final String title;
  final String? subtitle;
  final String content;

  const _ProcessStep({
    required this.number,
    required this.title,
    this.subtitle,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: Text(content, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

// ヘルパーウィジェット: 関数の行表示
class _FunctionRow extends StatelessWidget {
  final String name;
  final String description;

  const _FunctionRow({required this.name, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 220,
            child: Text(
              name,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(description, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
