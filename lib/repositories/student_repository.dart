import '../models/siswa_model.dart';

abstract class StudentRepository {
  Future<Siswa> getStudentProfile();
  Future<Map<String, dynamic>> getViolationHistory({int page = 1, int limit = 10});
  Future<List<Map<String, dynamic>>> getSiswaList();
  Future<List<Map<String, dynamic>>> getJenisCatatan(String tipe);
  Future<void> saveViolation(int idGuru, int idSiswa, int idJenis, String tanggal, String keterangan);

  // CRUD Catatan
  Future<Map<String, dynamic>> getAllCatatan({int page = 1, int limit = 50, String? search, String? tipe, int? idSiswa});
  Future<void> updateCatatan(int idCatatan, {required int idSiswa, required int idJenis, required String tanggal, required String keterangan});
  Future<void> deleteCatatan(int idCatatan);

  // CRUD Siswa
  Future<void> createSiswa({required String nama, required String nis, required String kelas});
  Future<void> updateSiswa(int idSiswa, {required String nama, required String nis, required String kelas});
  Future<void> deleteSiswa(int idSiswa);

  // CRUD Jenis Catatan
  Future<List<Map<String, dynamic>>> getAllJenisCatatan();
  Future<void> createJenisCatatan({required String nama, required int poin, required String tipe});
  Future<void> updateJenisCatatan(int idJenis, {required String nama, required int poin, required String tipe});
  Future<void> deleteJenisCatatan(int idJenis);

  // Stats & Leaderboard
  Future<Map<String, dynamic>> getTeacherStats();
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 5});
}
