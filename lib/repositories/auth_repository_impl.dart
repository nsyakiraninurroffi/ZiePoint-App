import 'package:dio/dio.dart';
import '../core/dio_client.dart';
import '../core/local_db.dart';
import '../models/guru_model.dart';
import '../models/siswa_model.dart';
import '../services/token_manager.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio = DioClient().dio;
  final TokenManager _tokenManager = TokenManager();

  @override
  Future<Map<String, dynamic>> loginGuru(String email, String password) async {
    final response = await _dio.post(
      '/login/guru',
      data: {'email': email, 'password': password},
      options: Options(
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    await _tokenManager.saveTokens(
      accessToken: response.data['token'],
      role: 'guru',
      refreshToken: response.data['refreshToken'],
    );

    final guru = Guru.fromJson(response.data['guru']);
    await LocalDb.getGuruBox().put('current', guru);
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> loginSiswa(String nis, String password) async {
    final response = await _dio.post(
      '/login/siswa',
      data: {'nis': nis, 'password': password},
      options: Options(
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    await _tokenManager.saveTokens(
      accessToken: response.data['token'],
      role: 'siswa',
      refreshToken: response.data['refreshToken'],
    );

    final siswa = Siswa.fromJson(response.data['siswa']);
    await LocalDb.getSiswaBox().put('current', siswa);
    return response.data;
  }

  @override
  Future<void> logout() async {
    await _tokenManager.clearTokens();
    await LocalDb.getGuruBox().clear();
    await LocalDb.getSiswaBox().clear();
    await LocalDb.getCatatanBox().clear();
  }

  @override
  Future<Guru?> getCurrentGuru() async {
    return LocalDb.getGuruBox().get('current');
  }

  @override
  Future<Siswa?> getCurrentSiswa() async {
    return LocalDb.getSiswaBox().get('current');
  }

  @override
  Future<bool> isAuthenticated() async {
    return _tokenManager.accessToken != null;
  }
}
