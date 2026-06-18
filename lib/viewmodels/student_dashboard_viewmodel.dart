import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/app_logger.dart';
import '../models/catatan_model.dart';
import '../models/siswa_model.dart';
import '../repositories/student_repository.dart';

enum DashboardState { idle, loading, loadingMore, loaded, error, empty }

class StudentDashboardViewModel extends ChangeNotifier {
  final StudentRepository _studentRepo;

  StudentDashboardViewModel(this._studentRepo);

  DashboardState _state = DashboardState.idle;
  String? _errorMessage;
  Siswa? _profile;
  RiwayatSummary? _summary;
  List<Catatan> _riwayat = [];
  List<Map<String, dynamic>> _leaderboard = [];
  int _currentPage = 1;
  bool _hasMore = false;

  // Getters
  DashboardState get state => _state;
  String? get errorMessage => _errorMessage;
  Siswa? get profile => _profile;
  RiwayatSummary? get summary => _summary;
  List<Catatan> get riwayat => _riwayat;
  List<Map<String, dynamic>> get leaderboard => _leaderboard;
  bool get hasMore => _hasMore;
  bool get isLoading => _state == DashboardState.loading;
  bool get isLoadingMore => _state == DashboardState.loadingMore;

  Future<void> loadDashboard() async {
    _state = DashboardState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch profile and first page of history concurrently
      final results = await Future.wait([
        _studentRepo.getStudentProfile(),
        _studentRepo.getViolationHistory(page: 1, limit: 10),
        _studentRepo.getLeaderboard(limit: 5),
      ]);

      _profile = results[0] as Siswa;
      final historyData = results[1] as Map<String, dynamic>;
      _leaderboard = results[2] as List<Map<String, dynamic>>;
      _riwayat = historyData['riwayat'] as List<Catatan>;
      _summary = historyData['summary'] as RiwayatSummary;
      _hasMore = historyData['hasMore'] as bool;
      _currentPage = 1;

      _state = _riwayat.isEmpty ? DashboardState.empty : DashboardState.loaded;
      notifyListeners();
    } on DioException catch (e) {
      _handleError(e);
    } catch (e) {
      _errorMessage = 'Gagal memuat data: ${e.toString()}';
      _state = DashboardState.error;
      AppLogger.e('Dashboard load error', e);
      notifyListeners();
    }
  }

  Future<void> fetchNextPage() async {
    if (!_hasMore || _state == DashboardState.loadingMore) return;

    _state = DashboardState.loadingMore;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final historyData = await _studentRepo.getViolationHistory(
        page: nextPage,
        limit: 10,
      );

      final newItems = historyData['riwayat'] as List<Catatan>;
      _riwayat = [..._riwayat, ...newItems];
      _hasMore = historyData['hasMore'] as bool;
      _currentPage = nextPage;
      _state = DashboardState.loaded;
      notifyListeners();
    } on DioException catch (e) {
      _state = DashboardState.loaded; // Revert to loaded so list stays visible
      _handleError(e, showState: false);
    } catch (e) {
      _state = DashboardState.loaded;
      AppLogger.e('Fetch next page error', e);
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _currentPage = 1;
    _riwayat = [];
    _hasMore = false;
    await loadDashboard();
  }

  void _handleError(DioException e, {bool showState = true}) {
    if (e.response != null) {
      final msg = e.response?.data;
      _errorMessage = (msg is Map)
          ? msg['message'] ?? 'Terjadi kesalahan.'
          : 'Terjadi kesalahan.';
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      _errorMessage = 'Tidak dapat terhubung ke server.';
    } else {
      _errorMessage = 'Koneksi gagal.';
    }
    if (showState) _state = DashboardState.error;
    AppLogger.e('Dashboard DioError', e);
    notifyListeners();
  }
}
