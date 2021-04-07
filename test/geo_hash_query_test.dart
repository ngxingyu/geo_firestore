import 'package:geo_firestore_flutter/src/geo_hash_query.dart';
import 'package:geo_firestore_flutter/src/geo_point.dart';

void main() {
  var test1 = Set<GeoHashQuery>();
  test1.add(GeoHashQuery(startValue: 'w21zkt', endValue: 'w21zku'));
  test1.add(GeoHashQuery(startValue: 'w21zkv', endValue: 'w21zk~'));
  print(test1);
  print(GeoHashQuery.queriesAtLocation(
    GeoPoint(1.34309745890513, 103.856225857985),
    400,
  ));
}
