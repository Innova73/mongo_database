import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mongo_database/service/decode_encoded_polyline.dart';

Future<List<LatLng>> getRouteCoordinates(LatLng start, LatLng end) async {
  try {
    String googleApiKey = "AIzaSyDLtxyjsNjyt_cPwvaPJHagqbOTyVMtlL0";
    Dio dio = Dio();
    Response response = await dio.get(
      'https://maps.googleapis.com/maps/api/directions/json',
      queryParameters: {
        'origin': '${start.latitude},${start.longitude}',
        'destination': '${end.latitude},${end.longitude}',
        'key': googleApiKey,
        'units': 'metric',
        'mode': 'driving',
      },
    );

    if (response.statusCode == 200) {
      String encodedPoly = response.data['routes'][0]['overview_polyline']['points'];
      return decodeEncodedPolyline(encodedPoly);
    } else {
      print('Errore nella richiesta al Google Directions API: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print("Errore nella chiamata a Google Directions API: $e");
    return [];
  }
}
