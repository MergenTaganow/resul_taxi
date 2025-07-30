import 'package:geolocator/geolocator.dart';

/// Enum for boundary behavior configuration
enum BoundaryBehavior {
  /// Points on boundary are considered inside
  inside,

  /// Points on boundary are considered outside
  outside,

  /// Return special value for boundary points (use isPointOnPolygonBoundary)
  explicit
}

/// Result of point-in-polygon check with boundary information
class PolygonCheckResult {
  final bool isInside;
  final bool isOnBoundary;
  final bool isOnVertex;
  final bool isOnEdge;

  const PolygonCheckResult({
    required this.isInside,
    required this.isOnBoundary,
    required this.isOnVertex,
    required this.isOnEdge,
  });

  @override
  String toString() =>
      'PolygonResult(inside: $isInside, onBoundary: $isOnBoundary, onVertex: $isOnVertex, onEdge: $isOnEdge)';
}

class LocationHelper {
  static Future<bool> requestLocationPermission() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('[LOCATION] Location services are disabled');
      return false;
    }

    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('[LOCATION] Location permissions are denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('[LOCATION] Location permissions are permanently denied');
      return false;
    }

    print('[LOCATION] Location permissions granted');
    return true;
  }

  static Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 5,
          // timeLimit: Duration(seconds: 5),
        ),
      );

      return position;
    } catch (e) {
      print('[LOCATION] Error getting current location: $e');
      return null;
    }
  }

  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  static Future<LocationPermission> getLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  static Future<Position?> getLastKnownPosition() async {
    try {
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        return null;
      }

      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      print('[LOCATION] Error getting last known position: $e');
      return null;
    }
  }

  /// Filter duplicate coordinates from a polygon
  /// Returns a new list with unique coordinates based on precision tolerance
  ///
  /// Example usage:
  /// ```dart
  /// final rawCoordinates = [
  ///   [10.0, 20.0],
  ///   [10.0, 20.0], // duplicate
  ///   [15.0, 25.0],
  ///   [10.0000001, 20.0000001], // very close duplicate
  /// ];
  /// final filtered = LocationHelper.filterDuplicateCoordinates(rawCoordinates);
  /// // Result: [[10.0, 20.0], [15.0, 25.0]]
  /// ```
  static List<List<double>> filterDuplicateCoordinates(
    List<dynamic> coordinates, {
    double precision = 0.000001, // ~0.1 meter precision
  }) {
    if (coordinates.isEmpty) return [];

    List<List<double>> filteredCoordinates = [];

    for (int i = 0; i < coordinates.length; i++) {
      final current = coordinates[i];
      if (current is! List || current.length < 2) continue;

      final currentLng =
          current[0] is double ? current[0] : (current[0] as num).toDouble();
      final currentLat =
          current[1] is double ? current[1] : (current[1] as num).toDouble();

      bool isDuplicate = false;

      // Check against already added coordinates
      for (var existing in filteredCoordinates) {
        final lngDiff = (existing[0] - currentLng).abs();
        final latDiff = (existing[1] - currentLat).abs();

        if (lngDiff < precision && latDiff < precision) {
          isDuplicate = true;
          break;
        }
      }

      if (!isDuplicate) {
        filteredCoordinates.add([currentLng, currentLat]);
      }
    }

    print(
        '[LOCATION] Filtered coordinates: ${coordinates.length} -> ${filteredCoordinates.length}');
    return filteredCoordinates;
  }

  /// Optimized point-in-polygon method with automatic duplicate filtering
  /// Uses ray casting algorithm (odd-even rule)
  ///
  /// Example usage:
  /// ```dart
  /// final polygon = {
  ///   'type': 'Polygon',
  ///   'coordinates': [[
  ///     [10.0, 10.0], [20.0, 10.0], [20.0, 20.0], [10.0, 20.0], [10.0, 10.0]
  ///   ]]
  /// };
  ///
  /// // Check if point is inside polygon (with duplicate filtering enabled by default)
  /// bool isInside = LocationHelper.pointInPolygon(15.0, 15.0, polygon);
  ///
  /// // Disable duplicate filtering for performance if you know coordinates are clean
  /// bool isInside2 = LocationHelper.pointInPolygon(15.0, 15.0, polygon, filterDuplicates: false);
  /// ```
  static bool pointInPolygon(
    double lat,
    double lng,
    Map<String, dynamic> polygonGeoJson, {
    bool filterDuplicates = true,
    double precision = 0.000001,
  }) {
    if (polygonGeoJson['type'] != 'Polygon' ||
        polygonGeoJson['coordinates'] == null) {
      return false;
    }

    final List rawCoordinates = polygonGeoJson['coordinates'][0];

    // Filter duplicates if requested
    final List<List<double>> coordinates = filterDuplicates
        ? filterDuplicateCoordinates(rawCoordinates, precision: precision)
        : rawCoordinates
            .map<List<double>>((coord) => [
                  coord[0] is double ? coord[0] : (coord[0] as num).toDouble(),
                  coord[1] is double ? coord[1] : (coord[1] as num).toDouble(),
                ])
            .toList();

    if (coordinates.length < 3) {
      print('[LOCATION] Invalid polygon: less than 3 points after filtering');
      return false;
    }

    // Ensure polygon is closed (first point equals last point)
    if (coordinates.first[0] != coordinates.last[0] ||
        coordinates.first[1] != coordinates.last[1]) {
      coordinates.add([coordinates.first[0], coordinates.first[1]]);
    }

    int i, j = coordinates.length - 1;
    bool oddNodes = false;

    for (i = 0; i < coordinates.length; i++) {
      final double lat_i = coordinates[i][1]; // latitude
      final double lng_i = coordinates[i][0]; // longitude
      final double lat_j = coordinates[j][1];
      final double lng_j = coordinates[j][0];

      if ((lng_i < lng && lng_j >= lng || lng_j < lng && lng_i >= lng) &&
          (lat_i <= lat || lat_j <= lat)) {
        if (lat_i + (lng - lng_i) / (lng_j - lng_i) * (lat_j - lat_i) < lat) {
          oddNodes = !oddNodes;
        }
      }
      j = i;
    }

    return oddNodes;
  }

  /// Get polygon area in square meters (approximate)
  static double calculatePolygonArea(List<List<double>> coordinates) {
    if (coordinates.length < 3) return 0.0;

    double area = 0.0;
    final int n = coordinates.length;

    for (int i = 0; i < n; i++) {
      final j = (i + 1) % n;
      area += coordinates[i][0] * coordinates[j][1];
      area -= coordinates[j][0] * coordinates[i][1];
    }

    // Convert to approximate square meters
    // This is a rough approximation - for precise calculations use proper geodesic algorithms
    area = (area / 2.0).abs();
    const double degreesToMeters =
        111319.9; // approximate meters per degree at equator
    return area * degreesToMeters * degreesToMeters;
  }

  /// Calculate polygon centroid
  static List<double>? calculatePolygonCentroid(
      List<List<double>> coordinates) {
    if (coordinates.length < 3) return null;

    double centroidLng = 0.0;
    double centroidLat = 0.0;
    double signedArea = 0.0;

    for (int i = 0; i < coordinates.length - 1; i++) {
      final double x0 = coordinates[i][0];
      final double y0 = coordinates[i][1];
      final double x1 = coordinates[i + 1][0];
      final double y1 = coordinates[i + 1][1];

      final double a = x0 * y1 - x1 * y0;
      signedArea += a;
      centroidLng += (x0 + x1) * a;
      centroidLat += (y0 + y1) * a;
    }

    signedArea *= 0.5;
    if (signedArea == 0) return null;

    centroidLng /= (6.0 * signedArea);
    centroidLat /= (6.0 * signedArea);

    return [centroidLng, centroidLat];
  }

  /// Check if point is exactly on one of the polygon vertices
  static bool isPointOnPolygonVertex(
    double lat,
    double lng,
    List<List<double>> coordinates, {
    double tolerance = 0.000001,
  }) {
    for (final coord in coordinates) {
      final latDiff = (coord[1] - lat).abs();
      final lngDiff = (coord[0] - lng).abs();
      if (latDiff <= tolerance && lngDiff <= tolerance) {
        return true;
      }
    }
    return false;
  }

  /// Check if point lies on any edge of the polygon
  static bool isPointOnPolygonEdge(
    double lat,
    double lng,
    List<List<double>> coordinates, {
    double tolerance = 0.000001,
  }) {
    for (int i = 0; i < coordinates.length - 1; i++) {
      final p1 = coordinates[i];
      final p2 = coordinates[i + 1];

      if (_isPointOnLineSegment(
          lat, lng, p1[1], p1[0], p2[1], p2[0], tolerance)) {
        return true;
      }
    }
    return false;
  }

  /// Helper method to check if point is on line segment
  static bool _isPointOnLineSegment(
    double px,
    double py,
    double x1,
    double y1,
    double x2,
    double y2,
    double tolerance,
  ) {
    // Calculate the distance from point to line segment
    final double A = px - x1;
    final double B = py - y1;
    final double C = x2 - x1;
    final double D = y2 - y1;

    final double dot = A * C + B * D;
    final double lenSq = C * C + D * D;

    if (lenSq == 0) {
      // Line segment is actually a point
      return (px - x1).abs() <= tolerance && (py - y1).abs() <= tolerance;
    }

    double param = dot / lenSq;

    double xx, yy;

    if (param < 0) {
      xx = x1;
      yy = y1;
    } else if (param > 1) {
      xx = x2;
      yy = y2;
    } else {
      xx = x1 + param * C;
      yy = y1 + param * D;
    }

    final dx = px - xx;
    final dy = py - yy;
    final distance = (dx * dx + dy * dy);

    // Convert tolerance from degrees to approximate distance squared
    final toleranceSquared = tolerance * tolerance;

    return distance <= toleranceSquared;
  }

  /// Comprehensive point-in-polygon check with boundary detection
  /// Returns detailed information about point location relative to polygon
  static PolygonCheckResult pointInPolygonDetailed(
    double lat,
    double lng,
    Map<String, dynamic> polygonGeoJson, {
    bool filterDuplicates = true,
    double precision = 0.000001,
    double boundaryTolerance = 0.000001,
  }) {
    if (polygonGeoJson['type'] != 'Polygon' ||
        polygonGeoJson['coordinates'] == null) {
      return const PolygonCheckResult(
        isInside: false,
        isOnBoundary: false,
        isOnVertex: false,
        isOnEdge: false,
      );
    }

    final List rawCoordinates = polygonGeoJson['coordinates'][0];

    // Filter duplicates if requested
    final List<List<double>> coordinates = filterDuplicates
        ? filterDuplicateCoordinates(rawCoordinates, precision: precision)
        : rawCoordinates
            .map<List<double>>((coord) => [
                  coord[0] is double ? coord[0] : (coord[0] as num).toDouble(),
                  coord[1] is double ? coord[1] : (coord[1] as num).toDouble(),
                ])
            .toList();

    if (coordinates.length < 3) {
      return const PolygonCheckResult(
        isInside: false,
        isOnBoundary: false,
        isOnVertex: false,
        isOnEdge: false,
      );
    }

    // Ensure polygon is closed
    if (coordinates.first[0] != coordinates.last[0] ||
        coordinates.first[1] != coordinates.last[1]) {
      coordinates.add([coordinates.first[0], coordinates.first[1]]);
    }

    // Check if point is on vertex
    final bool isOnVertex = isPointOnPolygonVertex(lat, lng, coordinates,
        tolerance: boundaryTolerance);

    // Check if point is on edge
    final bool isOnEdge = isPointOnPolygonEdge(lat, lng, coordinates,
        tolerance: boundaryTolerance);

    final bool isOnBoundary = isOnVertex || isOnEdge;

    // If on boundary, don't need to do ray casting
    if (isOnBoundary) {
      return PolygonCheckResult(
        isInside: true, // Consider boundary as inside by default
        isOnBoundary: true,
        isOnVertex: isOnVertex,
        isOnEdge: isOnEdge,
      );
    }

    // Perform ray casting for interior points
    int i, j = coordinates.length - 1;
    bool oddNodes = false;

    for (i = 0; i < coordinates.length; i++) {
      final double lat_i = coordinates[i][1];
      final double lng_i = coordinates[i][0];
      final double lat_j = coordinates[j][1];
      final double lng_j = coordinates[j][0];

      if ((lng_i < lng && lng_j >= lng || lng_j < lng && lng_i >= lng) &&
          (lat_i <= lat || lat_j <= lat)) {
        if (lat_i + (lng - lng_i) / (lng_j - lng_i) * (lat_j - lat_i) < lat) {
          oddNodes = !oddNodes;
        }
      }
      j = i;
    }

    return PolygonCheckResult(
      isInside: oddNodes,
      isOnBoundary: false,
      isOnVertex: false,
      isOnEdge: false,
    );
  }

  /// Enhanced point-in-polygon method with configurable boundary behavior
  static bool pointInPolygonEnhanced(
    double lat,
    double lng,
    Map<String, dynamic> polygonGeoJson, {
    bool filterDuplicates = true,
    double precision = 0.000001,
    double boundaryTolerance = 0.000001,
    BoundaryBehavior boundaryBehavior = BoundaryBehavior.inside,
  }) {
    final result = pointInPolygonDetailed(
      lat,
      lng,
      polygonGeoJson,
      filterDuplicates: filterDuplicates,
      precision: precision,
      boundaryTolerance: boundaryTolerance,
    );

    if (result.isOnBoundary) {
      switch (boundaryBehavior) {
        case BoundaryBehavior.inside:
          return true;
        case BoundaryBehavior.outside:
          return false;
        case BoundaryBehavior.explicit:
          // Caller should use pointInPolygonDetailed for boundary info
          return true;
      }
    }

    return result.isInside;
  }

  /// Check if point is on polygon boundary (vertex or edge)
  static bool isPointOnPolygonBoundary(
    double lat,
    double lng,
    Map<String, dynamic> polygonGeoJson, {
    bool filterDuplicates = true,
    double precision = 0.000001,
    double boundaryTolerance = 0.000001,
  }) {
    final result = pointInPolygonDetailed(
      lat,
      lng,
      polygonGeoJson,
      filterDuplicates: filterDuplicates,
      precision: precision,
      boundaryTolerance: boundaryTolerance,
    );

    return result.isOnBoundary;
  }

  /// Demonstration method showing boundary detection behavior
  /// This method shows various test cases for educational purposes
  static void demonstrateBoundaryDetection() {
    // Example polygon: a square from (10,10) to (20,20)
    final polygon = {
      'type': 'Polygon',
      'coordinates': [
        [
          [10.0, 10.0], // bottom-left vertex
          [20.0, 10.0], // bottom-right vertex
          [20.0, 20.0], // top-right vertex
          [10.0, 20.0], // top-left vertex
          [10.0, 10.0], // close polygon
        ]
      ]
    };

    print('=== BOUNDARY DETECTION DEMONSTRATION ===');

    // Test cases
    final testCases = [
      // [lat, lng, expected description]
      [15.0, 15.0, 'Inside polygon (center)'],
      [25.0, 25.0, 'Outside polygon'],
      [10.0, 10.0, 'On vertex (bottom-left corner)'],
      [20.0, 20.0, 'On vertex (top-right corner)'],
      [15.0, 10.0, 'On edge (bottom edge)'],
      [20.0, 15.0, 'On edge (right edge)'],
      [15.0, 20.0, 'On edge (top edge)'],
      [10.0, 15.0, 'On edge (left edge)'],
    ];

    for (final testCase in testCases) {
      final lat = testCase[0] as double;
      final lng = testCase[1] as double;
      final description = testCase[2] as String;

      print('\n--- Testing: $description ---');
      print('Point: ($lat, $lng)');

      // Test with old method (may give wrong results for boundary cases)
      final oldResult = pointInPolygon(lat, lng, polygon);
      print('Old method result: $oldResult');

      // Test with detailed boundary detection
      final detailedResult = pointInPolygonDetailed(lat, lng, polygon);
      print('Detailed result: $detailedResult');

      // Test with different boundary behaviors
      final insideBehavior = pointInPolygonEnhanced(lat, lng, polygon,
          boundaryBehavior: BoundaryBehavior.inside);
      final outsideBehavior = pointInPolygonEnhanced(lat, lng, polygon,
          boundaryBehavior: BoundaryBehavior.outside);

      print('Boundary as INSIDE: $insideBehavior');
      print('Boundary as OUTSIDE: $outsideBehavior');
    }

    print('\n=== DEMONSTRATION COMPLETE ===');
  }
}
