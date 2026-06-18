import 'package:hive_flutter/hive_flutter.dart';
import '../models/siswa_model.dart';
import '../models/catatan_model.dart';
import '../models/guru_model.dart';

class LocalDb {
  static const String siswaBox = 'siswa_box';
  static const String catatanBox = 'catatan_box';
  static const String guruBox = 'guru_box';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(SiswaAdapter());
    Hive.registerAdapter(CatatanAdapter());
    Hive.registerAdapter(RiwayatSummaryAdapter());
    Hive.registerAdapter(GuruAdapter());

    // Open Boxes
    await Hive.openBox<Siswa>(siswaBox);
    await Hive.openBox(catatanBox);
    await Hive.openBox<Guru>(guruBox);
  }

  static Box<Siswa> getSiswaBox() => Hive.box<Siswa>(siswaBox);
  static Box getCatatanBox() => Hive.box(catatanBox);
  static Box<Guru> getGuruBox() => Hive.box<Guru>(guruBox);
}
