import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'color_adapter.g.dart';

@HiveType(typeId: 0) // Choose a unique typeId for your adapter
class ColorAdapter extends TypeAdapter<Color> {
  @override
  final int typeId = 0; // Must match the @HiveType annotation

  @override
  Color read(BinaryReader reader) {
    final int value = reader.readInt();
    return Color(value);
  }

  @override
  void write(BinaryWriter writer, Color obj) {
    writer.writeInt(obj.value);
  }
}
