// ============================================
// Model: Guru (Teacher)
// ============================================

import 'package:hive/hive.dart';

part 'guru_model.g.dart';

@HiveType(typeId: 3)
class Guru {
  @HiveField(0)
  final int idGuru;
  @HiveField(1)
  final String nama;
  @HiveField(2)
  final String email;

  Guru({required this.idGuru, required this.nama, required this.email});

  factory Guru.fromJson(Map<String, dynamic> json) {
    return Guru(
      idGuru: json['id_guru'] ?? json['id'] ?? 0,
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id_guru': idGuru, 'nama': nama, 'email': email};
  }
}
