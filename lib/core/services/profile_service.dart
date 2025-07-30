import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxi_service/domain/repositories/auth_repository.dart';
import 'package:taxi_service/core/di/injection.dart';
import 'package:taxi_service/core/services/settings_service.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  Map<String, dynamic>? _profileData;
  double _balance = 0.0;
  bool _isLoading = false;
  DateTime? _lastProfileFetch;

  // Stream controller for balance updates
  final StreamController<double> _balanceController =
      StreamController<double>.broadcast();

  // Getters
  Map<String, dynamic>? get profileData => _profileData;
  double get balance => _balance;
  bool get isLoading => _isLoading;
  Stream<double> get balanceStream => _balanceController.stream;

  // Load profile data from API
  Future<void> loadProfile() async {
    if (_isLoading) return;

    // Check if profile was fetched recently (within last 30 seconds)
    if (_lastProfileFetch != null &&
        DateTime.now().difference(_lastProfileFetch!).inSeconds < 30 &&
        _profileData != null) {
      print(
          '[PROFILE SERVICE] Profile was fetched recently, skipping API call');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authRepository = getIt<AuthRepository>();
      final profileData = await authRepository.getProfile();

      _profileData = profileData;
      _lastProfileFetch = DateTime.now();

      // Extract balance from profile data
      double oldBalance = _balance;
      if (profileData.containsKey('balance')) {
        final balanceValue = profileData['balance'];
        if (balanceValue is num) {
          _balance = balanceValue.toDouble();
        } else if (balanceValue is String) {
          _balance = double.tryParse(balanceValue) ?? 0.0;
        } else {
          _balance = 0.0;
        }
      } else {
        _balance = 0.0;
      }

      // Save balance to shared preferences for offline access
      await _saveBalanceToStorage();

      // Notify listeners if balance changed
      if (oldBalance != _balance) {
        print(
            '[PROFILE SERVICE] Notifying listeners of balance change: $oldBalance -> $_balance');
        _balanceController.add(_balance);
      }

      print('[PROFILE SERVICE] Profile loaded, balance: $_balance');
    } catch (e) {
      print('[PROFILE SERVICE] Error loading profile: $e');
      // Try to load balance from storage if API fails
      await _loadBalanceFromStorage();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Force refresh profile (ignores recent fetch check)
  Future<void> forceRefreshProfile() async {
    _lastProfileFetch = null; // Reset timestamp to force refresh
    await loadProfile();
  }

  // Update balance (for when driver completes orders)
  Future<void> updateBalance(double newBalance) async {
    double oldBalance = _balance;
    _balance = newBalance;
    await _saveBalanceToStorage();

    // Notify listeners if balance changed
    if (oldBalance != _balance) {
      print(
          '[PROFILE SERVICE] Notifying listeners of manual balance update: $oldBalance -> $_balance');
      _balanceController.add(_balance);
    }

    print('[PROFILE SERVICE] Balance updated to: $_balance');
  }

  // Update profile data from API response
  Future<void> updateProfileData(Map<String, dynamic> profileData) async {
    _profileData = profileData;

    // Extract balance from profile data
    double oldBalance = _balance;
    if (profileData.containsKey('balance')) {
      final balanceValue = profileData['balance'];
      if (balanceValue is num) {
        _balance = balanceValue.toDouble();
      } else if (balanceValue is String) {
        _balance = double.tryParse(balanceValue) ?? 0.0;
      } else {
        _balance = 0.0;
      }
    } else {
      _balance = 0.0;
    }

    // Save balance to shared preferences
    await _saveBalanceToStorage();

    // Notify listeners if balance changed
    if (oldBalance != _balance) {
      _balanceController.add(_balance);
    }

    print('[PROFILE SERVICE] Profile data updated, balance: $_balance');
  }

  // Save balance to shared preferences
  Future<void> _saveBalanceToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('driver_balance', _balance);
  }

  // Load balance from shared preferences
  Future<void> _loadBalanceFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _balance = prefs.getDouble('driver_balance') ?? 0.0;
    print('[PROFILE SERVICE] Balance loaded from storage: $_balance');
  }

  // Clear profile data (on logout)
  Future<void> clearProfile() async {
    double oldBalance = _balance;
    _profileData = null;
    _balance = 0.0;
    _lastProfileFetch = null; // Reset timestamp on logout
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('driver_balance');

    // Notify listeners if balance changed
    if (oldBalance != _balance) {
      _balanceController.add(_balance);
    }

    print('[PROFILE SERVICE] Profile cleared');
  }

  // Dispose the service
  void dispose() {
    _balanceController.close();
  }

  // Format balance for display
  String getFormattedBalance() {
    return _balance.toStringAsFixed(2);
  }

  // Get currency symbol (you can make this configurable)
  String getCurrencySymbol() {
    return '₸'; // Kazakhstani Tenge
  }

  // Get full formatted balance with currency
  String getFullFormattedBalance() {
    return '${getCurrencySymbol()} ${getFormattedBalance()}';
  }

  void setState(Function() callback) {
    callback();
  }
}
