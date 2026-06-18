import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/app_logger.dart';
import '../models/siswa_model.dart';
import '../repositories/student_repository.dart';

enum TeacherFormState { idle, loading, success, error }

class TeacherInputViewModel extends ChangeNotifier {
  final StudentRepository _studentRepo;
  TeacherInputViewModel(this._studentRepo);

  TeacherFormState _state = TeacherFormState.idle;
  String? _errorMessage;
  String? _successMessage;
  bool _isLoadingData = true;
  bool _isPelanggaran = true;

  List<Siswa> _siswaList = [];
  List<Map<String, dynamic>> _jenisList = [];
  String? _selectedSiswa;
  String? _selectedJenis;
  DateTime _selectedDate = DateTime.now();

  // Stats
  Map<String, dynamic>? _stats;
  bool _isLoadingStats = false;

  // All catatan for history tab
  List<Map<String, dynamic>> _allCatatan = [];
  bool _isLoadingCatatan = false;
  int _catatanPage = 1;
  bool _catatanHasMore = false;
  int _catatanTotal = 0;
  String? _catatanSearch;
  String? _catatanFilterTipe;

  // Getters
  TeacherFormState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isLoadingData => _isLoadingData;
  bool get isPelanggaran => _isPelanggaran;
  bool get isSaving => _state == TeacherFormState.loading;
  List<Siswa> get siswaList => _siswaList;
  List<Map<String, dynamic>> get jenisList => _jenisList;
  String? get selectedSiswa => _selectedSiswa;
  String? get selectedJenis => _selectedJenis;
  DateTime get selectedDate => _selectedDate;
  Map<String, dynamic>? get stats => _stats;
  bool get isLoadingStats => _isLoadingStats;
  List<Map<String, dynamic>> get allCatatan => _allCatatan;
  bool get isLoadingCatatan => _isLoadingCatatan;
  bool get catatanHasMore => _catatanHasMore;
  int get catatanTotal => _catatanTotal;

  void setSelectedSiswa(String? v) { _selectedSiswa = v; notifyListeners(); }
  void setSelectedJenis(String? v) { _selectedJenis = v; notifyListeners(); }
  void setSelectedDate(DateTime d) { _selectedDate = d; notifyListeners(); }

  Future<void> loadFormData() async {
    _isLoadingData = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _studentRepo.getSiswaList(),
        _studentRepo.getJenisCatatan(_isPelanggaran ? 'pelanggaran' : 'prestasi'),
      ]);
      _siswaList = (results[0]).map((s) => Siswa.fromJson(s)).toList();
      _jenisList = results[1];
      _isLoadingData = false;
      notifyListeners();
    } on DioException catch (e) {
      _isLoadingData = false;
      _errorMessage = _extractDioMessage(e);
      AppLogger.e('Load form data error', e);
      notifyListeners();
    } catch (e) {
      _isLoadingData = false;
      _errorMessage = 'Gagal memuat data: $e';
      notifyListeners();
    }
  }

  Future<void> loadTeacherStats() async {
    _isLoadingStats = true;
    notifyListeners();
    try {
      _stats = await _studentRepo.getTeacherStats();
    } catch (e) {
      AppLogger.e('Load stats error', e);
    }
    _isLoadingStats = false;
    notifyListeners();
  }

  Future<void> switchTipe(bool isPelanggaran) async {
    if (_isPelanggaran == isPelanggaran) return;
    _isPelanggaran = isPelanggaran;
    _selectedJenis = null;
    notifyListeners();

    try {
      _jenisList = await _studentRepo.getJenisCatatan(isPelanggaran ? 'pelanggaran' : 'prestasi');
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memuat jenis catatan.';
      AppLogger.e('Switch tipe error', e);
      notifyListeners();
    }
  }

  Future<bool> saveCatatan({required int idGuru, required String keterangan}) async {
    if (_selectedSiswa == null || _selectedJenis == null) {
      _errorMessage = 'Pilih siswa dan jenis catatan terlebih dahulu.';
      notifyListeners();
      return false;
    }

    _state = TeacherFormState.loading;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _studentRepo.saveViolation(
        idGuru,
        int.parse(_selectedSiswa!),
        int.parse(_selectedJenis!),
        _selectedDate.toString().split(' ')[0],
        keterangan,
      );
      _state = TeacherFormState.success;
      _successMessage = 'Catatan berhasil disimpan!';
      _selectedSiswa = null;
      _selectedJenis = null;
      _selectedDate = DateTime.now();
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _state = TeacherFormState.error;
      _errorMessage = _extractDioMessage(e);
      notifyListeners();
      return false;
    } catch (e) {
      _state = TeacherFormState.error;
      _errorMessage = 'Gagal menyimpan: $e';
      notifyListeners();
      return false;
    }
  }

  // ── History Management ─────────────────────

  Future<void> loadAllCatatan({bool refresh = false}) async {
    if (refresh) { _catatanPage = 1; _allCatatan = []; }
    _isLoadingCatatan = true;
    notifyListeners();

    try {
      final result = await _studentRepo.getAllCatatan(
        page: _catatanPage, limit: 20,
        search: _catatanSearch, tipe: _catatanFilterTipe,
      );
      final data = result['data'] as List;
      final pagination = result['pagination'] as Map<String, dynamic>;

      if (refresh || _catatanPage == 1) {
        _allCatatan = List<Map<String, dynamic>>.from(data);
      } else {
        _allCatatan.addAll(List<Map<String, dynamic>>.from(data));
      }
      _catatanHasMore = pagination['hasMore'] ?? false;
      _catatanTotal = pagination['total'] ?? 0;
    } catch (e) {
      _errorMessage = 'Gagal memuat riwayat: $e';
      AppLogger.e('Load catatan error', e);
    }
    _isLoadingCatatan = false;
    notifyListeners();
  }

  Future<void> loadMoreCatatan() async {
    if (!_catatanHasMore || _isLoadingCatatan) return;
    _catatanPage++;
    await loadAllCatatan();
  }

  void setCatatanSearch(String? search) {
    _catatanSearch = search;
    loadAllCatatan(refresh: true);
  }

  void setCatatanFilter(String? tipe) {
    _catatanFilterTipe = tipe;
    loadAllCatatan(refresh: true);
  }

  Future<bool> updateCatatan(int idCatatan, {required int idSiswa, required int idJenis, required String tanggal, required String keterangan}) async {
    try {
      await _studentRepo.updateCatatan(idCatatan, idSiswa: idSiswa, idJenis: idJenis, tanggal: tanggal, keterangan: keterangan);
      await loadAllCatatan(refresh: true);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengupdate catatan: $e';
      AppLogger.e('Update catatan error', e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCatatan(int idCatatan) async {
    try {
      await _studentRepo.deleteCatatan(idCatatan);
      _allCatatan.removeWhere((c) => c['id_catatan'] == idCatatan);
      _catatanTotal--;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus catatan: $e';
      AppLogger.e('Delete catatan error', e);
      notifyListeners();
      return false;
    }
  }

  void resetState() {
    _state = TeacherFormState.idle;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  String _extractDioMessage(DioException e) {
    if (e.response?.data is Map) {
      return e.response?.data['message'] ?? 'Terjadi kesalahan server.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Tidak dapat terhubung ke server.';
    }
    return 'Koneksi gagal.';
  }
}
