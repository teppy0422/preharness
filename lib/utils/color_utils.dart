import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:preharness/models/color_entry.dart';
import 'package:collection/collection.dart';

/// 指定された [colorNum] に対応する色をHiveから非同期で取得します。
///
/// [getForeColor] が `true` の場合は前景色を、それ以外の場合は背景色を返します。
/// 見つからない場合や、ボックスが開けない場合は `null` を返します。
///
/// 例:
/// ```dart
/// // 背景色を取得
/// final bgColor = await getColorFromHive('A1');
/// // 前景色を取得
/// final fgColor = await getColorFromHive('A1', getForeColor: true);
/// ```
Future<Color?> getColorFromHive(String colorNum, {bool getForeColor = false}) async {
  try {
    final box = await Hive.openBox<ColorEntry>('colorEntryBox');
    final ColorEntry? foundEntry = box.values.firstWhereOrNull(
      (entry) => entry.colorNum == colorNum,
    );
    return getForeColor ? foundEntry?.foreColor : foundEntry?.backColor;
  } catch (e) {
    debugPrint('Error getting color from Hive: $e');
    return null;
  }
}
