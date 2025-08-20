
abstract class AuthRepository {
  Future<String> login(String username, String password);
  Future<Map<String, dynamic>> getProfile();
  Future<void> logout();
  Future<bool> refreshToken();
  Future<void> setDutyStatus(String status);
  Future<void> registerDistrict(int districtId);
  Future<void> unregisterDistrict(int districtId);
  Future<List<Map<String, dynamic>>> getDriverSettings();
}
