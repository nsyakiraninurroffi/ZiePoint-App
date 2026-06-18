// ============================================
// Model: JenisCatatan
// ============================================

class JenisCatatan {
  final int idJenis;
  final String nama;
  final int poin;
  final String tipe; // 'pelanggaran' | 'prestasi'

  JenisCatatan({
    required this.idJenis,
    required this.nama,
    required this.poin,
    required this.tipe,
  });

  factory JenisCatatan.fromJson(Map<String, dynamic> json) {
    return JenisCatatan(
      idJenis: json['id_jenis'] ?? 0,
      nama: json['nama'] ?? '',
      poin: json['poin'] ?? 0,
      tipe: json['tipe'] ?? 'pelanggaran',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id_jenis': idJenis, 'nama': nama, 'poin': poin, 'tipe': tipe};
  }

  JenisCatatan copyWith({String? nama, int? poin, String? tipe}) {
    return JenisCatatan(
      idJenis: idJenis,
      nama: nama ?? this.nama,
      poin: poin ?? this.poin,
      tipe: tipe ?? this.tipe,
    );
  }
}
