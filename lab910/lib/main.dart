import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'models/geo_location.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  List<GeoLocation> locations = [];// Placeholder array for GeoLocation objects
  MapController? mapController;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  void _zoomIn() {
    if (mapController != null) {
      mapController!.move(mapController!.camera.center, mapController!.camera.zoom + 1);
    }
  }

  void _zoomOut() {
    if (mapController != null) {
      mapController!.move(mapController!.camera.center, mapController!.camera.zoom - 1);
    }
  }

  Future<void> _getCurrentLocation() async {
    if (await _requestPermission()) {
      // Permission has been granted, proceed with getting the location
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        Placemark placemark = placemarks[0];
        String name = placemark.name ?? 'Unknown place';
        String address = '${placemark.subThoroughfare} ${placemark.thoroughfare}';
        GeoLocation newLocation =
        GeoLocation(name: name, address: address, latlng: LatLng(position.latitude, position.longitude));
        setState(() {
          locations.add(newLocation);
        });
      } catch (e) {
        // Handle errors that may occur during location retrieval
        print('Error getting location: $e');
      }
    } else {
      // Handle the case when the user denies permission
      print('Permission not granted');
    }
  }

  Future<bool> _requestPermission() async {
    var status = await Permission.location.request();
    return status == PermissionStatus.granted;
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fitness Tracking App'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                _getCurrentLocation();
              },
            ),
            IconButton(
              icon: const Icon(Icons.zoom_in),
              onPressed: () {
               _zoomIn();
              },
            ),
            IconButton(
              icon: const Icon(Icons.zoom_out),
              onPressed: () {
                _zoomOut();
              },
            ),
          ],
        ),
        body: FlutterMap(
          mapController: mapController,
          options: mapController != null
          ? const MapOptions(
            minZoom: 4.0,
            maxZoom: 18.0,
          ) : const MapOptions(),
          children: [
            TileLayer(
              urlTemplate: 'https://api.mapbox.com/styles/v1/carterantro/cloq1cfno008n01nw5lyj26no/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiY2FydGVyYW50cm8iLCJhIjoiY2xvcHl5YXA0MGFkNDJrbzFjbmphZzd4aSJ9.bnBc-hBoZePLv7SfK_QJVA',
              additionalOptions: const {
                'access_Token': 'pk.eyJ1IjoiY2FydGVyYW50cm8iLCJhIjoiY2xvcHl5YXA0MGFkNDJrbzFjbmphZzd4aSJ9.bnBc-hBoZePLv7SfK_QJVA',
                'id': 'mapbox/streets-v11',
              },
            ),
            MarkerLayer(
              markers: locations
                  .map((loc) => Marker(
                width: 40.0,
                height: 40.0,
                point: loc.latlng,
                child: const Icon(Icons.circle, color: Colors.blueAccent),
              ))
                  .toList(),
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: locations.map((loc) => loc.latlng).toList(),
                  color: Colors.blue,
                  strokeWidth: 4.0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}