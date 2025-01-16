import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:qfix_nitmo_new/helper/constants.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation = LatLng(6.814726, 79.927905);
  static const LatLng destinationLocation = LatLng(6.816622, 79.937196);

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  void getCurrentLocation() {
    Location location = Location();
    location.getLocation().then((nowLocate) {
      setState(() {
        currentLocation = nowLocate;
      });
    });

    location.onLocationChanged.listen((newLoc) {
      currentLocation = newLoc;
      setState(() {});
    });
  }

  // void getPolyPoint() async {
  //   PolylinePoints polylinePoints = PolylinePoints();

  //   PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //       google_api_key,
  //       PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
  //       PointLatLng(
  //           destinationLocation.latitude, destinationLocation.longitude));
  //   if (result.points.isNotEmpty) {
  //     result.points.forEach((PointLatLng pointLatLng) => polylineCoordinates
  //         .add(LatLng(pointLatLng.latitude, pointLatLng.longitude)));
  //     setState(() {});
  //   }
  // }

  @override
  void initState() {
    getCurrentLocation();
   // getPolyPoint();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MAP SCREEN'),
      ),
      body: currentLocation == null
          ? Text('loading...')
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                  target: LatLng(
                      currentLocation!.latitude!, currentLocation!.longitude!),
                  zoom: 15.5),
              polylines: {
                Polyline(
                    polylineId: PolylineId('route'),
                    points: polylineCoordinates,
                    color: Colors.orange,
                    width: 4)
              },
              markers: {
                Marker(
                    markerId: const MarkerId("currentLocation"),
                    position: LatLng(currentLocation!.latitude!,
                        currentLocation!.longitude!)),
                Marker(markerId: MarkerId("Source"), position: sourceLocation),
                Marker(
                    markerId: MarkerId("Destination"),
                    position: destinationLocation)
              },
            ),
    );
  }
}
