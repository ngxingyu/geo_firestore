import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geo_firestore_flutter/src/geo_hash_query.dart';

void main() {
  var test1 = Set<GeoHashQuery>();
  test1.add(GeoHashQuery(startValue: 'w21zkt', endValue: 'w21zku'));
  test1.add(GeoHashQuery(startValue: 'w21zkv', endValue: 'w21zk~'));
  print(test1);
  print(GeoHashQuery.queriesAtLocation(
    GeoPoint(1.3097521662712097, 103.91663610935211),
    400,
  ));
}
