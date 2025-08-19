import 'package:taxi_service/core/network/api_client.dart';
import 'package:taxi_service/core/network/socket_client.dart';
import 'package:taxi_service/domain/entities/driver.dart';
import 'package:taxi_service/domain/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxi_service/core/services/profile_service.dart';
import 'package:taxi_service/core/services/location_district_service.dart';
import 'package:taxi_service/core/di/injection.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final SocketClient _socketClient;

  AuthRepositoryImpl(this._apiClient, this._socketClient);

  @override
  Future<String> login(String username, String password) async {
    final response = await _apiClient.login(username, password);
    final payload = response.data['payload'];
    final tokens = payload['tokens'];
    final accessToken = tokens['access']['token'];
    final refreshToken = tokens['refresh'];
    // Save driver and vehicle data
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('driver_id', payload['id'].toString());
    await prefs.setString('first_name', payload['first_name'] ?? '');
    await prefs.setString('last_name', payload['last_name'] ?? '');
    await prefs.setString('vehicle_type', payload['vehicle_type'] ?? '');
    await prefs.setString('vehicle_number', payload['vehicle_number'] ?? '');
    // Set auth token in socket client
    _socketClient.setAuthToken(accessToken);
    // Tokens are already saved in ApiClient
    return accessToken;
  }

  @override
  Future<void> logout() async {
    await _apiClient.deleteTokens();
    _socketClient.disconnect();

    // Clear profile service data
    final profileService = getIt<ProfileService>();
    await profileService.clearProfile();
  }

  @override
  Future<bool> refreshToken() async {
    return await _apiClient.refreshToken();
  }

  @override
  Future<Map<String, dynamic>> getProfile() async {
    // try {
      final response = await _apiClient.getProfile();
      print(response.data);
      final profileData = response.data['payload'] as Map<String, dynamic>;

      // If profile fetch is successful, ensure socket is connected with current token
      final currentToken = _apiClient.authToken;
      if (currentToken != null) {
        _socketClient.setAuthToken(currentToken);
      }

      // Switch to on_duty after getting profile
      await setDutyStatus('on_duty');

      // Update profile service with new data
      final profileService = getIt<ProfileService>();
      await profileService.updateProfileData(profileData);

      // Fetch districts after profile is loaded
      final locationDistrictService = getIt<LocationDistrictService>();
      await locationDistrictService.fetchDistrictsWhenAuthenticated();

      return profileData;
    // } catch (e) {
    //   return {};
    // }
  }

  // Method to initialize socket connection for already authenticated user
  Future<void> initializeSocketConnection() async {
    final currentToken = _apiClient.authToken;
    if (currentToken != null) {
      _socketClient.setAuthToken(currentToken);
    }
  }

  @override
  Future<void> setDutyStatus(String status) async {
    await _apiClient.setDriverDutyStatus(status);
  }

  @override
  Future<void> registerDistrict(int districtId) async {
    await _apiClient.registerDistrict(districtId);
  }

  @override
  Future<void> unregisterDistrict(int districtId) async {
    await _apiClient.unregisterDistrict(districtId);
  }

  @override
  Future<List<Map<String, dynamic>>> getDriverSettings() async {
    final settings = await _apiClient.getDriverSettings();
    // Ensure each item is a Map<String, dynamic>
    return settings.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
