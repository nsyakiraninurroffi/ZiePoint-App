import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/app_logger.dart';
import '../models/guru_model.dart';
import '../models/siswa_model.dart';
import '../repositories/auth_repository.dart';

enum AuthState { idle, loading, authenticated, error }

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepo;

  LoginViewModel(this._authRepo);

  AuthState _state = AuthState.idle;
  String? _errorMessage;
  bool _isGuruMode = true;
  String _role = ''; // 'guru' or 'siswa'
  Guru? _guru;
  Siswa? _siswa;

  // Getters
  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isGuruMode => _isGuruMode;
  bool get isLoading => _state == AuthState.loading;
  String get role => _role;
  Guru? get guru => _guru;
  Siswa? get siswa => _siswa;

  void toggleMode() {
    _isGuruMode = !_isGuruMode;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> loginGuru(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _authRepo.loginGuru(email, password);
      _guru = Guru.fromJson(data['guru']);
      _role = 'guru';
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _handleDioError(e);
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      _state = AuthState.error;
      AppLogger.e('Login guru error', e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginSiswa(String nis, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _authRepo.loginSiswa(nis, password);
      _siswa = Siswa.fromJson(data['siswa']);
      _role = 'siswa';
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _handleDioError(e);
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      _state = AuthState.error;
      AppLogger.e('Login siswa error', e);
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepo.logout();
    _state = AuthState.idle;
    _role = '';
    _guru = null;
    _siswa = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final isAuth = await _authRepo.isAuthenticated();
    if (isAuth) {
      _guru = await _authRepo.getCurrentGuru();
      _siswa = await _authRepo.getCurrentSiswa();
      if (_guru != null) {
        _role = 'guru';
        _state = AuthState.authenticated;
      } else if (_siswa != null) {
        _role = 'siswa';
        _state = AuthState.authenticated;
      }
      notifyListeners();
    }
  }

  void _handleDioError(DioException e) {
    if (e.response?.statusCode == 401) {
      final responseData = e.response?.data;
      String message = 'NIS atau password salah. Silakan coba lagi.';
      if (responseData is Map && responseData.containsKey('message')) {
        message = responseData['message'];
      }
      _errorMessage = message;
      _state = AuthState.error;
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      _errorMessage = 'Koneksi timeout. Periksa server backend kamu.';
      _state = AuthState.error;
    } else if (e.type == DioExceptionType.connectionError) {
      _errorMessage =
          'Tidak bisa terhubung ke server. Pastikan backend berjalan.';
      _state = AuthState.error;
    } else {
      _errorMessage = 'Terjadi kesalahan. Coba lagi nanti.';
      _state = AuthState.error;
    }
    AppLogger.e('Login DioError', e);
    notifyListeners();
  }
}
