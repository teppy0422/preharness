import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:preharness/core/constants/app_colors.dart';

/// 機械情報を表示するカードウィジェット
class EquipmentInfoCard extends StatefulWidget {
  const EquipmentInfoCard({super.key});

  @override
  State<EquipmentInfoCard> createState() => _EquipmentInfoCardState();
}

class _EquipmentInfoCardState extends State<EquipmentInfoCard> {
  String _machineNumber = ''; // 号機
  String _machineType = ''; // 機種
  String _machineSerial = ''; // 管理No

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _machineNumber = prefs.getString('machine_number') ?? '未設定';
      _machineType = prefs.getString('machine_type') ?? '未設定';
      _machineSerial = prefs.getString('machine_serial') ?? '未設定';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        border: Border.all(color: AppColors.getLineSubColor(context), width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "号機: $_machineNumber",
                    style: TextStyle(color: AppColors.getLineSubColor(context)),
                  ),
                ),
                Expanded(child: Text("機種: $_machineType")),
                Expanded(child: Text("管理No: $_machineSerial")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}