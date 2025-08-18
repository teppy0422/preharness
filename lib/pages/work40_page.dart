import 'package:flutter/material.dart';
import 'package:preharness/services/api_service.dart';
import 'package:preharness/widgets/efu.dart';
import 'package:preharness/widgets/efu_detail.dart'; // 詳細ページをインポート
import 'package:preharness/widgets/responsive_scaffold.dart';
import 'package:preharness/routes/app_routes.dart';

import 'package:preharness/widgets/measurement.dart';

class Work40Page extends StatefulWidget {
  const Work40Page({super.key});

  @override
  State<Work40Page> createState() => _Work40PageState();
}

class _Work40PageState extends State<Work40Page> {
  Map<String, dynamic>? _processingConditions;
  bool _isDetailView = false;
  Map<String, dynamic>? _selectedBlockInfo;

  void _onSearch(String query) async {
    String? pNumber;
    String? cfgNo;

    if (query.length >= 38) {
      cfgNo = query.substring(10, 14);
      pNumber = query.substring(24, 34);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('入力された文字列が短すぎます。')));
      return;
    }

    try {
      final result = await ApiService.fetchProcessingConditions(
        pNumber: pNumber,
        cfgNo: cfgNo,
      );
      setState(() {
        _processingConditions = result;
        _isDetailView = false; // 新しい検索をしたら一覧に戻す
      });

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('検索成功: ${result.toString()}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('データが見つかりませんでした。p: $pNumber, c: $cfgNo')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('検索エラー: $e')));
    }
  }

  void _handleBlockTapped(Map<String, dynamic> blockInfo) {
    setState(() {
      _selectedBlockInfo = blockInfo;
      _isDetailView = true;
    });
  }

  void _handleBackFromDetail() {
    setState(() {
      _isDetailView = false;
      _selectedBlockInfo = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'work40',
      currentPage: AppRoutes.work40,
      child: Stack(
        children: [
          Positioned(
            top: 60,
            left: 10,
            right: 10,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _EquipmentInfoCard()),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _SearchCard(onSearch: _onSearch)),
              ],
            ),
          ),
          // 状態に応じて表示を切り替える
          Positioned(
            top: 200,
            left: 10,
            right: 10,
            bottom: 80,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _isDetailView
                      ? EfuDetailPage(
                          processingConditions: _processingConditions!,
                          blockInfo: _selectedBlockInfo!,
                          onBack: _handleBackFromDetail,
                        )
                      : EfuPage(
                          lot_num:
                              _processingConditions?['lot_num']?.toString() ??
                              '',
                          p_number:
                              _processingConditions?['p_number']?.toString() ??
                              '',
                          eng_change:
                              _processingConditions?['eng_change']
                                  ?.toString() ??
                              '',
                          cfg_no:
                              _processingConditions?['cfg_no']?.toString() ??
                              '',
                          subAssy:
                              _processingConditions?['sub_assy']?.toString() ??
                              '',
                          wire_type:
                              _processingConditions?['wire_type']?.toString() ??
                              '',
                          wire_size:
                              _processingConditions?['wire_size']?.toString() ??
                              '',
                          wire_color:
                              _processingConditions?['wire_color']
                                  ?.toString() ??
                              '',
                          wire_len:
                              _processingConditions?['wire_len']?.toString() ??
                              '',
                          circuit_1:
                              _processingConditions?['circuit_1']?.toString() ??
                              '',
                          circuit_2:
                              _processingConditions?['circuit_2']?.toString() ??
                              '',
                          term_proc_inst_1:
                              _processingConditions?['term_proc_inst_1']
                                  ?.toString() ??
                              '',
                          term_proc_inst_2:
                              _processingConditions?['term_proc_inst_2']
                                  ?.toString() ??
                              '',
                          mark_color_1:
                              (_processingConditions?['mark_color_1']
                                          ?.toString() ??
                                      "")
                                  .isNotEmpty
                              ? "ﾏｼﾞｯｸ_${_processingConditions?['mark_color_1']}"
                              : "",
                          mark_color_2:
                              (_processingConditions?['mark_color_2']
                                          ?.toString() ??
                                      "")
                                  .isNotEmpty
                              ? "ﾏｼﾞｯｸ_${_processingConditions?['mark_color_2']}"
                              : "",
                          strip_len_1:
                              _processingConditions?['strip_len_1']
                                  ?.toString() ??
                              '',
                          strip_len_2:
                              _processingConditions?['strip_len_2']
                                  ?.toString() ??
                              '',
                          term_part_no_1:
                              _processingConditions?['term_part_no_1']
                                  ?.toString() ??
                              '',
                          term_part_no_2:
                              _processingConditions?['term_part_no_2']
                                  ?.toString() ??
                              '',
                          add_parts_1:
                              _processingConditions?['add_parts_1']
                                  ?.toString() ??
                              '',
                          add_parts_2:
                              _processingConditions?['add_parts_2']
                                  ?.toString() ??
                              '',
                          cut_code:
                              _processingConditions?['cut_code']?.toString() ??
                              '',
                          wire_cnt:
                              _processingConditions?['wire_cnt']?.toString() ??
                              '',
                          delivery_date:
                              _processingConditions?['delivery_date']
                                  ?.toString() ??
                              '200101',
                          onBlockTapped: _handleBlockTapped,
                        ),
                ],
              ),
            ),
          ),
          Positioned(bottom: 20, left: 10, right: 10, child: FooterButtons()),
        ],
      ),
    );
  }
}

class FooterButtons extends StatelessWidget {
  const FooterButtons({super.key});
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () {
              showCustomDialog(context, const Measurement());
            },
            child: const Text("規格測定"),
          ),
        ],
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

class _EquipmentInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: .5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("【設備情報】", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text("号機: 5号機"),
              Text("機種: CM20"),
              Text("管理ナンバー: 3456"),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchCard extends StatefulWidget {
  final Function(String) onSearch;
  const _SearchCard({required this.onSearch});
  @override
  State<_SearchCard> createState() => _SearchCardState();
}

class _SearchCardState extends State<_SearchCard> {
  final TextEditingController _searchController = TextEditingController(
    text: 'N712/5M39255551780700186821616BP80D011N712/94.54.5325184039',
  );
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch() {
    final query = _searchController.text;
    if (query.isEmpty) return;
    widget.onSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: .5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "【データ検索】",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'ロット番号などを入力',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _handleSearch(),
              ),
              const SizedBox(height: 0),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _handleSearch,
                  child: const Text('検索'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
