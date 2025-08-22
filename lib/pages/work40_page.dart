import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // RawKeyEventのために追加
import 'package:preharness/services/api_service.dart';
import 'package:preharness/widgets/efu.dart';
import 'package:preharness/widgets/efu_detail.dart'; // 詳細ページをインポート
import 'package:preharness/widgets/responsive_scaffold.dart';
import 'package:preharness/routes/app_routes.dart';
import 'package:preharness/utils/global.dart';
import "package:preharness/constants/app_colors.dart";
import 'package:preharness/services/settings_service.dart';
import 'package:preharness/widgets/flip_animation.dart';

class Work40Page extends StatefulWidget {
  const Work40Page({super.key});

  @override
  State<Work40Page> createState() => _Work40PageState();
}

class _Work40PageState extends State<Work40Page>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _processingConditions;
  bool _isDetailView = false;
  Map<String, dynamic>? _selectedBlockInfo;
  List<Map<String, dynamic>>? _chListData;
  bool _isLoadingChList = false;
  String? _chListError;
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController(
    text: 'N712/ 5M39255551780700186821616BP80D011N712/94.54.5325184039',
  );

  late final AnimationController _animationController;
  String _animationType = 'none';
  final _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadSettings();
    _focusAndSelectSearchText(); // 初期表示時にもフォーカス
  }

  Future<void> _loadSettings() async {
    _animationType = await _settingsService.loadAnimationType();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _focusAndSelectSearchText() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_searchFocusNode);
      _searchController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _searchController.text.length,
      );
    });
  }

  void _onSearch(String query) async {
    String? pNumber;
    String? cfgNo;

    if (query.length >= 38) {
      cfgNo = query.substring(11, 15);
      pNumber = query.substring(25, 35);
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

      if (_animationType == 'flip') {
        _animationController.forward(from: 0.0);
      }

      _focusAndSelectSearchText(); // 検索後にフォーカス

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

  void _handleBlockTapped(Map<String, dynamic> blockInfo) async {
    if (_animationType == 'flip') {
      _animationController.forward(from: 0.0);
    }

    setState(() {
      _selectedBlockInfo = blockInfo;
      _isDetailView = true;
      _isLoadingChList = true;
      _chListError = null;
      _chListData = null;
    });

    try {
      final thin = blockInfo['terminals'][0] as String;
      var fhin = blockInfo['terminals'][1] as String;
      final hin1 = _processingConditions!['wire_type'] as String;
      final size1 = _processingConditions!['wire_size'] as String;

      // fhin が "" のときは "@@@" に置き換え
      if (fhin.isEmpty) {
        fhin = "@@@";
      }

      final data = await ApiService.searchChList(
        thin: thin,
        fhin: fhin,
        hin1: hin1,
        size1: size1,
      );
      setState(() {
        _chListData = data;
      });
    } catch (e) {
      setState(() {
        _chListError = 'CHリストの読み込みに失敗しました: $e';
      });
    } finally {
      setState(() {
        _isLoadingChList = false;
      });
    }
  }

  void _handleBackFromDetail() {
    setState(() {
      _isDetailView = false;
      _selectedBlockInfo = null;
    });
    // if (_animationType == 'flip') {
    //   _animationController.forward(from: 0.0);
    // }
    _focusAndSelectSearchText(); // 詳細から戻った時にフォーカス
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'work40',
      currentPage: AppRoutes.work40,
      child: Stack(
        children: [
          Positioned(
            top: 20,
            left: 10,
            right: 10,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: _SearchCard(
                    onSearch: _onSearch,
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onSelectAll: _focusAndSelectSearchText,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: _EquipmentInfoCard()),
                const SizedBox(width: 72),
              ],
            ),
          ),
          // 状態に応じて表示を切り替える
          Positioned(
            top: 180,
            left: 10,
            right: 10,
            bottom: 10,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _isDetailView
                      ? EfuDetailPage(
                          processingConditions: _processingConditions!,
                          blockInfo: _selectedBlockInfo!,
                          onBack: _handleBackFromDetail,
                          chListData: _chListData,
                          isLoadingChList: _isLoadingChList,
                          chListError: _chListError,
                        )
                      : _buildEfuPage(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEfuPage() {
    final efuPage = EfuPage(
      lot_num: _processingConditions?['lot_num']?.toString() ?? '',
      p_number: _processingConditions?['p_number']?.toString() ?? '',
      eng_change: _processingConditions?['eng_change']?.toString() ?? '',
      cfg_no: _processingConditions?['cfg_no']?.toString() ?? '',
      subAssy: _processingConditions?['sub_assy']?.toString() ?? '',
      wire_type: _processingConditions?['wire_type']?.toString() ?? '',
      wire_size: _processingConditions?['wire_size']?.toString() ?? '',
      wire_color: _processingConditions?['wire_color']?.toString() ?? '',
      wire_len: _processingConditions?['wire_len']?.toString() ?? '',
      circuit_1: _processingConditions?['circuit_1']?.toString() ?? '',
      circuit_2: _processingConditions?['circuit_2']?.toString() ?? '',
      term_proc_inst_1:
          _processingConditions?['term_proc_inst_1']?.toString() ?? '',
      term_proc_inst_2:
          _processingConditions?['term_proc_inst_2']?.toString() ?? '',
      mark_color_1:
          (_processingConditions?['mark_color_1']?.toString() ?? "").isNotEmpty
          ? "ﾏｼﾞｯｸ_${_processingConditions?['mark_color_1']}"
          : "",
      mark_color_2:
          (_processingConditions?['mark_color_2']?.toString() ?? "").isNotEmpty
          ? "ﾏｼﾞｯｸ_${_processingConditions?['mark_color_2']}"
          : "",
      strip_len_1: _processingConditions?['strip_len_1']?.toString() ?? '',
      strip_len_2: _processingConditions?['strip_len_2']?.toString() ?? '',
      term_part_no_1:
          _processingConditions?['term_part_no_1']?.toString() ?? '',
      term_part_no_2:
          _processingConditions?['term_part_no_2']?.toString() ?? '',
      add_parts_1: _processingConditions?['add_parts_1']?.toString() ?? '',
      add_parts_2: _processingConditions?['add_parts_2']?.toString() ?? '',
      cut_code: _processingConditions?['cut_code']?.toString() ?? '',
      wire_cnt: _processingConditions?['wire_cnt']?.toString() ?? '',
      delivery_date:
          _processingConditions?['delivery_date']?.toString() ?? '200101',
      onBlockTapped: _handleBlockTapped,
    );

    if (_animationType == 'flip') {
      return FlipAnimation(controller: _animationController, child: efuPage);
    }
    return efuPage;
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
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSelectAll;

  const _SearchCard({
    required this.onSearch,
    required this.controller,
    required this.focusNode,
    required this.onSelectAll,
  });

  @override
  State<_SearchCard> createState() => _SearchCardState();
}

class _SearchCardState extends State<_SearchCard> {
  // QRリーダーからの入力を保持する変数
  String _inputText = '';
  // ソフトキーボードモードが有効かどうかを管理する状態変数
  bool _isKeyboardEnabled = false;
  // 検索が実行された直後かどうかを判断するフラグ
  bool _justSearched = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
    // 初期テキストをinputTextにも反映
    _inputText = widget.controller.text;
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {});
  }

  void _handleSearch() {
    // 現在のモードに応じてcontrollerにテキストをセット
    if (_isKeyboardEnabled) {
      _inputText = widget.controller.text;
    } else {
      widget.controller.text = _inputText;
    }

    if (widget.controller.text.isEmpty) return;
    widget.onSearch(widget.controller.text);

    // 検索が実行されたことを記録
    setState(() {
      _justSearched = true;
    });
  }

  // QRリーダーモードのウィジェット
  Widget _buildRawKeyboardReader() {
    return RawKeyboardListener(
      focusNode: widget.focusNode,
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter) {
            _handleSearch();
            return;
          }
          if (event.logicalKey == LogicalKeyboardKey.backspace) {
            // Backspaceが押されたら、検索直後フラグはリセット
            _justSearched = false;
            if (_inputText.isNotEmpty) {
              setState(() {
                _inputText = _inputText.substring(0, _inputText.length - 1);
              });
            }
            return;
          }

          final char = event.character;
          if (char != null && char.isNotEmpty) {
            final code = char.codeUnits.first;
            if (code < 32 || code == 127) {
              return; // 制御文字は無視
            }

            setState(() {
              if (_justSearched) {
                // 検索直後の最初の入力であれば、テキストをクリアして置き換え
                _inputText = char;
              } else {
                // 既存のスキャンに追記
                _inputText += char;
              }
              // 文字が入力されたので、検索直後フラグはリセット
              _justSearched = false;
            });
          }
        }
      },
      child: GestureDetector(
        onTap: () {
          // タップ時にクリア処理を実行
          setState(() {
            _inputText = '';
            widget.controller.text = '';
          });
          widget.focusNode.requestFocus();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.focusNode.hasFocus
                  ? AppColors.neonGreen
                  : Colors.grey,
              width: widget.focusNode.hasFocus ? 2.0 : 1.0,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            _inputText.isEmpty ? 'エフをQRリーダーで読む' : _inputText,
            style: TextStyle(
              fontSize: 12,
              color: _inputText.isEmpty
                  ? Theme.of(context).hintColor
                  : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ),
    );
  }

  // ソフトキーボードモードのウィジェット
  Widget _buildTextField() {
    return TextField(
      style: const TextStyle(fontSize: 14),
      controller: widget.controller,
      focusNode: widget.focusNode,
      autocorrect: false,
      enableSuggestions: false,
      decoration: const InputDecoration(
        hintText: 'エフを手入力',
        isDense: true,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      inputFormatters: [HalfWidthTextInputFormatter()],
      onSubmitted: (_) => _handleSearch(),
    );
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
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              // モードに応じて表示するウィジェットを切り替え
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isKeyboardEnabled
                          ? Icons.qr_code_scanner
                          : Icons.keyboard,
                    ),
                    tooltip: _isKeyboardEnabled
                        ? 'QRリーダーモードに切り替え'
                        : '手入力モードに切り替え',
                    onPressed: () {
                      setState(() {
                        _isKeyboardEnabled = !_isKeyboardEnabled;
                        // モード切替時にテキストを同期
                        if (_isKeyboardEnabled) {
                          widget.controller.text = _inputText;
                        } else {
                          _inputText = widget.controller.text;
                        }
                      });
                      widget.focusNode.requestFocus();
                    },
                  ),
                  Expanded(
                    child: _isKeyboardEnabled
                        ? _buildTextField()
                        : _buildRawKeyboardReader(),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: _handleSearch,
                    child: const Text('検索', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // モード切り替えボタン
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
