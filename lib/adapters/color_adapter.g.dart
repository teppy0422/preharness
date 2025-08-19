// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'color_adapter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ColorAdapterAdapter extends TypeAdapter<ColorAdapter> {
  @override
  final int typeId = 0;

  @override
  ColorAdapter read(BinaryReader reader) {
    return ColorAdapter();
  }

  @override
  void write(BinaryWriter writer, ColorAdapter obj) {
    writer.writeByte(0);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorAdapterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
