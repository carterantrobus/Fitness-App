import 'package:latlong2/latlong.dart';

class GeoLocation {
  final String name;
  final String address;
  final LatLng latlng;

  GeoLocation({required this.name, required this.address, required this.latlng});
}