import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> createCustomMarkerBitmap(String title, Color markerColor) async {
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);
  final double width = 220; // Larghezza aumentata per contenere testo e icona
  final double height = 100;

  // Crea la forma del marker
  final Path path = Path();
  // Parte superiore del marker (la "goccia")
  path.moveTo(width * 0.5, 0);
  path.quadraticBezierTo(width * 0.6, height * 0.2, width * 0.5, height * 0.4);
  path.quadraticBezierTo(width * 0.4, height * 0.2, width * 0.5, 0);
  // Parte inferiore del marker (l'"ombra")
  path.moveTo(width * 0.5, height * 0.4);
  path.quadraticBezierTo(width * 0.5, height * 0.6, width * 0.65, height * 0.6);
  path.quadraticBezierTo(width * 0.5, height * 0.8, width * 0.5, height * 0.4);

  // Riempie la forma con il colore desiderato
  final Paint paint = Paint()..color = markerColor;
  canvas.drawPath(path, paint);

  // Disegna il testo accanto all'icona
  final textPainter = TextPainter(
    text: TextSpan(
      text: title,
      style: TextStyle(fontSize: 40, color: Colors.black, fontWeight: FontWeight.bold),
    ),
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();
  textPainter.paint(canvas, Offset(height, (height - textPainter.height) / 2));

  // Finalizza il disegno e crea l'icona
  final ui.Image image = await recorder.endRecording().toImage(width.toInt(), height.toInt());
  final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List uint8List = byteData!.buffer.asUint8List();

  return BitmapDescriptor.fromBytes(uint8List);
}
