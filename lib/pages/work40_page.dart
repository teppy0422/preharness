import 'package:flutter/material.dart';
import 'package:preharness/widgets/efu.dart';
import 'package:preharness/widgets/responsive_scaffold.dart';
import 'package:preharness/routes/app_routes.dart';

import 'package:preharness/widgets/standard_info_card.dart';

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
                  const SizedBox(height: 80),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 4, child: _EquipmentInfoCard()),
                      const SizedBox(width: 16),
                      Expanded(flex: 6, child: _OperatorInfoCard()),
                    ],
                  ),
                  const SizedBox(height: 14),
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
          ElevatedButton(onPressed: () {}, child: const Text("作業開始")),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              showStandardInfoDialog(context);
            },
            child: const Text("規格測定"),
          ),
        ],
      ),
    );
  }
}

void showStandardInfoDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true, // ← これでも一応必要
    barrierColor: Colors.black54,
    builder: (context) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque, // ← 背景のタップも拾う
        onTap: () {
          Navigator.of(context).pop(); // ← 背景タップで閉じる
        },
        child: Center(
          child: GestureDetector(
            onTap: () {}, // ← Card 自体はタップしても閉じないように
            child: const StandardInfoCard(),
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
              SizedBox(height: 8),
              Text("号機: 5号機"),
              Text("機種: XYZ-100"),
              Text("管理ナンバー: EQ-123456"),
              Text("作業名: 圧着"),
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
