import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:taxi_service/core/network/api_client.dart';
import 'package:taxi_service/core/di/injection.dart';
import 'package:taxi_service/core/utils/location_helper.dart';

class LocationDistrictService {
  static final LocationDistrictService _instance =
      LocationDistrictService._internal();
  factory LocationDistrictService() => _instance;
  LocationDistrictService._internal();

  final ApiClient _apiClient = getIt<ApiClient>();
  Timer? _locationTimer;
  Position? _currentPosition;
  List<Map<String, dynamic>> _districts = [];
  bool _isLocationEnabled = false;

  // Stream controllers for real-time updates
  final StreamController<Position> _locationController =
      StreamController<Position>.broadcast();
  final StreamController<List<Map<String, dynamic>>> _districtsController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  // Getters for streams
  Stream<Position> get locationStream => _locationController.stream;
  Stream<List<Map<String, dynamic>>> get districtsStream =>
      _districtsController.stream;

  // Getters for current values
  Position? get currentPosition => _currentPosition;
  List<Map<String, dynamic>> get districts => _districts;
  bool get isLocationEnabled => _isLocationEnabled;

  /// Initialize the service
  Future<void> initialize() async {
    await _checkLocationPermission();
    // Don't fetch districts immediately - wait for authentication
    // await _fetchDistricts();
  }

  /// Check and request location permissions
  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _isLocationEnabled = false;
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _isLocationEnabled = false;
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _isLocationEnabled = false;
      return false;
    }

    _isLocationEnabled = true;
    return true;
  }

  /// Start location tracking
  Future<void> startLocationTracking() async {
    if (!_isLocationEnabled) {
      bool hasPermission = await _checkLocationPermission();
      if (!hasPermission) return;
    }

    // Get initial position
    try {
      _currentPosition = await Geolocator.getCurrentPosition();
      _locationController.add(_currentPosition!);
    } catch (e) {
      print('Error getting initial position: $e');
    }

    // Start periodic location updates
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      try {
        Position position = await Geolocator.getCurrentPosition();
        _currentPosition = position;
        _locationController.add(position);
      } catch (e) {
        print('Error updating location: $e');
      }
    });
  }

  /// Stop location tracking
  void stopLocationTracking() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  /// Fetch districts from API
  Future<void> _fetchDistricts() async {
    try {
      print('[LOCATION DISTRICT] Fetching districts from API...');
      final response = await _apiClient.getDistricts();
      _districts = List<Map<String, dynamic>>.from(response);
      print('[LOCATION DISTRICT] Fetched ${_districts.length} districts');

      // Log district details for debugging
      // for (var district in _districts) {
      //   final hasPolygon = district['polygon'] != null;
      //   final hasGeoJson = district['geojson'] != null;
      //   final hasCenter =
      //       district['center_lat'] != null && district['center_lng'] != null;

      //   print(
      //       '[LOCATION DISTRICT] District: ${district['slug']} - hasPolygon: $hasPolygon, hasGeoJson: $hasGeoJson, hasCenter: $hasCenter');

      //   if (hasPolygon) {
      //     final polygon = json.decode(district['polygon']['coordinates']) as List<dynamic>;
      //     print('[LOCATION DISTRICT]   Polygon points: ${polygon.length}');
      //   }

      //   if (hasGeoJson) {
      //     final geojson = district['geojson'] as Map<String, dynamic>;
      //     final coordinates = geojson['coordinates'] as List<dynamic>?;
      //     print(
      //         '[LOCATION DISTRICT]   GeoJSON coordinates: ${coordinates?.length ?? 0} rings');
      //   }

      //   if (hasCenter) {
      //     print(
      //         '[LOCATION DISTRICT]   Center: ${district['center_lat']}, ${district['center_lng']} - radius: ${district['radius']}');
      //   }
      // }

      _districtsController.add(_districts);
    } catch (e) {
      print('[LOCATION DISTRICT] Error fetching districts: $e');
    }
  }

  /// Refresh districts data
  Future<void> refreshDistricts() async {
    await _fetchDistricts();
  }

  /// Fetch districts when user is authenticated
  Future<void> fetchDistrictsWhenAuthenticated() async {
    await _fetchDistricts();
  }

  /// Get district by ID
  Map<String, dynamic>? getDistrictById(int id) {
    try {
      return _districts.firstWhere((district) => district['id'] == id);
    } catch (e) {
      return null;
    }
  }

  /// Get district by name
  Map<String, dynamic>? getDistrictByName(String name) {
    try {
      return _districts.firstWhere((district) => district['name'] == name);
    } catch (e) {
      return null;
    }
  }

  /// Calculate distance between two positions
  double calculateDistance(Position position1, Position position2) {
    return Geolocator.distanceBetween(
      position1.latitude,
      position1.longitude,
      position2.latitude,
      position2.longitude,
    );
  }

  /// Get distance from current position to a specific location
  double? getDistanceToLocation(double latitude, double longitude) {
    if (_currentPosition == null) return null;

    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      latitude,
      longitude,
    );
  }

  /// Check if a position is within a district using polygon coordinates
  bool isPositionInDistrict(Position position, Map<String, dynamic> district) {
    // Check if district has polygon data
    if (district['polygon'] != null) {
      try {
        Map<String, dynamic> polygon;

        // Handle case where polygon is stored as JSON string
        if (district['polygon'] is String) {
          final jsonString = district['polygon'] as String;
          print(
              '[LOCATION DISTRICT] Polygon is JSON string: ${jsonString.substring(0, jsonString.length > 100 ? 100 : jsonString.length)}...');
          polygon = json.decode(jsonString) as Map<String, dynamic>;
          print(
              '[LOCATION DISTRICT] Parsed polygon from JSON string successfully');
        } else {
          print('[LOCATION DISTRICT] Polygon is already Map object');
          polygon = district['polygon'] as Map<String, dynamic>;
        }

        print('[LOCATION DISTRICT] Testing district: ${district['slug']}');
        final isInPolygon = LocationHelper.pointInPolygon(
            position.latitude, position.longitude, polygon);
        print(
            '[LOCATION DISTRICT] District ${district['slug']}: polygon check = $isInPolygon');
        return isInPolygon;
      } catch (e) {
        print(
            '[LOCATION DISTRICT] Error parsing polygon for district ${district['slug']}: $e');
        print('[LOCATION DISTRICT] Polygon data: ${district['polygon']}');
      }
    }

    print(
        '[LOCATION DISTRICT] District ${district['slug']}: No polygon or center coordinates available');
    return false;
  }

  /// Get current district based on current position
  Map<String, dynamic>? getCurrentDistrict() {
    if (_currentPosition == null) {
      print('[LOCATION DISTRICT] No current position available');
      return null;
    }

    print(
        '[LOCATION DISTRICT] Checking ${_districts.length} districts for position: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');

    List<Map<String, dynamic>> matchingDistricts = [];

    for (var district in _districts) {
      final isInDistrict = isPositionInDistrict(_currentPosition!, district);
      print(
          '[LOCATION DISTRICT] District ${district['slug']}: isInDistrict = $isInDistrict');

      if (isInDistrict) {
        matchingDistricts.add(district);
        print(
            '[LOCATION DISTRICT] Found matching district: ${district['slug']}');
      }
    }

    if (matchingDistricts.isEmpty) {
      print('[LOCATION DISTRICT] No matching district found');
      return null;
    }

    if (matchingDistricts.length > 1) {
      print(
          '[LOCATION DISTRICT] WARNING: Multiple districts match! Found ${matchingDistricts.length} districts:');
      for (var district in matchingDistricts) {
        print('[LOCATION DISTRICT]   - ${district['slug']}');
      }
    }

    // Return the first matching district (you might want to add priority logic here)
    final selectedDistrict = matchingDistricts.first;
    print('[LOCATION DISTRICT] Selected district: ${selectedDistrict['slug']}');
    return selectedDistrict;
  }

  /// Get nearby districts within a certain radius
  List<Map<String, dynamic>> getNearbyDistricts(double radiusInMeters) {
    if (_currentPosition == null) return [];

    List<Map<String, dynamic>> nearbyDistricts = [];

    for (var district in _districts) {
      if (district['center_lat'] != null && district['center_lng'] != null) {
        double distance = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          district['center_lat'],
          district['center_lng'],
        );

        if (distance <= radiusInMeters) {
          nearbyDistricts.add({
            ...district,
            'distance': distance,
          });
        }
      }
    }

    // Sort by distance
    nearbyDistricts.sort(
        (a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

    return nearbyDistricts;
  }

  /// Start location monitoring and return a stream of current district updates
  Stream<Map<String, dynamic>?> startLocationMonitoring() {
    print('[LOCATION DISTRICT] Starting location monitoring...');
    print('[LOCATION DISTRICT] Current districts: ${_districts.length}');

    // Start location tracking if not already started
    if (_locationTimer == null) {
      print('[LOCATION DISTRICT] Starting location tracking...');
      startLocationTracking();
    } else {
      print('[LOCATION DISTRICT] Location tracking already active');
    }

    // Create a stream that emits the current district whenever location changes
    return _locationController.stream.map((position) {
      _currentPosition = position;
      final currentDistrict = getCurrentDistrict();
      print(
          '[LOCATION DISTRICT] Position: ${position.latitude}, ${position.longitude}');
      print('[LOCATION DISTRICT] Current district: $currentDistrict');
      return currentDistrict;
    });
  }

  /// Dispose of resources
  void dispose() {
    stopLocationTracking();
    _locationController.close();
    _districtsController.close();
  }
}
