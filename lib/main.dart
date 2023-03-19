import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MapSample());
  }
}

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  @override
  void initState() {
    getCurrentLocation();
    setCustomMarkerIcon();
    // getPolylinePoints();
    super.initState();
  }

  //////static aayt chumma kodukkunna source and destination location
  static const LatLng sourceLocation =
      LatLng(10.9760, 76.2254); //perinthalmanna
  static const LatLng destinationLocation =
      LatLng(11.0317, 76.9778); //coimbatore

/////////////////////////////////poly lines varakkaan vendi between source and destination (currently not working ,because API key is not available) /////////////////////////
  // List<LatLng> polyLineCoordinates = [];
  // void getPolylinePoints() async {
  //   PolylinePoints polylinePoints = PolylinePoints();
  //   PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //       "AIzaSyAd4rEAQqf58fCJGABqW99teDP9BcuyN08",
  //       PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
  //       PointLatLng(
  //           destinationLocation.latitude, destinationLocation.longitude));
  //   log(result.points.toString());
  //   if (result.points.isNotEmpty) {
  //     for (var points in result.points) {
  //       polyLineCoordinates.add(LatLng(points.latitude, points.longitude));
  //     }
  //   } else {}
  // }
  //////////////////////////////////////////////////////////////////////////////////////////

//////////////////////for current location and for listening location change/////////////////////////
  LocationData? currentLocation;
  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then((location) {
      currentLocation = location;

      setState(() {});
    });

    GoogleMapController googleMapController = await _controller.future;
    location.onLocationChanged.listen((newLoc) {
      currentLocation = newLoc;

      ////map camera location change nu anusarich change aavan vendi
      googleMapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              zoom: 9, target: LatLng(newLoc.latitude!, newLoc.longitude!))));

      setState(() {});
    });
  }
///////////////////////////////////////////////////////////////////////////////////////////////////

  /////////for changing marker images in map
  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentIcon = BitmapDescriptor.defaultMarker;
  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/images/start.png")
        .then((icon) => sourceIcon = icon);
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/images/end.png")
        .then((icon) => destinationIcon = icon);
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/images/current.png")
        .then((icon) => currentIcon = icon);
  }
//////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentLocation == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GoogleMap(
              mapToolbarEnabled: true,
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    currentLocation!.latitude!, currentLocation!.longitude!),
                zoom: 8,
              ),
              // polylines: {
              //   Polyline(
              //       polylineId: const PolylineId("route"),
              //       points: polyLineCoordinates)
              // },
              markers: {
                Marker(
                    icon: sourceIcon,
                    markerId: const MarkerId("source"),
                    position: sourceLocation),
                Marker(
                    icon: destinationIcon,
                    markerId: const MarkerId("destination"),
                    position: destinationLocation),
                Marker(
                    icon: currentIcon,
                    markerId: const MarkerId("current"),
                    position: LatLng(currentLocation!.latitude!,
                        currentLocation!.longitude!))
              },
              ///////current location change aavumbo map athinte kooode povaan vendi
              onMapCreated: (mapController) {
                _controller.complete(mapController);
              },
            ),
    );
  }
}
