import 'dart:math';

import 'package:geo_firestore_flutter/src/geo_constants.dart';

import 'base32_utils.dart';
import 'geo_point.dart';

class GeoUtils {
  ///
  /// Checks if these coordinates are valid geo coordinates.
  /// [latitude]  The latitude must be in the range [-90, 90]
  /// [longitude] The longitude must be in the range [-180, 180]
  /// returns [true] if these are valid geo coordinates
  ///
  static bool coordinatesValid(double latitude, double longitude) {
    return (latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180);
  }

  ///
  /// Checks if the coordinates  of a GeopPoint are valid geo coordinates.
  /// [latitude]  The latitude must be in the range [-90, 90]
  /// [longitude] The longitude must be in the range [-180, 180]
  /// returns [true] if these are valid geo coordinates
  ///
  static bool geoPointValid(GeoPoint point) {
    return (point.latitude >= -90 && point.latitude <= 90 && point.longitude >= -180 && point.longitude <= 180);
  }

  ///
  /// Wraps the longitude to [-180,180].
  ///
  /// [longitude] The longitude to wrap.
  /// returns The resulting longitude.
  ///
  static double wrapLongitude(double longitude) {
    if (longitude <= 180 && longitude >= -180) {
      return longitude;
    }
    final adjusted = longitude + 180;
    if (adjusted > 0) {
      return (adjusted % 360) - 180;
    }
    // else
    return 180 - (-adjusted % 360);
  }

  static double degreesToRadians(double degrees) {
    return (degrees * pi) / 180;
  }

  ///
  /// Calculates the number of degrees a given distance is at a given latitude.
  /// [distance] The distance to convert.
  /// [latitude] The latitude at which to calculate.
  /// returns the number of degrees the distance corresponds to.
  static double distanceToLongitudeDegrees(double distance, double latitude) {
    final radians = degreesToRadians(latitude);
    final numerator = cos(radians) * EARTH_EQ_RADIUS * pi / 180;
    final denom = 1 / sqrt(1 - E2 * sin(radians) * sin(radians));
    final deltaDeg = numerator * denom;
    if (deltaDeg < EPSILON) {
      return distance > 0 ? 360.0 : 0.0;
    }
    // else
    return min(360.0, distance / deltaDeg);
  }

  ///
  /// Calculates the distance, in kilometers, between two locations, via the
  /// Haversine formula. Note that this is approximate due to the fact that
  /// the Earth's radius varies between 6356.752 km and 6378.137 km.
  /// [p1] The first location given
  /// [p2] The second location given
  /// return the distance, in kilometers, between the two locations.
  ///
  static double distance(GeoPoint p1, GeoPoint p2) {
    final dlat = degreesToRadians(p2.latitude - p1.latitude);
    final dlon = degreesToRadians(p2.longitude - p1.longitude);
    final lat1 = degreesToRadians(p1.latitude);
    final lat2 = degreesToRadians(p2.latitude);

    final r = 6378.137; // WGS84 major axis
    double c = 2 * asin(sqrt(pow(sin(dlat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dlon / 2), 2)));
    return r * c;
  }

  static double distanceToLatitudeDegrees(double distance) => distance / METERS_PER_DEGREE_LATITUDE;

  static double capRadius(double radius) {
    if (radius > MAX_SUPPORTED_RADIUS) {
      print("The radius is bigger than $MAX_SUPPORTED_RADIUS and hence we'll use that value");
      return MAX_SUPPORTED_RADIUS.toDouble();
    }
    return radius;
  }

  // The default precision of a geohash
  static const DEFAULT_PRECISION = 10;

  // The maximal precision of a geohash
  static const MAX_PRECISION = 22;

  // The maximal number of bits precision for a geohash
  static const MAX_PRECISION_BITS = MAX_PRECISION * Base32Utils.BITS_PER_BASE32_CHAR;

  /// Get the rectangle that covers the entire area of a geohash string.
  static Rectangle<double> getExtents(String geohash) {
    final precision = geohash.length;
    if (precision > MAX_PRECISION) {
      throw new ArgumentError('latitude and longitude are not precise enough to encode $precision characters');
    }
    var latitudeInt = 0;
    var longitudeInt = 0;
    var longitudeFirst = true;
    for (var character in geohash.codeUnits.map((r) => new String.fromCharCode(r))) {
      int thisSequence;
      try {
        thisSequence = Base32Utils.base32CharToValue(character);
      } catch (error) {
        throw new ArgumentError('$geohash was not a geohash string');
      }
      final bigBits = ((thisSequence & 16) >> 2) | ((thisSequence & 4) >> 1) | (thisSequence & 1);
      final smallBits = ((thisSequence & 8) >> 2) | ((thisSequence & 2) >> 1);
      if (longitudeFirst) {
        longitudeInt = (longitudeInt << 3) | bigBits;
        latitudeInt = (latitudeInt << 2) | smallBits;
      } else {
        longitudeInt = (longitudeInt << 2) | smallBits;
        latitudeInt = (latitudeInt << 3) | bigBits;
      }
      longitudeFirst = !longitudeFirst;
    }
    final longitudeBits = (precision ~/ 2) * 5 + (precision % 2) * 3;
    final latitudeBits = precision * 5 - longitudeBits;

    if (identical(1.0, 1)) {
      // Some of our intermediate numbers are STILL too big for javascript,
      // so  we use floating point math...
      final longitudeDiff = pow(2.0, 52 - longitudeBits);
      final latitudeDiff = pow(2.0, 52 - latitudeBits);
      final latitudeFloat = latitudeInt.toDouble() * latitudeDiff;
      final longitudeFloat = longitudeInt.toDouble() * longitudeDiff;
      final latitude = latitudeFloat * (180 / pow(2.0, 52)) - 90;
      final longitude = longitudeFloat * (360 / pow(2.0, 52)) - 180;
      final height = latitudeDiff * (180 / pow(2.0, 52));
      final width = longitudeDiff * (360 / pow(2.0, 52));
      return Rectangle<double>(longitude, latitude, width.toDouble(), height.toDouble());
    }

    longitudeInt = longitudeInt << (52 - longitudeBits);
    latitudeInt = latitudeInt << (52 - latitudeBits);
    final longitudeDiff = 1 << (52 - longitudeBits);
    final latitudeDiff = 1 << (52 - latitudeBits);

    final latitude = latitudeInt.toDouble() * (180 / pow(2.0, 52)) - 90;
    final longitude = longitudeInt.toDouble() * (360 / pow(2.0, 52)) - 180;
    final height = latitudeDiff.toDouble() * (180 / pow(2.0, 52));
    final width = longitudeDiff.toDouble() * (360 / pow(2.0, 52));
    return Rectangle<double>(longitude, latitude - height, width, height);
    //I know this is backward, but it's because lat/lng are backwards.
  }

  /// Encode a latitude and longitude pair into a geohash string.
  static String encode(final double latitude, final double longitude, {final int precision: DEFAULT_PRECISION}) {
    if (precision > MAX_PRECISION) {
      throw new ArgumentError('latitude and longitude are not precise enough to encode $precision characters');
    }
    if (longitude < -180.0 || longitude > 180.0) throw RangeError.range(longitude, -180, 180, "Longitude");
    if (latitude < -90.0 || latitude > 90.0) throw RangeError.range(latitude, -180, 180, "Latitude");
    final latitudeBase2 = (latitude + 90) * (pow(2.0, 52) / 180);
    final longitudeBase2 = (longitude + 180) * (pow(2.0, 52) / 360);
    final longitudeBits = (precision ~/ 2) * 5 + (precision % 2) * 3;
    final latitudeBits = precision * 5 - longitudeBits;
    var longitudeCode = longitudeBase2.floor() >> (52 - longitudeBits);
    var latitudeCode = latitudeBase2.floor() >> (52 - latitudeBits);

    final stringBuffer = [];
    for (var localPrecision = precision; localPrecision > 0; localPrecision--) {
      int bigEndCode, littleEndCode;
      if (localPrecision % 2 == 0) {
        // Even slot. Latitude is more significant.
        bigEndCode = latitudeCode;
        littleEndCode = longitudeCode;
        latitudeCode >>= 3;
        longitudeCode >>= 2;
      } else {
        bigEndCode = longitudeCode;
        littleEndCode = latitudeCode;
        latitudeCode >>= 2;
        longitudeCode >>= 3;
      }
      final code = ((bigEndCode & 4) << 2) | ((bigEndCode & 2) << 1) | (bigEndCode & 1) | ((littleEndCode & 2) << 2) | ((littleEndCode & 1) << 1);
      stringBuffer.add(Base32Utils.valueToBase32Char(code));
    }
    final buffer = new StringBuffer()..writeAll(stringBuffer.reversed);
    return buffer.toString();
  }

  /// Get a single number that is the center of a specific geohash rectangle.
  static GeoPoint decode(String geohash) {
    if (geohash == "")
      throw ArgumentError.value(geohash, "geohash");
    else if (!geohash.contains(new RegExp(r'^[0123456789bcdefghjkmnpqrstuvwxyz]+$'))) throw ArgumentError("Invalid character in GeoHash");
    final extents = getExtents(geohash);
    final x = extents.left + extents.width / 2;
    final y = extents.bottom + extents.height / 2;
    return GeoPoint(y, x);
  }
}
