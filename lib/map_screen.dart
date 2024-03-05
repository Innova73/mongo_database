import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mongo_database/models/milazzo_path_model.dart';
import 'package:http/http.dart' as http;
class MapScreen extends StatefulWidget {
  final PathMilazzo path;

  MapScreen({required this.path});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late List<LatLng> _routeCoordinates;
  Set<Marker> _markers = {};
  late GoogleMapController _mapController;
  bool _isMarkersInitialized = false;
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _initializeRouteAndMarkers();
  }

  Future<void> _initializeRouteAndMarkers() async {
    _routeCoordinates = widget.path.datiGeoJSON.features.map((feature) => LatLng(feature.geometry.coordinates[1], feature.geometry.coordinates[0])).toList();
    _markers =  await _createMarkers();
    setState(() {
      _isMarkersInitialized = true;
    });
  }

  Set<Marker> _createMarkers() {
    Set<Marker> markers = {};

    // Aggiungi marker verde per l'inizio
    markers.add(Marker(
      markerId: MarkerId("start"),
      position: _routeCoordinates.first,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(
          title: widget.path.datiGeoJSON.features.first.properties.name,
          snippet: _routeCoordinates.first.toString()
      ), // Nome del punto di inizio
    ));

    // Aggiungi marker arancio per i punti intermedi
    for (int i = 1; i < _routeCoordinates.length - 1; i++) {
      markers.add(Marker(
        markerId: MarkerId("intermediate_$i"),
        position: _routeCoordinates[i],
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: InfoWindow(
            title: widget.path.datiGeoJSON.features[i].properties.name,
            snippet: _routeCoordinates[i].toString()
        ), // Nome del punto intermedio
      ));
    }

    // Aggiungi marker rosso per la fine
    markers.add(Marker(
      markerId: MarkerId("end"),
      position: _routeCoordinates.last,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(
          title: widget.path.datiGeoJSON.features.last.properties.name,
          snippet: _routeCoordinates.last.toString()
      ), // Nome del punto di fine
    ));

    return markers;
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _drawRoute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dettagli Percorso')),
      body: _isMarkersInitialized
          ? GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(target: _routeCoordinates.first, zoom: 13),
        markers: _markers,
        polylines: _polylines,
      ): Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _drawRoute() async {
    String url = _buildDirectionsUrl();
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map data = json.decode(response.body);
      var points = data['routes'][0]['overview_polyline']['points'];
      var decodedPolyline = _decodePolyline(points);

      if (response.statusCode == 200) {
        Map data = json.decode(response.body);
        var points = data['routes'][0]['overview_polyline']['points'];
        var decodedPolyline = _decodePolyline(points);

        setState(() {
          _polylines.add(
            Polyline(
              polylineId: PolylineId("route"),
              points: decodedPolyline,
              color: Colors.blue,
              width: 5,
            ),
          );
        });

      } else {
        throw Exception('Failed to load directions');
      }
    } else {
      throw Exception('Failed to load directions');
    }
  }

  String _buildDirectionsUrl() {
    String googleApiKey = "AIzaSyDLtxyjsNjyt_cPwvaPJHagqbOTyVMtlL0";
    LatLng start = _routeCoordinates.first;
    LatLng end = _routeCoordinates.last;
    String waypoints = _routeCoordinates.sublist(1, _routeCoordinates.length - 1).map((point) => '${point.latitude},${point.longitude}').join('|');

    return 'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&waypoints=optimize:true|$waypoints&key=$googleApiKey';
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      LatLng point = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      points.add(point);
    }

    return points;
  }
}
