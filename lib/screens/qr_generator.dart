import 'dart:io';
import 'dart:typed_data';
import 'dart:convert'; // ✅ Import for jsonDecode
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // ✅ Import for MediaType
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRGenerator {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String cloudName = "dctn41obg";
  final String uploadPreset = "unsigned_preset"; // Cloudinary preset

  Future<String?> uploadToCloudinary(File imageFile) async {
    try {
      final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
      
      var request = http.MultipartRequest("POST", uri);
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = "event_qrcodes"; 

      // Attach file
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType.parse(lookupMimeType(imageFile.path) ?? 'image/png'),
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final uploadedData = jsonDecode(responseData);
        return uploadedData["secure_url"]; // Cloudinary URL
      } else {
        print("Cloudinary Upload Failed: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      print("Error Uploading to Cloudinary: $e");
      return null;
    }
  }

  Future<void> generateAndStoreQRCode({
    required String name,
    required String email,
    required String college,
    required String eventName,
  }) async {
    final File qrFile = await generateQRCode(name, email, college, eventName);
    final String? qrUrl = await uploadToCloudinary(qrFile);

    try {
  await _firestore.collection("registered_events").doc(email.replaceAll('.', '_')).set({
    "name": name,
    "email": email,
    "college": college,
    "event": eventName,
    "qr_code_url": qrUrl,
    "timestamp": FieldValue.serverTimestamp(),
  });
  print("✅ QR Code stored in Firestore!");
} catch (e) {
  print("❌ Firestore Write Error: $e");
}
  }

  static Future<File> generateQRCode(String name, String email, String college, String eventName) async {
    final tempDir = await getTemporaryDirectory();
    final filePath = "${tempDir.path}/$name-qrcode.png";
    final qrData = "Name: $name\nEmail: $email\nCollege: $college\nEvent: $eventName";

    final qrImage = await QrPainter(
      data: qrData,
      version: QrVersions.auto,
      gapless: false,
      color: Colors.black,
      emptyColor: Colors.white,
    ).toImageData(400);

    final qrBytes = qrImage!.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(qrBytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image qrCodeImage = frameInfo.image;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(500, 500),
        [
          Colors.pink.shade400,
          Colors.orange.shade400,
          Colors.yellow.shade400,
        ],
        [0.0, 0.5, 1.0],
      );

    canvas.drawRect(Rect.fromLTWH(0, 0, 500, 500), paint);

    final double qrSize = 350;
    final double centerX = (500 - qrSize) / 2;
    final double centerY = (500 - qrSize) / 2;

    final paintQr = Paint();
    canvas.drawImageRect(
      qrCodeImage,
      Rect.fromLTWH(0, 0, qrCodeImage.width.toDouble(), qrCodeImage.height.toDouble()),
      Rect.fromLTWH(centerX, centerY, qrSize, qrSize),
      paintQr,
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(500, 500);
    final ByteData? byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    final file = File(filePath);
    await file.writeAsBytes(pngBytes);
    return file;
  }
}
