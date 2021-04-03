import 'dart:math';

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_firestore_flutter/src/geo_hash.dart';
// import 'package:geo_firestore_flutter/src/geo_hash_query.dart';

void main() {
  test('Test decoding GeoHash', () {
    // region Test Decode
    expect(GeoHash.decode("0"), Point(-157.5, -67.5));
    // Standard example with 9 character accuracy
    expect(GeoHash.decode("9v6kn87zg"), Point(-97.79499292373657, 30.23710012435913));
    // Arbitrary accuracy. Only up to 12 characters accuracy can be achieved
    expect(GeoHash.decode("9v6kn87zgbbbbbbbbbb"), Point(-97.7949811566264, 30.237082819785357));

    // Multiple ones that should throw an Exception
    expect(() => GeoHash.decode("a"), throwsArgumentError);
    expect(() => GeoHash.decode("-0"), throwsArgumentError);
    expect(() => GeoHash.decode(""), throwsArgumentError);
    //endregion

    // region Test Encode
    expect(GeoHash.encode(-67.5, -157.5, precision: 0), "");
    expect(GeoHash.encode(30.23710012435913, -97.79499292373657, precision: 1), "9");
    expect(GeoHash.encode(30.23710012435913, -97.79499292373657, precision: 9), "9v6kn87zg");
    expect(GeoHash.encode(30.23710012435913, -97.79499292373657, precision: 10), "9v6kn87zgs");
    expect(GeoHash.encode(30.23710012435913, -97.79499292373657, precision: 20), "9v6kn87zgs0000000000");
    expect(GeoHash.encode(30.23710012435913, -97.79499292373657), "9v6kn87zgs");

    // Multiple ones that should throw an Exception
    expect(() => GeoHash.encode(45, -181), throwsArgumentError);
    expect(() => GeoHash.encode(95, 45), throwsArgumentError);
    //endregion
  });
}
