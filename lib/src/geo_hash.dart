import 'dart:math';

import 'geo_point.dart';
import 'geo_utils.dart';

abstract class GeoHashBase {
  String? get geohash;
  double? longitude();
  double? latitude();
  Rectangle<double>? get extents;
  GeoPoint? get geolocation;
}

class NoGeoHash implements GeoHashBase {
  double? longitude() => null;
  double? latitude() => null;
  String? get geohash => null;
  Rectangle<double>? get extents => null;
  GeoPoint? get geolocation => null;
}

/// A containing class for a geohash
class GeoHash implements GeoHashBase {
  late String _geohash;
  late GeoPoint _geolocation;
  late Rectangle<double> _extents;

  GeoHash(String geohash) {
    _geohash = geohash;
    // _neighbors = GeoHasher.neighbors(geohash);
    _extents = GeoUtils.getExtents(geohash);
    _geolocation = GeoUtils.decode(geohash);
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

  String get geohash => _geohash;
  Rectangle<double> get extents => _extents;
  GeoPoint get geolocation => _geolocation;
}
