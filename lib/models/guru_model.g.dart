// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guru_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GuruAdapter extends TypeAdapter<Guru> {
  @override
  final int typeId = 3;

  @override
  Guru read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Guru(
      idGuru: fields[0] as int,
      nama: fields[1] as String,
      email: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Guru obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.idGuru)
      ..writeByte(1)
      ..write(obj.nama)
      ..writeByte(2)
      ..write(obj.email);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuruAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
