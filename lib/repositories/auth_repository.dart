import '../models/guru_model.dart';
import '../models/siswa_model.dart';

abstract class AuthRepository {
  Future<Map<String, dynamic>> loginGuru(String email, String password);
  Future<Map<String, dynamic>> loginSiswa(String nis, String password);
  Future<void> logout();
  Future<Guru?> getCurrentGuru();
  Future<Siswa?> getCurrentSiswa();
  Future<bool> isAuthenticated();
}
