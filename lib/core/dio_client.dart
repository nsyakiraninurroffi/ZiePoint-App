import 'package:dio/dio.dart';
import '../services/token_manager.dart';
import 'env.dart';
import 'app_logger.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late Dio dio;
  final TokenManager _tokenManager = TokenManager();

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: '${Env.baseUrl}/api',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (!options.path.contains('/login')) {
            final token = _tokenManager.accessToken;
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          AppLogger.d('➡️ Request: ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.d(
            '✅ Response: ${response.statusCode} ${response.requestOptions.uri}',
          );
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          AppLogger.e(
            '❌ Error: ${e.response?.statusCode} ${e.requestOptions.uri}',
            e,
          );

          // Handle 401 Unauthorized for token refresh
          if (e.response?.statusCode == 401 &&
              !e.requestOptions.path.contains('/refresh') &&
              !e.requestOptions.path.contains('/login')) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retry the original request
              try {
                final token = _tokenManager.accessToken;
                final opts = Options(
                  method: e.requestOptions.method,
                  headers: {
                    ...e.requestOptions.headers,
                    'Authorization': 'Bearer $token',
                  },
                );
                final cloneReq = await dio.request(
                  e.requestOptions.path,
                  options: opts,
                  data: e.requestOptions.data,
                  queryParameters: e.requestOptions.queryParameters,
                );
                return handler.resolve(cloneReq);
              } catch (retryError) {
                return handler.next(e);
              }
            } else {
              // Refresh failed, clear tokens (Router will handle redirection)
              await _tokenManager.clearTokens();
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await _tokenManager.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      AppLogger.d('🔄 Attempting token refresh...');
      // Using a separate Dio instance to avoid infinite loops
      final refreshDio = Dio(BaseOptions(baseUrl: '${Env.baseUrl}/api'));
      final response = await refreshDio.post(
        '/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final newToken = response.data['token'];
        await _tokenManager.setAccessToken(newToken);
        AppLogger.d('✅ Token refresh successful');
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.e('❌ Token refresh failed', e);
      return false;
    }
  }
}
