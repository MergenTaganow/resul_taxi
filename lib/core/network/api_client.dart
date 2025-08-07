import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:taxi_service/domain/entities/commute_type.dart';

class ApiClient {
  late final Dio _dio;
  String? _authToken;
  String? _refreshToken;
  Function(String)? _onTokenRefreshed;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        // baseUrl: 'http://46.173.17.202:9091',
        baseUrl: 'http://46.173.17.202:9091',
        contentType: 'application/json',
      ),
    );

    // Allow self-signed SSL certificates (for development only!)
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };

    // Logging interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('[DIO REQUEST] => ${options.method} ${options.uri}');
          print('[DIO REQUEST DATA] => ${options.data}');
          print('[DIO REQUEST HEADERS] => ${options.headers}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
              '[DIO RESPONSE] => ${response.statusCode} ${response.requestOptions.uri}');
          print('[DIO RESPONSE DATA] => ${response.data}');
          return handler.next(response);
        },
        onError: (DioError error, handler) {
          print(
              '[DIO ERROR] => ${error.response?.statusCode} ${error.requestOptions.uri}');
          print('[DIO ERROR DATA] => ${error.response?.data}');
          return handler.next(error);
        },
      ),
    );

    // Auth/refresh interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          print('[DIO REQUEST HEADERS] => ${options.headers}');
          return handler.next(options);
        },
        onError: (DioError error, handler) async {
          if (error.response?.statusCode == 401 && _refreshToken != null) {
            final refreshed = await _refreshAccessToken();
            if (refreshed) {
              // Retry the original request with new token
              final opts = error.requestOptions;
              opts.headers['Authorization'] = 'Bearer $_authToken';
              try {
                final cloneReq = await _dio.fetch(opts);
                return handler.resolve(cloneReq);
              } catch (e) {
                return handler.reject(error);
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
    _loadTokens();
  }

  Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
    _authToken = accessToken;
    _refreshToken = refreshToken;
  }

  void setAuthToken(String token) {
    _authToken = token;
  }

  Future<Response> login(String username, String password) async {
    final response = await _dio.post('/api/v1/authentication/driver/login',
        data: {'username': username, 'password': password});
    final payload = response.data['payload'];
    final tokens = payload['tokens'];
    final accessToken = tokens['access']['token'];
    final refreshToken = tokens['refresh'];
    await _saveTokens(accessToken, refreshToken);
    return response;
  }

  Future<bool> _refreshAccessToken() async {
    try {
      final response = await _dio.post(
        '/api/v1/authentication/driver/change-token',
        data: {'token': _refreshToken},
      );
      final newAccessToken = response.data['payload']?['token'];
      if (newAccessToken != null) {
        await _saveTokens(newAccessToken, _refreshToken!);

        // Notify listeners that token has been refreshed
        if (_onTokenRefreshed != null) {
          _onTokenRefreshed!(newAccessToken);
        }

        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<Response> sendAppeal(String message) async {
    if (_authToken == null) {
      await _loadTokens();
    }
    return _dio.post('/api/v1/driver-app/appeal', data: {'note': message});
  }

  Future<Response> getProfile() async {
    if (_authToken == null) {
      await _loadTokens();
    }
    return _dio.get('/api/v1/driver-app/drivers/profile');
  }

  Future<Response> updateOrderStatus(String orderId, String status) async {
    return _dio.patch(
      '/orders/$orderId/status',
      data: {'status': status},
    );
  }

  // Patch driver duty status
  Future<Response> setDriverDutyStatus(String status) async {
    return _dio.patch(
      '/api/v1/driver-app/drivers/$status',
    );
  }

  // Register a district for the driver
  Future<Response> registerDistrict(int districtId) async {
    return _dio.post(
      '/api/v1/driver-app/drivers/register-district',
      data: {'district_id': districtId},
    );
  }

  // Unregister a district for the driver
  Future<Response> unregisterDistrict(int districtId) async {
    return _dio.delete(
      '/api/v1/driver-app/drivers/${districtId}/districts',
    );
  }

  Future<void> deleteTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    _authToken = null;
    _refreshToken = null;
  }

  Future<List<dynamic>> getDistricts() async {
    final response = await _dio.get('/api/v1/driver-app/districts');
    return response.data['payload'] is List
        ? response.data['payload']
        : [response.data['payload']];
  }

  Future<List<dynamic>> getAvailableOrders(int districtId,
      {int page = 1, int limit = 20}) async {
    final response = await _dio.get(
        '/api/v1/driver-app/requests/free-from-driver?limit=$limit&page=$page&order_direction=desc&order_by=id&district_id=$districtId');
    return response.data['payload'] is List
        ? response.data['payload']
        : [response.data['payload']];
  }

  Future<Map<String, dynamic>> getFreeRequestsCount(int districtId) async {
    final response = await _dio.get(
        '/api/v1/driver-app/requests/free-from-driver?limit=1&page=1&order_direction=desc&order_by=id&district_id=$districtId');
    return {
      'count': response.data['meta']?['total'] ?? 0,
      'district_id': districtId,
    };
  }

  // Method to set token refresh callback
  void setTokenRefreshCallback(Function(String) callback) {
    _onTokenRefreshed = callback;
  }

  // Method to get current auth token
  String? get authToken => _authToken;

  // Method to manually refresh token (for testing)
  Future<bool> refreshToken() async {
    return await _refreshAccessToken();
  }

  // Fetch driver settings
  Future<List<dynamic>> getDriverSettings() async {
    final response = await _dio.get('/api/v1/driver/settings');
    return response.data['payload'] is List
        ? response.data['payload']
        : [response.data['payload']];
  }

  Future<List<CommuteType>> getCommuteTypes() async {
    final response = await _dio.get('/api/v1/driver/settings/commutes');
    final payload = response.data['payload'] as List<dynamic>;
    return payload
        .map((e) => CommuteType.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> acceptOrder(int orderId, {String? commuteTime}) async {
    final data = {};
    if (commuteTime != null) {
      data['commute_time'] = commuteTime;
    }
    await _dio.patch(
      '/api/v1/driver-app/requests/accept/$orderId',
      data: data,
    );
  }

  Future<void> startOrder(String orderId, int startTimeMillis) async {
    await _dio.patch(
      '/api/v1/driver-app/requests/start/$orderId',
      data: {'start_time': startTimeMillis},
    );
  }

  Future<Response> completeOrder({
    required int requestId,
    required double priceTotal,
    required List<Map<String, dynamic>> roadDetails,
  }) async {
    return _dio.patch(
      '/api/v1/driver-app/requests/complete',
      data: {
        'request_id': requestId,
        'price_total': priceTotal,
        'road_details': roadDetails,
      },
    );
  }

  Future<Map<String, dynamic>> getRegionTariffs(int tarrifId) async {
    final response = await _dio.get('/api/v1/driver-app/tarrifs/$tarrifId');
    return response.data['payload'];
  }

  Future<List<dynamic>> getMessages() async {
    final lastThreeDays = DateTime.now()
        .subtract(Duration(days: 3, hours: 1))
        .millisecondsSinceEpoch;
    final response = await _dio.get(
        '/api/v1/driver-app/chats?limit=100&page=0&order_direction=desc&order_by=id&min_created_at=$lastThreeDays');

    return response.data['payload'] is List
        ? response.data['payload']
        : [response.data['payload']];
  }

  Future<List<dynamic>> getNotifications() async {
    final lastThreeDays = DateTime.now()
        .subtract(Duration(days: 3, hours: 1))
        .millisecondsSinceEpoch;
    final response = await _dio.get(
        '/api/v1/driver-app/notifications?limit=100&page=0&order_direction=desc&order_by=id&min_created_at=$lastThreeDays');
    return response.data['payload'] is List
        ? response.data['payload']
        : [response.data['payload']];
  }

  Future<List<dynamic>> getDriverPayments(
      {int limit = 20, int page = 1}) async {
    final response = await _dio.get(
        '/api/v1/driver-app/payments?limit=$limit&page=$page&order_direction=desc&order_by=id');
    return response.data['payload'] is List
        ? response.data['payload']
        : [response.data['payload']];
  }

  Future<List<dynamic>> getDriverStatistics(
      {int limit = 20, int page = 1}) async {
    final response = await _dio.get(
        '/api/v1/driver-app/requests/statistics?limit=$limit&page=$page&order_direction=desc&order_by=id');
    return response.data['payload'] is List
        ? response.data['payload']
        : [response.data['payload']];
  }

  // Fetch cars list for a specific district
  Future<List<dynamic>> getDistrictCars(
    int districtId, {
    int limit = 20,
    int page = 1,
    String orderDirection = 'desc',
    String orderBy = 'queue_number',
  }) async {
    final response = await _dio.get(
      '/api/v1/driver-app/drivers/districts',
      queryParameters: {
        'limit': limit,
        'page': page,
        'order_direction': orderDirection,
        'order_by': orderBy,
        'district_id': districtId,
      },
    );
    return response.data['payload'] is List
        ? response.data['payload']
        : [response.data['payload']];
  }
}
