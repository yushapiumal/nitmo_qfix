import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:location/location.dart';

LocationData? currentLocation;
Location location = Location();
StreamSubscription<LocationData>? locationSubscription;
var randNo = 0;
final LocalStorage storage = LocalStorage('qfix');
late DatabaseReference dbRef;
var lastId = null;
void initLocations() {
  location.getLocation().then((nowLocate) {
    currentLocation = nowLocate;
  });
}

getCurrentLocation(state, locData, existRefIds) async {
  var rng = Random();
  rng.nextInt(999999);
  randNo = rng.nextInt(999999) + int.parse(locData['timestamp']);
  locData['start_latitude'] = currentLocation!.latitude!.toString();
  locData['start_longitude'] = currentLocation!.longitude!.toString();

  var database = FirebaseDatabase.instance.ref().child("Locations/$randNo");

  if (state) {
    database.set(locData).whenComplete(() {
      locationSubscription = location.onLocationChanged.listen((newLoc) {
        currentLocation = newLoc;
        var navArray = {
          'latitude': currentLocation!.latitude!,
          'longitude': currentLocation!.longitude!,
          'utc': DateTime.now().millisecondsSinceEpoch,
          'speed': currentLocation!.speed,
        };
        var newDataRef = database.child('navigation');
        var newPostRef = newDataRef.push();
        newPostRef.update(navArray);
      });
    });
  } else {
    locationSubscription!.cancel();
    for (var i = 0; i < existRefIds.length; i++) {
      var db = FirebaseDatabase.instance
          .ref()
          .child("Locations/" + existRefIds[i].toString());
      await db.update({
        "status": Icons.trending_up_rounded,
      });
    }
  }
}

getLastTrackingRef() {
  return randNo;
}
