// ============================================
// Model: Siswa (Student)
// ============================================

import 'package:hive/hive.dart';

part 'siswa_model.g.dart';

@HiveType(typeId: 0)
class Siswa {
  @HiveField(0)
  final int idSiswa;
  @HiveField(1)
  final String nama;
  @HiveField(2)
  final String? nis;
  @HiveField(3)
  final String? kelas;

  Siswa({required this.idSiswa, required this.nama, this.nis, this.kelas});

  factory Siswa.fromJson(Map<String, dynamic> json) {
    return Siswa(
      idSiswa: json['id_siswa'] ?? json['id'] ?? 0,
      nama: json['nama'] ?? '',
      nis: json['nis'],
      kelas: json['kelas'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id_siswa': idSiswa, 'nama': nama, 'nis': nis, 'kelas': kelas};
  }
}
