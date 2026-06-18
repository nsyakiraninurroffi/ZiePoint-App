// ============================================
// Model: Catatan (Disciplinary/Achievement Record)
// ============================================

import 'package:hive/hive.dart';

part 'catatan_model.g.dart';

@HiveType(typeId: 1)
class Catatan {
  @HiveField(0)
  final int idCatatan;
  @HiveField(1)
  final String tanggal;
  @HiveField(2)
  final String? keterangan;
  @HiveField(3)
  final String namaJenis;
  @HiveField(4)
  final int poin;
  @HiveField(5)
  final String tipe; // 'pelanggaran' or 'prestasi'
  @HiveField(6)
  final String namaGuru;

  Catatan({
    required this.idCatatan,
    required this.tanggal,
    this.keterangan,
    required this.namaJenis,
    required this.poin,
    required this.tipe,
    required this.namaGuru,
  });

  factory Catatan.fromJson(Map<String, dynamic> json) {
    return Catatan(
      idCatatan: json['id_catatan'] ?? 0,
      tanggal: json['tanggal'] ?? '',
      keterangan: json['keterangan'],
      namaJenis: json['nama_jenis'] ?? '',
      poin: json['poin'] ?? 0,
      tipe: json['tipe'] ?? 'pelanggaran',
      namaGuru: json['nama_guru'] ?? '',
    );
  }
}

/// Summary of student points
@HiveType(typeId: 2)
class RiwayatSummary {
  @HiveField(0)
  final int totalPelanggaran;
  @HiveField(1)
  final int totalPrestasi;
  @HiveField(2)
  final int totalPoin;

  RiwayatSummary({
    required this.totalPelanggaran,
    required this.totalPrestasi,
    required this.totalPoin,
  });

  factory RiwayatSummary.fromJson(Map<String, dynamic> json) {
    return RiwayatSummary(
      totalPelanggaran: json['total_pelanggaran'] ?? 0,
      totalPrestasi: json['total_prestasi'] ?? 0,
      totalPoin: json['total_poin'] ?? 0,
    );
  }
}
