import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // In-memory access token is the source of truth for sync checks
  String? _accessToken;
  String? _userRole;

  static const String _refreshTokenKey = 'refresh_token';
  static const String _userRoleKey = 'user_role';

  bool get isAuthenticated => _accessToken != null;
  String? get accessToken => _accessToken;
  String? get userRole => _userRole;

  // Call this on app startup to restore session from secure storage
  Future<void> restoreSession() async {
    // Actually our access token is meant to be in memory or refresh token fetched
    // We will read access_token if it was stored or just read userRole
    // The user's FIX 1 says we store access_token in secure storage. 
    // In my previous version, I only stored refresh_token. I'll follow the user's FIX 1.
    _accessToken = await _storage.read(key: 'access_token');
    _userRole = await _storage.read(key: _userRoleKey);
    // Also keep refresh token for Dio refresh logic
  }

  Future<void> saveTokens({
    required String accessToken,
    required String role,
    String? refreshToken, // Keep this for backward compatibility with my implementation
  }) async {
    _accessToken = accessToken;   // set memory FIRST
    _userRole = role;
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: _userRoleKey, value: role);
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  Future<void> setAccessToken(String token) async {
    _accessToken = token;
    await _storage.write(key: 'access_token', value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _userRole = null;
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: _userRoleKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
