// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'color_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ColorEntryAdapter extends TypeAdapter<ColorEntry> {
  @override
  final int typeId = 1;

  @override
  ColorEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ColorEntry(
      colorNum: fields[0] as String,
      backColor: fields[1] as Color,
      foreColor: fields[2] as Color,
    );
  }

  @override
  void write(BinaryWriter writer, ColorEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.colorNum)
      ..writeByte(1)
      ..write(obj.backColor)
      ..writeByte(2)
      ..write(obj.foreColor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
