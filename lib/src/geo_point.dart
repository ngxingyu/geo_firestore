import 'dart:ui';

/// Represents a geographical point by its longitude and latitude
class GeoPoint {
  /// Create [GeoPoint] instance.
  const GeoPoint(this.latitude, this.longitude)
      : assert(latitude >= -90 && latitude <= 90),
        assert(longitude >= -180 && longitude <= 180);

  final double latitude;
  final double longitude;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is GeoPoint && runtimeType == other.runtimeType && other.latitude == latitude && other.longitude == longitude;

  @override
  int get hashCode => hashValues(latitude, longitude);

  @override
  String toString() => "GeoPoint(latitude=$latitude,longitude=$longitude)";
}
