// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catatan_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CatatanAdapter extends TypeAdapter<Catatan> {
  @override
  final int typeId = 1;

  @override
  Catatan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Catatan(
      idCatatan: fields[0] as int,
      tanggal: fields[1] as String,
      keterangan: fields[2] as String?,
      namaJenis: fields[3] as String,
      poin: fields[4] as int,
      tipe: fields[5] as String,
      namaGuru: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Catatan obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.idCatatan)
      ..writeByte(1)
      ..write(obj.tanggal)
      ..writeByte(2)
      ..write(obj.keterangan)
      ..writeByte(3)
      ..write(obj.namaJenis)
      ..writeByte(4)
      ..write(obj.poin)
      ..writeByte(5)
      ..write(obj.tipe)
      ..writeByte(6)
      ..write(obj.namaGuru);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatatanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RiwayatSummaryAdapter extends TypeAdapter<RiwayatSummary> {
  @override
  final int typeId = 2;

  @override
  RiwayatSummary read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RiwayatSummary(
      totalPelanggaran: fields[0] as int,
      totalPrestasi: fields[1] as int,
      totalPoin: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, RiwayatSummary obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.totalPelanggaran)
      ..writeByte(1)
      ..write(obj.totalPrestasi)
      ..writeByte(2)
      ..write(obj.totalPoin);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RiwayatSummaryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
