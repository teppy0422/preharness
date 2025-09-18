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

  Widget _buildResultCard(Map<String, dynamic> result) {
    final actualCount = result['actual_count'] ?? 0;
    final averageSpeed = result['average_speed'] ?? 0.0;
    final workName = result['work_name'] ?? '未設定';
    final username = result['username'] ?? '未設定';
    final machineType = result['machine_type'] ?? '未設定';
    final machineNumber = result['machine_number'] ?? '未設定';
    final createdAt = _formatDateTime(result['created_at']);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppColors.getLineColor(context), width: 0.5),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Expanded(
              child: Text(
                '$workName - $username',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.getHighLightColor(context),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.getHighLightColor(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$actualCount個',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('速度: ${averageSpeed.toStringAsFixed(1)}個/分'),
              Text(
                '$machineType $machineNumber | $createdAt',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.getLineColor(context),
                ),
              ),
            ],
          ),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailSection('機械情報', [
                  _buildDetailRow('機種', machineType),
                  _buildDetailRow('号機', machineNumber),
                  _buildDetailRow('管理No', result['machine_serial']),
                ]),
                const SizedBox(height: 16),
                _buildDetailSection('製品情報', [
                  _buildDetailRow('ロット番号', result['efu_lot_num']),
                  _buildDetailRow('品番', result['efu_p_number']),
                  _buildDetailRow('CFG No', result['efu_cfg_no']),
                  _buildDetailRow('ワイヤータイプ', result['efu_wire_type']),
                  _buildDetailRow('ワイヤーサイズ', result['efu_wire_size']),
                  _buildDetailRow('ワイヤー色', result['efu_wire_color']),
                  _buildDetailRow('ワイヤー長', result['efu_wire_len']),
                  _buildDetailRow('ワイヤー本数', result['efu_wire_cnt']),
                ]),
                const SizedBox(height: 16),
                _buildDetailSection('端子情報', [
                  _buildDetailRow('端子1', result['block_terminals_0']),
                  _buildDetailRow('端子2', result['block_terminals_1']),
                  _buildDetailRow('端子長', result['block_terminals_length']),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.getHighLightColor(context),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.getCardColor(context),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.getLineColor(context),
              width: 0.5,
            ),
          ),
          child: Column(children: rows),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.getLineColor(context),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? '未設定',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
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
                  child: ListView.builder(
                    itemCount: _workResults.length,
                    itemBuilder: (context, index) {
                      return _buildResultCard(_workResults[index]);
                    },
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
          Icon(icon, size: 16), // アイコンサイズ調整
          const SizedBox(width: 2), // ✅ アイコンとテキスト間隔
          Text(
            label,
            style: const TextStyle(
              fontSize: 14, // ✅ フォントサイズ調整
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
