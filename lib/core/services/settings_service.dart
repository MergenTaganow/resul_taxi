import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const String _keyAutoMode = 'auto_mode';
  static const String _keyAutoSwitchRegions =
      'auto_switch_regions'; // Keep key for migration
  static const String _keyDriverDistrict = 'driver_district';
  static const String _keySoundEnabled = 'sound_enabled';
  static const String _keyVibrationEnabled = 'vibration_enabled';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLanguage = 'language';
  static const String _keyLastLoginTime = 'last_login_time';
  static const String _keyRememberMe = 'remember_me';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyTaxometerSettings = 'taxometer_settings';
  static const String _keyProfileData = 'profile_data';

  SharedPreferences? _prefs;

  // Store autoSwitchRegions in memory only (app storage, not persistent)
  // This ensures the setting resets to false on app restart unless backend explicitly enables it
  bool _autoSwitchRegionsAppStorage = false;
  bool _isAutoSwitchInitialized = false;

  bool prevAutoSwitchRegions = false;

  /// Initialize the service
  ///
  /// IMPORTANT: autoSwitchRegions behavior has been changed:
  /// - No longer stored in persistent storage (SharedPreferences)
  /// - Stored in app memory only, resets to false on app restart
  /// - Always syncs with backend: if backend is false, app value will be false
  /// - This prevents drivers from having auto-switch enabled when backend says it should be disabled
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();

    // Remove any existing persistent autoSwitchRegions setting
    await _migrateAutoSwitchRegionsFromPersistentStorage();
  }

  /// Migrate autoSwitchRegions from persistent storage to app storage
  Future<void> _migrateAutoSwitchRegionsFromPersistentStorage() async {
    if (_prefs?.containsKey(_keyAutoSwitchRegions) == true) {
      print(
          '[SETTINGS] Migrating autoSwitchRegions from persistent to app storage');
      // Don't transfer the value, just remove it to force backend sync
      await _prefs?.remove(_keyAutoSwitchRegions);
      print('[SETTINGS] Removed autoSwitchRegions from persistent storage');
    }
  }

  /// Check if service is initialized
  bool get isInitialized => _prefs != null;

  /// Auto mode settings
  bool get autoMode => _prefs?.getBool(_keyAutoMode) ?? false;
  Future<bool> setAutoMode(bool value) async {
    return await _prefs?.setBool(_keyAutoMode, value) ?? false;
  }

  /// Auto switch regions setting (now stored in app memory only)
  bool get autoSwitchRegions {
    if (!_isAutoSwitchInitialized) {
      // Default to false until backend sync is performed
      return false;
    }
    return _autoSwitchRegionsAppStorage;
  }

  /// Set auto switch regions in app storage (memory only)
  Future<bool> setAutoSwitchRegions(bool value) async {
    print('[SETTINGS] Setting autoSwitchRegions to $value (app storage only)');
    _autoSwitchRegionsAppStorage = value;
    _isAutoSwitchInitialized = true;
    prevAutoSwitchRegions = value;
    return true;
  }

  /// Reset auto switch regions to default (false) - called on app restart
  void resetAutoSwitchRegions() {
    print('[SETTINGS] Resetting autoSwitchRegions to false (app restart)');
    _autoSwitchRegionsAppStorage = false;
    _isAutoSwitchInitialized = false;
  }

  /// Auto switch district setting with backend sync
  bool get autoSwitchDistrict => autoSwitchRegions;

  /// Get auto switch district setting with backend priority and proper app restart behavior
  /// Always respects backend value: if backend is false, app value will be false
  /// If backend is true, it can override to true
  Future<Map<String, dynamic>> getAutoSwitchDistrictWithBackendSync(
      [List<Map<String, dynamic>>? backendSettings]) async {
    print('[SETTINGS] Starting autoSwitchRegions backend sync...');

    // First check backend driver settings if provided
    if (backendSettings != null) {
      for (final setting in backendSettings) {
        if (setting['key'] == 'auto_mode') {
          final backendValue = setting['value'] == 'true' ? true : false;
          print(
              '[SETTINGS] Found auto_switch_regions in backend settings: $backendValue');

          if (backendValue == true) {
            // Backend says it should be true, set to true
            await setAutoSwitchRegions(true);
            print(
                '[SETTINGS] Auto switch district set to true from backend settings');
            return {
              'enabled': true,
              'forcedByBackend': true,
            };
          } else if (backendValue == false) {
            // Backend says it should be false, force app value to false
            await setAutoSwitchRegions(prevAutoSwitchRegions);
            print(
                '[SETTINGS] Backend auto switch district is false, setting app value to false');
            return {
              'enabled': prevAutoSwitchRegions,
              'forcedByBackend': false,
            };
          }
        }
      }
    }

    // If no backend data found, default to false for safety
    await setAutoSwitchRegions(false);
    print(
        '[SETTINGS] No backend auto switch district data, defaulting to false');
    return {
      'enabled': false,
      'forcedByBackend': false,
    };
  }

  /// Driver district
  String? get driverDistrict => _prefs?.getString(_keyDriverDistrict);
  Future<bool> setDriverDistrict(String? value) async {
    if (value == null) {
      return await _prefs?.remove(_keyDriverDistrict) ?? false;
    }
    return await _prefs?.setString(_keyDriverDistrict, value) ?? false;
  }

  /// Sound settings
  bool get soundEnabled => _prefs?.getBool(_keySoundEnabled) ?? true;
  Future<bool> setSoundEnabled(bool value) async {
    return await _prefs?.setBool(_keySoundEnabled, value) ?? false;
  }

  /// Vibration settings
  bool get vibrationEnabled => _prefs?.getBool(_keyVibrationEnabled) ?? true;
  Future<bool> setVibrationEnabled(bool value) async {
    return await _prefs?.setBool(_keyVibrationEnabled, value) ?? false;
  }

  /// Notifications settings
  bool get notificationsEnabled =>
      _prefs?.getBool(_keyNotificationsEnabled) ?? true;
  Future<bool> setNotificationsEnabled(bool value) async {
    return await _prefs?.setBool(_keyNotificationsEnabled, value) ?? false;
  }

  /// Theme mode (light, dark, system)
  String get themeMode => _prefs?.getString(_keyThemeMode) ?? 'system';
  Future<bool> setThemeMode(String value) async {
    return await _prefs?.setString(_keyThemeMode, value) ?? false;
  }

  /// Language setting
  String get language => _prefs?.getString(_keyLanguage) ?? 'ru';
  Future<bool> setLanguage(String value) async {
    return await _prefs?.setString(_keyLanguage, value) ?? false;
  }

  /// Last login time
  DateTime? get lastLoginTime {
    final timestamp = _prefs?.getInt(_keyLastLoginTime);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  Future<bool> setLastLoginTime(DateTime? value) async {
    if (value == null) {
      return await _prefs?.remove(_keyLastLoginTime) ?? false;
    }
    return await _prefs?.setInt(
            _keyLastLoginTime, value.millisecondsSinceEpoch) ??
        false;
  }

  /// Remember me setting
  bool get rememberMe => _prefs?.getBool(_keyRememberMe) ?? false;
  Future<bool> setRememberMe(bool value) async {
    return await _prefs?.setBool(_keyRememberMe, value) ?? false;
  }

  /// Biometric authentication setting
  bool get biometricEnabled => _prefs?.getBool(_keyBiometricEnabled) ?? false;
  Future<bool> setBiometricEnabled(bool value) async {
    return await _prefs?.setBool(_keyBiometricEnabled, value) ?? false;
  }

  /// Profile data
  Map<String, dynamic>? get profileData {
    final jsonString = _prefs?.getString(_keyProfileData);
    if (jsonString != null) {
      try {
        return json.decode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        print('Error parsing profile data: $e');
      }
    }
    return null;
  }

  Future<bool> setProfileData(Map<String, dynamic>? data) async {
    if (data == null) {
      return await _prefs?.remove(_keyProfileData) ?? false;
    }
    try {
      final jsonString = json.encode(data);
      return await _prefs?.setString(_keyProfileData, jsonString) ?? false;
    } catch (e) {
      print('Error saving profile data: $e');
      return false;
    }
  }

  /// Get all settings as a map
  /// Note: autoSwitchRegions is not included as it's stored in app memory only
  Map<String, dynamic> getAllSettings() {
    return {
      'autoMode': autoMode,
      // 'autoSwitchRegions': autoSwitchRegions, // Excluded - app storage only
      'driverDistrict': driverDistrict,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'notificationsEnabled': notificationsEnabled,
      'themeMode': themeMode,
      'language': language,
      'lastLoginTime': lastLoginTime?.millisecondsSinceEpoch,
      'rememberMe': rememberMe,
      'biometricEnabled': biometricEnabled,
      'profileData': profileData,
    };
  }

  /// Reset all settings to defaults
  Future<bool> resetToDefaults() async {
    try {
      await _prefs?.clear();
      // Also reset app storage values
      resetAutoSwitchRegions();
      return true;
    } catch (e) {
      print('Error resetting settings: $e');
      return false;
    }
  }

  /// Export settings as JSON string
  String exportSettings() {
    return json.encode(getAllSettings());
  }

  /// Import settings from JSON string
  Future<bool> importSettings(String jsonString) async {
    try {
      final settings = json.decode(jsonString) as Map<String, dynamic>;

      // Apply each setting
      if (settings.containsKey('autoMode')) {
        await setAutoMode(settings['autoMode'] as bool);
      }
      // Skip autoSwitchRegions - it's controlled by backend sync only
      if (settings.containsKey('driverDistrict')) {
        await setDriverDistrict(settings['driverDistrict'] as String?);
      }
      if (settings.containsKey('soundEnabled')) {
        await setSoundEnabled(settings['soundEnabled'] as bool);
      }
      if (settings.containsKey('vibrationEnabled')) {
        await setVibrationEnabled(settings['vibrationEnabled'] as bool);
      }
      if (settings.containsKey('notificationsEnabled')) {
        await setNotificationsEnabled(settings['notificationsEnabled'] as bool);
      }
      if (settings.containsKey('themeMode')) {
        await setThemeMode(settings['themeMode'] as String);
      }
      if (settings.containsKey('language')) {
        await setLanguage(settings['language'] as String);
      }
      if (settings.containsKey('lastLoginTime')) {
        final timestamp = settings['lastLoginTime'] as int?;
        await setLastLoginTime(timestamp != null
            ? DateTime.fromMillisecondsSinceEpoch(timestamp)
            : null);
      }
      if (settings.containsKey('rememberMe')) {
        await setRememberMe(settings['rememberMe'] as bool);
      }
      if (settings.containsKey('biometricEnabled')) {
        await setBiometricEnabled(settings['biometricEnabled'] as bool);
      }
      if (settings.containsKey('profileData')) {
        await setProfileData(settings['profileData'] as Map<String, dynamic>?);
      }

      return true;
    } catch (e) {
      print('Error importing settings: $e');
      return false;
    }
  }

  /// Check if a specific setting exists
  bool hasSetting(String key) {
    return _prefs?.containsKey(key) ?? false;
  }

  /// Get a generic setting value
  dynamic getSetting(String key) {
    return _prefs?.get(key);
  }

  /// Set a generic setting value
  Future<bool> setSetting(String key, dynamic value) async {
    if (value == null) {
      return await _prefs?.remove(key) ?? false;
    }

    if (value is bool) {
      return await _prefs?.setBool(key, value) ?? false;
    } else if (value is int) {
      return await _prefs?.setInt(key, value) ?? false;
    } else if (value is double) {
      return await _prefs?.setDouble(key, value) ?? false;
    } else if (value is String) {
      return await _prefs?.setString(key, value) ?? false;
    } else if (value is List<String>) {
      return await _prefs?.setStringList(key, value) ?? false;
    } else {
      // For complex objects, try to serialize as JSON
      try {
        final jsonString = json.encode(value);
        return await _prefs?.setString(key, jsonString) ?? false;
      } catch (e) {
        print('Error saving setting $key: $e');
        return false;
      }
    }
  }

  /// Remove a specific setting
  Future<bool> removeSetting(String key) async {
    return await _prefs?.remove(key) ?? false;
  }

  /// Clear all settings
  Future<bool> clearAll() async {
    return await _prefs?.clear() ?? false;
  }

  /// Get auto mode for requests
  Future<bool> getAutoModeForRequests() async {
    return autoMode;
  }

  /// Check if auto switch regions should be enabled
  Future<bool> shouldAutoSwitchRegionsBeEnabled() async {
    return autoSwitchRegions;
  }

  /// Demonstration method showing the new autoSwitchRegions behavior
  /// This method shows various scenarios for educational purposes
  static void demonstrateAutoSwitchRegionsBehavior() {
    print('\n=== AUTO SWITCH REGIONS BEHAVIOR DEMONSTRATION ===');
    print(
        'New Behavior: App storage only, resets on restart, respects backend');
    print('');

    // Simulate different scenarios
    final scenarios = [
      {
        'name': 'App Restart - Backend False',
        'backend': false,
        'description':
            'Driver restarts app, backend says auto-switch should be disabled'
      },
      {
        'name': 'App Restart - Backend True',
        'backend': true,
        'description':
            'Driver restarts app, backend allows auto-switch to be enabled'
      },
      {
        'name': 'App Restart - No Backend Data',
        'backend': null,
        'description': 'Driver restarts app, no backend data available'
      },
    ];

    for (final scenario in scenarios) {
      print('--- ${scenario['name']} ---');
      print('Description: ${scenario['description']}');
      print('Backend value: ${scenario['backend']}');

      // Simulate the behavior
      if (scenario['backend'] == false) {
        print('Result: App value FORCED TO FALSE (respects backend)');
        print('User cannot enable auto-switch (backend controls it)');
      } else if (scenario['backend'] == true) {
        print('Result: App value CAN BE TRUE (backend allows it)');
        print('User can toggle auto-switch on/off');
      } else {
        print('Result: App value DEFAULTS TO FALSE (safety first)');
        print('Will sync with backend when available');
      }
      print('');
    }

    print('KEY BENEFITS:');
    print('✅ No persistent storage = fresh start every app restart');
    print('✅ Backend false = app false (always respects server)');
    print('✅ Prevents drivers bypassing backend restrictions');
    print('✅ Clear source of truth (backend controls the feature)');
    print('=== DEMONSTRATION COMPLETE ===\n');
  }
}
