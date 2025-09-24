import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'color_entry.g.dart';

@HiveType(typeId: 1) // Use a different typeId than ColorAdapter
class ColorEntry extends HiveObject {
  @HiveField(0)
  String colorNum;

  @HiveField(1)
  Color backColor;

  @HiveField(2)
  Color foreColor;

  ColorEntry({
    required this.colorNum,
    required this.backColor,
    required this.foreColor,
  });

  @override
  String toString() {
    return 'ColorEntry(colorNum: $colorNum, backColor: $backColor, foreColor: $foreColor)';
  }
}
