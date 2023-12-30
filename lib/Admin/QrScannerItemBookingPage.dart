import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ItemBookingDetailsShowPage.dart';

class QrScannerPageItemBooking extends StatefulWidget {
  @override
  _QrScannerPageState createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPageItemBooking> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isCameraGranted = false;
  String qrCode = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    initializeFirebase();
    requestCameraPermission();
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void requestCameraPermission() async {
    var status = await Permission.camera.request();
    setState(() {
      isCameraGranted = status.isGranted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Scanner'),
      ),
      body: Stack(
        children: [
          if (isCameraGranted) _buildQrView(context),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'Scan the QR code',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (isCameraGranted) // Add the focus box widget
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.green,
                    width: 2.0,
                  ),
                ),
                margin: EdgeInsets.all(20.0),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    if (!isCameraGranted) {
      return Center(
        child: Text(
          'Camera permission not granted',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    bool dataFetched = false; // Keep track of whether data has been fetched

    controller.scannedDataStream.listen((scanData) {
      if (!dataFetched) {
        // Only proceed if data hasn't been fetched yet
        setState(() {
          qrCode = scanData.code!;
        });

        // Fetch data and navigate to BookingDetailsShowPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemBookingDetailsPage(qrCode: qrCode),
          ),
        );

        dataFetched = true; // Mark data as fetched
      }
    });
  }
}
