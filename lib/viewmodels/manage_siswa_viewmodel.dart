import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/app_logger.dart';
import '../repositories/student_repository.dart';

enum ManageSiswaState { idle, loading, error }

class ManageSiswaViewModel extends ChangeNotifier {
  final StudentRepository _repository;

  ManageSiswaViewModel(this._repository);

  ManageSiswaState _state = ManageSiswaState.idle;
  String? _errorMessage;
  List<Map<String, dynamic>> _siswaList = [];
  bool _isLoading = false;

  ManageSiswaState get state => _state;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get siswaList => _siswaList;
  bool get isLoading => _isLoading;

  Future<void> loadSiswa() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _siswaList = await _repository.getSiswaList();
      _state = ManageSiswaState.idle;
    } catch (e) {
      _errorMessage = 'Gagal memuat data siswa: $e';
      _state = ManageSiswaState.error;
      AppLogger.e('Load siswa error', e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createSiswa({required String nama, required String nis, required String kelas}) async {
    try {
      await _repository.createSiswa(nama: nama, nis: nis, kelas: kelas);
      await loadSiswa();
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  Future<bool> updateSiswa(int idSiswa, {required String nama, required String nis, required String kelas}) async {
    try {
      await _repository.updateSiswa(idSiswa, nama: nama, nis: nis, kelas: kelas);
      await loadSiswa();
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  Future<bool> deleteSiswa(int idSiswa) async {
    try {
      await _repository.deleteSiswa(idSiswa);
      _siswaList.removeWhere((s) => s['id'] == idSiswa || s['id_siswa'] == idSiswa);
      notifyListeners();
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  void _handleError(dynamic e) {
    if (e is DioException) {
      if (e.response?.statusCode == 409) {
         _errorMessage = e.response?.data['message'] ?? 'Data konflik atau sudah ada.';
      } else {
        _errorMessage = e.response?.data['message'] ?? 'Terjadi kesalahan server.';
      }
    } else {
      _errorMessage = 'Terjadi kesalahan: $e';
    }
    _state = ManageSiswaState.error;
    AppLogger.e('Manage Siswa Error', e);
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _state = ManageSiswaState.idle;
    notifyListeners();
  }
}
