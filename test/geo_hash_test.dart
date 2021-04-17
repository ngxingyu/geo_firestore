// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_firestore_flutter/src/geo_hash.dart';
import 'package:geo_firestore_flutter/src/geo_point.dart';
import 'package:geo_firestore_flutter/src/geo_utils.dart';
// import 'package:geo_firestore_flutter/src/geo_hash_query.dart';

void main() {
  test('Test decoding GeoHash', () {
    // region Test Decode
    expect(GeoUtils.decode("0"), GeoPoint(-67.5, -157.5));
    // Standard example with 9 character accuracy
    expect(GeoUtils.decode("9v6kn87zg"), GeoPoint(30.23710012435913, -97.79499292373657));
    // Arbitrary accuracy. Only up to 12 characters accuracy can be achieved
    expect(GeoUtils.decode("9v6kn87zgbbbbbbbbbb"), GeoPoint(30.237082819785357, -97.7949811566264));
    // Multiple ones that should throw an Exception
    expect(() => GeoUtils.decode("a"), throwsArgumentError);
    expect(() => GeoUtils.decode("-0"), throwsArgumentError);
    expect(() => GeoUtils.decode(""), throwsArgumentError);
    //endregion

    // region Test Encode
    expect(GeoUtils.encode(-67.5, -157.5, precision: 0), "");
    expect(GeoUtils.encode(30.23710012435913, -97.79499292373657, precision: 1), "9");
    expect(GeoUtils.encode(30.23710012435913, -97.79499292373657, precision: 9), "9v6kn87zg");
    expect(GeoUtils.encode(30.23710012435913, -97.79499292373657, precision: 10), "9v6kn87zgs");
    expect(GeoUtils.encode(30.23710012435913, -97.79499292373657, precision: 20), "9v6kn87zgs0000000000");
    expect(GeoUtils.encode(30.23710012435913, -97.79499292373657), "9v6kn87zgs");

    // Multiple ones that should throw an Exception
    expect(() => GeoUtils.encode(45, -181), throwsArgumentError);
    expect(() => GeoUtils.encode(95, 45), throwsArgumentError);
    expect(GeoHash("0").latitude(decimalAccuracy: 2), -67.50);
    expect(GeoHash("0"), GeoHash("0"));
    expect(GeoHash.fromDecimalDegrees(0, 0).toString(), "GeoHash(latitude=0.0,longitude=0.0,hash=s000000000)");
    print(GeoHash("0").getQueries(1));
    //endregion
  });
}
