import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: QRScannerScreen()));
}

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  List<String> scannedDataList = [];

  @override
  void initState() {
    super.initState();
    _loadScannedData();
  }

  Future<void> _loadScannedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedData = prefs.getStringList('scannedData');
    if (storedData != null) {
      setState(() {
        scannedDataList = storedData;
      });
    }
  }

  Future<void> _saveScannedData(String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!scannedDataList.contains(data)) {
      setState(() {
        scannedDataList.add(data);
      });
      await prefs.setStringList('scannedData', scannedDataList);
    }
  }

  Future<void> _syncToFirebase() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    for (var data in scannedDataList) {
      await firestore.collection('participants').add({
        'data': data,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Synced to Firebase!')));
  }

  void _onScan(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      String data = barcodes.first.rawValue ?? "Unknown";
      _saveScannedData(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("QR Scanner",style: TextStyle(fontWeight: FontWeight.bold))
      ,           backgroundColor: Colors.grey, centerTitle: true,),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Container(
  margin: EdgeInsets.all(20),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12), // Rounded Corners
    color: Colors.white, // Background color for clarity
    boxShadow: [
      BoxShadow(
        color: Colors.black26, 
        blurRadius: 6, 
        offset: Offset(2, 2), // Soft Shadow for Depth
      ),
    ],
    border: Border(
      top: BorderSide.none, // No border on top
      left: BorderSide(color: Colors.black, width: 4), // Border on Left
      right: BorderSide(color: Colors.black, width: 4), // Border on Right
      bottom: BorderSide.none, // No border on Bottom
    ),
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(12), // Ensures Scanner Stays Rounded
    child: MobileScanner(controller: cameraController, onDetect: _onScan),
  ),
),
          ),
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: scannedDataList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(scannedDataList[index]),
                  leading: Icon(Icons.qr_code, color: const Color.fromARGB(255, 86, 86, 86)),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _syncToFirebase,
            child: Text("Sync to Firebase"),
          ),
        ],
      ),
    );
  }
}
