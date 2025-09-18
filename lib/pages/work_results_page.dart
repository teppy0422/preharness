import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:preharness/services/settings_service.dart';
import 'package:preharness/constants/app_colors.dart';
import 'package:intl/intl.dart';

class WorkResultsPage extends StatefulWidget {
  const WorkResultsPage({super.key});

  @override
  State<WorkResultsPage> createState() => _WorkResultsPageState();
}

class _WorkResultsPageState extends State<WorkResultsPage> {
  List<Map<String, dynamic>> _workResults = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWorkResults();
  }

  Future<String> _getBaseUrl() async {
    final settingsService = SettingsService();
    final settings = await settingsService.loadSettings();
    final mainPath = settings['main_path'] ?? '';

    if (mainPath.isNotEmpty) {
      String normalizedPath = mainPath
          .replaceAll(r'\\', '')
          .replaceAll('//', '');
      return 'http://$normalizedPath:3000';
    } else {
      return 'http://192.168.1.100:3000';
    }
  }

  Future<void> _loadWorkResults() async {
    try {
      final baseUrl = await _getBaseUrl();
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/work_results?limit=50&order=desc'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _workResults = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = 'サーバーエラー: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '通信エラー: $e';
        _isLoading = false;
      });
    }
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return '未設定';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('yyyy/MM/dd HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }

  String _formatDeliveryDate(String? deliveryDateStr) {
    if (deliveryDateStr == null ||
        deliveryDateStr.isEmpty ||
        deliveryDateStr == '未設定') {
      return '未設定';
    }

    try {
      // YYMMDD形式（6桁）の場合
      if (deliveryDateStr.length == 6) {
        final year = int.parse(deliveryDateStr.substring(0, 2));
        final month = int.parse(deliveryDateStr.substring(2, 4));
        final day = int.parse(deliveryDateStr.substring(4, 6));

        // 年の補正（2桁年 -> 4桁年）
        // 50未満なら2000年代、50以上なら1900年代と仮定
        final fullYear = year < 50 ? 2000 + year : 1900 + year;

        return '$fullYear/${month.toString().padLeft(2, '0')}/${day.toString().padLeft(2, '0')}';
      }

      // YYYYMMDD形式（8桁）の場合
      if (deliveryDateStr.length == 8) {
        final year = int.parse(deliveryDateStr.substring(0, 4));
        final month = int.parse(deliveryDateStr.substring(4, 6));
        final day = int.parse(deliveryDateStr.substring(6, 8));

        return '$year/${month.toString().padLeft(2, '0')}/${day.toString().padLeft(2, '0')}';
      }

      // その他の形式はそのまま表示
      return deliveryDateStr;
    } catch (e) {
      // パースエラーの場合は元の文字列をそのまま返す
      return deliveryDateStr;
    }
  }

  Widget _buildResultsTable() {
    if (_workResults.isEmpty) return Container();

    // テーブル列の定義（表示名とDBフィールド名）
    final columnDefinitions = [
      {'label': '準完日', 'field': 'efu_delivery_date'},
      {'label': '作業名', 'field': 'work_name'},
      {'label': 'ユーザー', 'field': 'username'},
      {'label': '実績数', 'field': 'actual_count'},
      {'label': '平均速度', 'field': 'average_speed'},
      {'label': '機種', 'field': 'machine_type'},
      {'label': '号機', 'field': 'machine_number'},
      {'label': '管理No', 'field': 'machine_serial'},
      {'label': 'ロット番号', 'field': 'efu_lot_num'},
      {'label': '品番', 'field': 'efu_p_number'},
      {'label': 'CFG No', 'field': 'efu_cfg_no'},
      {'label': 'ワイヤータイプ', 'field': 'efu_wire_type'},
      {'label': 'ワイヤーサイズ', 'field': 'efu_wire_size'},
      {'label': 'ワイヤー色', 'field': 'efu_wire_color'},
      {'label': 'ワイヤー長', 'field': 'efu_wire_len'},
      {'label': 'ワイヤー本数', 'field': 'efu_wire_cnt'},
      {'label': '端子1', 'field': 'block_terminals_0'},
      {'label': '端子2', 'field': 'block_terminals_1'},
      {'label': '端子長', 'field': 'block_terminals_length'},
      {'label': '作業日時', 'field': 'created_at'},
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.getLineColor(context)),
        borderRadius: BorderRadius.circular(0),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: columnDefinitions.length * 120.0, // 全列の合計幅
          child: Column(
            children: [
              // テーブルヘッダー
              Container(
                decoration: BoxDecoration(
                  color: AppColors.getCardColor(context),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: columnDefinitions
                      .map(
                        (column) => _buildHeaderCell(
                          column['label']!,
                          column['field']!,
                        ),
                      )
                      .toList(),
                ),
              ),

              // テーブルボディ（Y方向スクロール）
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: _workResults
                        .map(
                          (result) => _buildDataRow(result, columnDefinitions),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String label, String fieldName) {
    return Container(
      width: 120,
      height: 50,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: AppColors.getLineColor(context), width: 0.5),
          bottom: BorderSide(
            color: AppColors.getLineColor(context),
            width: 0.5,
          ),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColors.getHighLightColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              fieldName,
              style: TextStyle(
                fontSize: 8,
                color: AppColors.getLineColor(context),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(
    Map<String, dynamic> result,
    List<Map<String, String>> columnDefinitions,
  ) {
    final cells = columnDefinitions.map((columnDef) {
      final fieldName = columnDef['field']!;

      // 特別な表示形式の処理
      if (fieldName == 'actual_count') {
        return '${result[fieldName] ?? 0}個';
      } else if (fieldName == 'average_speed') {
        return '${(result[fieldName] ?? 0.0).toStringAsFixed(1)}個/分';
      } else if (fieldName == 'created_at') {
        return _formatDateTime(result[fieldName]);
      } else if (fieldName == 'efu_delivery_date') {
        return _formatDeliveryDate(result[fieldName]?.toString());
      } else {
        return result[fieldName]?.toString() ?? '未設定';
      }
    }).toList();

    return Row(
      children: cells.map((cell) => _buildDataCell(cell.toString())).toList(),
    );
  }

  Widget _buildDataCell(String text) {
    return Container(
      width: 120,
      height: 40,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: AppColors.getLineColor(context), width: 0.5),
          bottom: BorderSide(
            color: AppColors.getLineColor(context),
            width: 0.5,
          ),
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 11),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Future<void> _exportToCsv() async {
    try {
      // loading表示
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CSV出力中...'),
          duration: Duration(seconds: 2),
        ),
      );

      // 設定からpath01を取得
      final settingsService = SettingsService();
      final settings = await settingsService.loadSettings();
      final path01 = settings['path_01'];

      if (path01 == null || path01.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('出力先パス（path01）が設定されていません'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // APIリクエスト
      final baseUrl = await _getBaseUrl();
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/work_results/export'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'outputPath': path01,
              'format': 'csv'
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV出力完了: ${result['filename']} (${result['recordCount']}件)'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV出力エラー: ${error['error']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CSV出力エラー: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('作業実績'),
        backgroundColor: AppColors.getCardColor(context),
        foregroundColor: AppColors.getHighLightColor(context),
        elevation: 1,
        actions: [
          IconButton(
            onPressed: _loadWorkResults,
            icon: const Icon(Icons.refresh),
            tooltip: '更新',
          ),
          IconButton(
            onPressed: _exportToCsv,
            icon: const Icon(Icons.download),
            tooltip: 'CSV出力',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('作業実績を読み込み中...'),
                ],
              ),
            )
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadWorkResults,
                    child: const Text('再試行'),
                  ),
                ],
              ),
            )
          : _workResults.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text('作業実績がありません', style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.getCardColor(context),
                  child: Row(
                    children: [
                      Icon(
                        Icons.analytics,
                        color: AppColors.getHighLightColor(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_workResults.length}件の作業実績',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.getHighLightColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildResultsTable(),
                  ),
                ),
              ],
            ),
    );
  }
}

// 使い回し可能なボタン用Widget
class WorkResultsButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const WorkResultsButton({
    super.key,
    this.label = '作業実績',
    this.icon = Icons.analytics,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed:
          onPressed ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WorkResultsPage()),
            );
          },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.getCardColor(context),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 0,
          vertical: 0,
        ), // ✅ 外側padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(
            color: AppColors.getLineColor(context), // ボーダー色
            width: 1.0, // ボーダーの太さ
          ),
        ),
      ),
      // ✅ アイコン＋テキストの自由配置
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.getLineColor(context),
          ), // アイコンサイズ調整
          const SizedBox(width: 2), // ✅ アイコンとテキスト間隔
          Text(
            label,
            style: TextStyle(
              color: AppColors.getLineColor(context),
              fontSize: 14, // ✅ フォントサイズ調整
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
