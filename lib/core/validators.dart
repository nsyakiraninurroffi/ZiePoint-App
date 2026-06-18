class Validators {
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong.';
    }
    return null;
  }

  static String? minLength(String? value, int min, String fieldName) {
    if (value == null || value.trim().length < min) {
      return '$fieldName minimal $min karakter.';
    }
    return null;
  }

  static String? numericOnly(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return null;
    final numRegex = RegExp(r'^[0-9]+$');
    if (!numRegex.hasMatch(value.trim())) {
      return '$fieldName hanya boleh berisi angka.';
    }
    return null;
  }

  static String? email(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return null;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid.';
    }
    return null;
  }
}
