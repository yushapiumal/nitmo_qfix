import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';



class MobileQRScanScreen extends StatefulWidget {
  const MobileQRScanScreen({Key? key}) : super(key: key);

  @override
  State<MobileQRScanScreen> createState() => _MobileQRScanScreenState();
}

class _MobileQRScanScreenState extends State<MobileQRScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  MobileScannerController? controller;
    MobileScannerController cameraController = MobileScannerController();
  bool loadingText = true;


  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      cameraController.stop();  // Stop the camera if the app is reassembled
    } else if (Platform.isIOS) {
      cameraController.start(); // Start the camera if the app is reassembled
    }
  }

  String describeEnum(Object enumEntry) {
    if (enumEntry is Enum) {
      return enumEntry.name;
    }
    final String description = enumEntry.toString();
    final int indexOfDot = description.indexOf('.');
    assert(
      indexOfDot != -1 && indexOfDot < description.length - 1,
      'The provided object "$enumEntry" is not an enum.',
    );
    return description.substring(indexOfDot + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsRes.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: ColorsRes.backgroundColor,
        shadowColor: Colors.transparent,
        title: Text(
          'QR SCAN'.toUpperCase(),
          style: const TextStyle(
            color: ColorsRes.violateColor,
            letterSpacing: 4,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size(50, 5),
          child: Divider(
            color: ColorsRes.greyColor,
            height: 2.3,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  // if (result != null)
                  //   Text(
                  //       'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
                  // else
                  //   const Text('Scan a code'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                            onPressed: () async {
                              await cameraController.toggleTorch();
                              setState(() {});
                            },
                            child: FutureBuilder(
                              future: cameraController.switchCamera(),
                              builder: (context, snapshot) {
                                return Text('Flash: ${snapshot.data}');
                              },
                            )),
                      ),
                      // Container(
                      //   margin: const EdgeInsets.all(8),
                      //   child: ElevatedButton(
                      //       onPressed: () async {
                      //         await cameraController.switchCamera();
                      //         setState(() {});
                      //       },
                      //       child: FutureBuilder(
                      //         future: controller?.getCameraInfo(),
                      //         builder: (context, snapshot) {
                      //           if (snapshot.data != null) {
                      //             return Text(
                      //                 'Camera facing ${describeEnum(snapshot.data!)}');
                      //           } else {
                      //             return const Text('loading');
                      //           }
                      //         },
                      //       )),
                      // )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                           // await controller?.pauseCamera();
                          },
                          child: const Text('pause',
                              style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                           // await controller?.resumeCamera();
                          },
                          child: const Text('resume',
                              style: TextStyle(fontSize: 20)),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    //For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
   var scanArea = (MediaQuery.of(context).size.width < 400 ||
           MediaQuery.of(context).size.height < 400)
       ? 200.0
       : 300.0;
  //  To ensure the Scanner view is properly sizes after rotation
   // we need to listen for Flutter SizeChanged notification and update controller
  return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
      ),
      body: Stack(
        children: [
          // MobileScanner widget to scan QR codes
         MobileScanner(
  controller: cameraController,
  onDetect: (BarcodeCapture barcodeCapture) {
    final List<Barcode> barcodes = barcodeCapture.barcodes;
    for (final barcode in barcodes) {
      setState(() {
        result = barcode; // Store the detected barcode
        loadingText = false; // Hide loading text after scan
      });
      if (result != null) {
        _handleScannedResult(result!.rawValue!); // Ensure rawValue is not null
      }
    }
  },
),


          // Custom overlay (cut-out scanner view)
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: scanArea,
                height: scanArea,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 10),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          // Loading text or any other UI on top of scanner
          if (loadingText)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  // Handle the scanned QR code result
  void _handleScannedResult(String result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Scanned Result: $result')),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}