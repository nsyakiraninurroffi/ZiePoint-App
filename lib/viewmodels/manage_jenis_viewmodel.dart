import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/app_logger.dart';
import '../repositories/student_repository.dart';

enum ManageJenisState { idle, loading, error }

class ManageJenisViewModel extends ChangeNotifier {
  final StudentRepository _repository;

  ManageJenisViewModel(this._repository);

  ManageJenisState _state = ManageJenisState.idle;
  String? _errorMessage;
  List<Map<String, dynamic>> _jenisList = [];
  bool _isLoading = false;

  ManageJenisState get state => _state;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get jenisList => _jenisList;
  bool get isLoading => _isLoading;

  Future<void> loadJenisCatatan() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _jenisList = await _repository.getAllJenisCatatan();
      _state = ManageJenisState.idle;
    } catch (e) {
      _errorMessage = 'Gagal memuat jenis catatan: $e';
      _state = ManageJenisState.error;
      AppLogger.e('Load jenis catatan error', e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createJenisCatatan({required String nama, required int poin, required String tipe}) async {
    try {
      await _repository.createJenisCatatan(nama: nama, poin: poin, tipe: tipe);
      await loadJenisCatatan();
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  Future<bool> updateJenisCatatan(int idJenis, {required String nama, required int poin, required String tipe}) async {
    try {
      await _repository.updateJenisCatatan(idJenis, nama: nama, poin: poin, tipe: tipe);
      await loadJenisCatatan();
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  Future<bool> deleteJenisCatatan(int idJenis) async {
    try {
      await _repository.deleteJenisCatatan(idJenis);
      _jenisList.removeWhere((j) => j['id_jenis'] == idJenis);
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
         _errorMessage = e.response?.data['message'] ?? 'Data masih digunakan, tidak dapat dihapus.';
      } else {
        _errorMessage = e.response?.data['message'] ?? 'Terjadi kesalahan server.';
      }
    } else {
      _errorMessage = 'Terjadi kesalahan: $e';
    }
    _state = ManageJenisState.error;
    AppLogger.e('Manage Jenis Error', e);
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _state = ManageJenisState.idle;
    notifyListeners();
  }
}
