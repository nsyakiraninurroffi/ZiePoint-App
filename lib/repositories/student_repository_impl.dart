import 'package:dio/dio.dart';
import '../core/dio_client.dart';
import '../core/local_db.dart';
import '../core/app_logger.dart';
import '../models/catatan_model.dart';
import '../models/siswa_model.dart';
import 'student_repository.dart';

class StudentRepositoryImpl implements StudentRepository {
  final Dio _dio = DioClient().dio;

  @override
  Future<Siswa> getStudentProfile() async {
    final cached = LocalDb.getSiswaBox().get('current');
    try {
      final response = await _dio.get('/siswa/profil');
      final siswa = Siswa.fromJson(response.data);
      await LocalDb.getSiswaBox().put('current', siswa);
      return siswa;
    } catch (e) {
      AppLogger.w('Using cached profile: $e');
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getViolationHistory({int page = 1, int limit = 10}) async {
    final cacheKey = 'riwayat_page_$page';
    try {
      final response = await _dio.get('/siswa/riwayat', queryParameters: {'page': page, 'limit': limit});
      final data = response.data;
      final riwayat = (data['riwayat'] as List).map((e) => Catatan.fromJson(e)).toList();
      final summary = RiwayatSummary.fromJson(data['summary']);
      final pagination = data['pagination'];

      if (page == 1) {
        await LocalDb.getCatatanBox().put('summary', {
          'total_pelanggaran': summary.totalPelanggaran,
          'total_prestasi': summary.totalPrestasi,
          'total_poin': summary.totalPoin,
        });
        await LocalDb.getCatatanBox().put(cacheKey,
          riwayat.map((c) => {
            'id_catatan': c.idCatatan,
            'tanggal': c.tanggal,
            'keterangan': c.keterangan,
            'nama_jenis': c.namaJenis,
            'poin': c.poin,
            'tipe': c.tipe,
            'nama_guru': c.namaGuru,
          }).toList(),
        );
      }

      return {
        'riwayat': riwayat,
        'summary': summary,
        'hasMore': pagination['hasMore'] ?? false,
        'currentPage': pagination['currentPage'] ?? 1,
        'totalPages': pagination['totalPages'] ?? 1,
      };
    } catch (e) {
      AppLogger.w('Trying cached riwayat: $e');
      if (page == 1) {
        final cachedList = LocalDb.getCatatanBox().get(cacheKey);
        final cachedSummary = LocalDb.getCatatanBox().get('summary');
        if (cachedList != null && cachedSummary != null) {
          return {
            'riwayat': (cachedList as List).map((e) => Catatan.fromJson(Map<String, dynamic>.from(e))).toList(),
            'summary': RiwayatSummary.fromJson(Map<String, dynamic>.from(cachedSummary)),
            'hasMore': false, 'currentPage': 1, 'totalPages': 1,
          };
        }
      }
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSiswaList() async {
    final response = await _dio.get('/siswa');
    return List<Map<String, dynamic>>.from(response.data);
  }

  @override
  Future<List<Map<String, dynamic>>> getJenisCatatan(String tipe) async {
    final response = await _dio.get('/jenis_catatan/$tipe');
    return List<Map<String, dynamic>>.from(response.data);
  }

  @override
  Future<void> saveViolation(int idGuru, int idSiswa, int idJenis, String tanggal, String keterangan) async {
    await _dio.post('/catatan_siswa', data: {
      'id_guru': idGuru, 'id_siswa': idSiswa, 'id_jenis': idJenis,
      'tanggal': tanggal, 'keterangan': keterangan,
    });
  }

  // ── CRUD Catatan ───────────────────────────
  @override
  Future<Map<String, dynamic>> getAllCatatan({int page = 1, int limit = 50, String? search, String? tipe, int? idSiswa}) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (tipe != null && tipe.isNotEmpty) params['tipe'] = tipe;
    if (idSiswa != null) params['id_siswa'] = idSiswa;
    final response = await _dio.get('/catatan_siswa', queryParameters: params);
    return Map<String, dynamic>.from(response.data);
  }

  @override
  Future<void> updateCatatan(int idCatatan, {required int idSiswa, required int idJenis, required String tanggal, required String keterangan}) async {
    await _dio.put('/catatan_siswa/$idCatatan', data: {
      'id_siswa': idSiswa, 'id_jenis': idJenis, 'tanggal': tanggal, 'keterangan': keterangan,
    });
  }

  @override
  Future<void> deleteCatatan(int idCatatan) async {
    await _dio.delete('/catatan_siswa/$idCatatan');
  }

  // ── CRUD Siswa ─────────────────────────────
  @override
  Future<void> createSiswa({required String nama, required String nis, required String kelas}) async {
    await _dio.post('/siswa', data: {'nama': nama, 'nis': nis, 'kelas': kelas});
  }

  @override
  Future<void> updateSiswa(int idSiswa, {required String nama, required String nis, required String kelas}) async {
    await _dio.put('/siswa/$idSiswa', data: {'nama': nama, 'nis': nis, 'kelas': kelas});
  }

  @override
  Future<void> deleteSiswa(int idSiswa) async {
    await _dio.delete('/siswa/$idSiswa');
  }

  // ── CRUD Jenis Catatan ─────────────────────
  @override
  Future<List<Map<String, dynamic>>> getAllJenisCatatan() async {
    final response = await _dio.get('/jenis_catatan/all');
    return List<Map<String, dynamic>>.from(response.data);
  }

  @override
  Future<void> createJenisCatatan({required String nama, required int poin, required String tipe}) async {
    await _dio.post('/jenis_catatan', data: {'nama': nama, 'poin': poin, 'tipe': tipe});
  }

  @override
  Future<void> updateJenisCatatan(int idJenis, {required String nama, required int poin, required String tipe}) async {
    await _dio.put('/jenis_catatan/$idJenis', data: {'nama': nama, 'poin': poin, 'tipe': tipe});
  }

  @override
  Future<void> deleteJenisCatatan(int idJenis) async {
    await _dio.delete('/jenis_catatan/$idJenis');
  }

  // ── Stats & Leaderboard ────────────────────
  @override
  Future<Map<String, dynamic>> getTeacherStats() async {
    final response = await _dio.get('/stats/guru');
    return Map<String, dynamic>.from(response.data);
  }

  @override
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 5}) async {
    final response = await _dio.get('/siswa/leaderboard', queryParameters: {'limit': limit});
    return List<Map<String, dynamic>>.from(response.data);
  }
}
