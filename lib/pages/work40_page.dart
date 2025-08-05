import 'package:flutter/material.dart';
import 'package:preharness/widgets/efu.dart';
import 'package:preharness/widgets/responsive_scaffold.dart';
import 'package:preharness/routes/app_routes.dart';

import 'package:preharness/widgets/measurement.dart';
import 'package:preharness/widgets/dial_selector.dart';

class Work40Page extends StatelessWidget {
  const Work40Page({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      // appBar: AppBar(title: const Text("圧着作業")),
      title: 'work40',
      currentPage: AppRoutes.work40,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 4, child: _EquipmentInfoCard()),
                      const SizedBox(width: 16),
                      Expanded(flex: 4, child: _OperatorInfoCard()),
                      const SizedBox(width: 16),
                      Expanded(flex: 4, child: DialSelectorPage()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  InstructionSheetHeader(
                    lotNo: 'M392',
                    structureNo: '0099',
                    subAssy: '15-4',
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          const FooterButtons(),
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
              showCustomDialog(context, const DialSelectorPage());
            },
            child: const Text("ダイヤル調整"),
          ),
          const SizedBox(width: 8),
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
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Center(
          child: GestureDetector(
            onTap: () {}, // ダイアログ自体のタップで閉じない
            child: child,
          ),
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
              Text("機種: XYZ-100"),
              Text("管理ナンバー: EQ-123456"),
            ],
          ),
        ),
      ),
    );
  }
}

class _OperatorInfoCard extends StatelessWidget {
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
              Text("【作業者情報】", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("氏名: 田中 太郎"),
              Text("開始時間: 2025/07/25 09:15"),
            ],
          ),
        ),
      ),
    );
  }
}
