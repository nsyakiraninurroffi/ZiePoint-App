// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'siswa_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SiswaAdapter extends TypeAdapter<Siswa> {
  @override
  final int typeId = 0;

  @override
  Siswa read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Siswa(
      idSiswa: fields[0] as int,
      nama: fields[1] as String,
      nis: fields[2] as String?,
      kelas: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Siswa obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.idSiswa)
      ..writeByte(1)
      ..write(obj.nama)
      ..writeByte(2)
      ..write(obj.nis)
      ..writeByte(3)
      ..write(obj.kelas);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SiswaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
