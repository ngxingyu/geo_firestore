import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' hide GeoPoint;
import 'geo_hash_query.dart';
import 'geo_utils.dart';

import 'geo_point.dart';

/// A GeoFirestore instance is used to store and query geo location data in Firestore.
class GeoFirestore {
  late CollectionReference<Map<String, dynamic>> collectionReference;

  GeoFirestore(CollectionReference<Map<String, dynamic>> collectionReference) {
    this.collectionReference = collectionReference;
  }

  /// Build a GeoPoint from a [documentSnapshot]
  static GeoPoint? getLocationValue(DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
    try {
      final data = documentSnapshot.data();
      if (data != null && data['lat'] != null && data['lng'] != null) {
        final latitude = data['lat'];
        final longitude = data['lng'];
        if (GeoUtils.coordinatesValid(latitude, longitude)) {
          return GeoPoint(latitude, longitude);
        }
      }
      return null;
    } catch (e) {
      print('Error occurred when getLocationValue: ' + e.toString());
      return null;
    }
  }

  /// Sets the [location] of a document for the given [documentID].
  Future<dynamic> setLocation(String documentID, GeoPoint location) async {
    var docRef = this.collectionReference.doc(documentID);
    var geoHash = GeoUtils.encode(location.latitude, location.longitude);
    // Create a Map with the fields to add
    var updates = Map<String, dynamic>();
    updates['geohash'] = geoHash;
    updates['lat'] = location.latitude;
    updates['lng'] = location.longitude;
    // Update the DocumentReference with the location data
    return await docRef.set(updates, SetOptions(merge: true));
  }

  /// Removes the [location] of a document for the given [documentID].
  Future<dynamic> removeLocation(String documentID, GeoPoint location) async {
    //Get the DocumentReference for this documentID
    var docRef = this.collectionReference.doc(documentID);
    //Create a Map with the fields to add
    var updates = Map<String, dynamic>();
    updates['geohash'] = null;
    updates['lat'] = null;
    updates['lng'] = null;
    //Update the DocumentReference with the location data
    await docRef.set(updates, SetOptions(merge: true));
  }

  /// Gets the current location of a document for the given [documentID].
  Future<GeoPoint?> getLocation(String documentID) async {
    final snapshot = await this.collectionReference.doc(documentID).get();
    final geoPoint = getLocationValue(snapshot);
    return geoPoint;
  }

  /// Returns the documents centered at a given location and with the given radius.
  /// [center]      The center of the query
  /// [radius]      The radius of the query, in kilometers. The maximum radius that is
  ///               supported is about 8587km. If a radius bigger than this is passed we'll cap it.
  /// [addDistance] Whether to process data and add distance property to returned documents, defaults to True.
  /// [exact]       Whether to process data and remove documents that are further than specified radius, defaults to True.
  ///
  Future<List<DocumentSnapshot>> getAtLocation(
    GeoPoint center,
    double radius, {
    bool exact = true,
    bool addDistance = true,
  }) async {
    // Get the futures from Firebase Queries generated from GeoHashQueries
    final futures = GeoHashQuery.queriesAtLocation(center, GeoUtils.capRadius(radius) * 1000)
        .map((query) => createFirestoreQuery(this.collectionReference, query).get());

    // Await the completion of all the futures
    try {
      List<DocumentSnapshot<Map<String, dynamic>>> documents = [];
      final snapshots = await Future.wait(futures);
      snapshots.forEach((snapshot) {
        snapshot.docs.forEach((doc) {
          if (addDistance || exact) {
            final lat = doc.data()['lat'];
            final lng = doc.data()['lng'];
            final distance = GeoUtils.distance(center, GeoPoint(lat, lng));
            if (exact) {
              if (distance <= radius) {
                doc.data()['distance'] = distance;
                documents.add(doc);
              }
            } else {
              doc.data()['distance'] = distance;
              documents.add(doc);
            }
          } else {
            documents.add(doc);
          }
        });
      });
      return documents;
    } catch (e) {
      print('Failed retrieving data for geo query: ' + e.toString());
      throw e;
    }
  }

  static Query<Map<String, dynamic>> createFirestoreQuery(
      Query<Map<String, dynamic>> collectionReference, GeoHashQuery query) {
    return collectionReference.orderBy('geohash').startAt([query.startValue]).endAt([query.endValue]);
  }

  static List<Query<Map<String, dynamic>>> createFirestoreQueries(
      Query<Map<String, dynamic>> collectionReference, List<GeoHashQuery> queries) {
    return queries
        .map<Query<Map<String, dynamic>>>((query) => createFirestoreQuery(collectionReference, query))
        .toList();
  }
}
