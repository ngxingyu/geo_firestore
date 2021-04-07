import 'dart:math';
import 'dart:ui';

import 'geo_point.dart';
import 'geo_utils.dart';

/// A containing class for a geohash
class GeoHash {
  late String _geohash;
  late GeoPoint _geolocation;
  late Rectangle<double> _extents;

  GeoHash(String geohash) {
    _geohash = geohash;
    // _neighbors = GeoHasher.neighbors(geohash);
    _extents = GeoUtils.getExtents(geohash);
    _geolocation = GeoUtils.decode(geohash);
  }

  /// Constructor given Longitude and Latitude
  GeoHash.fromDecimalDegrees(double latitude, double longitude, {int codeLength = 10}) {
    _geolocation = GeoPoint(latitude, longitude);
    _geohash = GeoUtils.encode(latitude, longitude, precision: codeLength);
    _extents = GeoUtils.getExtents(_geohash);
  }

  /// Returns the double longitude with an optional decimal accuracy
  double longitude({int? decimalAccuracy}) {
    if (decimalAccuracy == null) return _geolocation.longitude;
    return double.parse(_geolocation.longitude.toStringAsFixed(decimalAccuracy));
  }

  /// Returns the double latitude with an optional decimal accuracy
  double latitude({int? decimalAccuracy}) {
    if (decimalAccuracy == null)
      return _geolocation.latitude;
    else
      return double.parse(_geolocation.latitude.toStringAsFixed(decimalAccuracy));
  }

  double distance(GeoHash other) => GeoUtils.distance(_geolocation, other.geolocation);

  String get geohash => _geohash;
  Rectangle<double> get extents => _extents;
  GeoPoint get geolocation => _geolocation;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GeoHash && runtimeType == other.runtimeType && _geohash == other.geohash;

  @override
  int get hashCode => runtimeType.hashCode ^ hashValues(latitude, longitude);

  @override
  String toString() => "GeoHash(latitude=$latitude,longitude=$longitude,hash=$geohash)";
}
