import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
//import 'package:qr_code_scanner/qr_code_scanner.dart';


class MobileQRScanScreen extends StatefulWidget {
  const MobileQRScanScreen({Key? key}) : super(key: key);

  @override
  State<MobileQRScanScreen> createState() => _MobileQRScanScreenState();
}

class _MobileQRScanScreenState extends State<MobileQRScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//  Barcode? result;
 // QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      //controller!.pauseCamera();
    } else if (Platform.isIOS) {
     // controller!.resumeCamera();
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
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: ColorsRes.backgroundColor,
        shadowColor: Colors.transparent,
        title: Text(
          'QR SCAN'.toUpperCase(),
          style: TextStyle(
            color: ColorsRes.violateColor,
            letterSpacing: 4,
          ),
        ),
        bottom: PreferredSize(
          child: Divider(
            color: ColorsRes.greyColor,
            height: 2.3,
          ),
          preferredSize: Size(50, 5),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: <Widget>[
        //  Expanded(flex: 4, child: _buildQrView(context)),
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
                        // child: ElevatedButton(
                        //     onPressed: () async {
                        //     //  await controller?.toggleFlash();
                        //       setState(() {});
                        //     },
                           
                        //    ),
                      ),
                   //   Container(
                    //    margin: const EdgeInsets.all(8),
                       // child: ElevatedButton(
                         //   onPressed: () async {
                             // await controller?.flipCamera();
                            //  setState(() {});
                          //  },
                            // child: FutureBuilder(
                            //   future: controller?.getCameraInfo(),
                            //   builder: (context, snapshot) {
                            //     if (snapshot.data != null) {
                            //       return Text(
                            //           'Camera facing ${describeEnum(snapshot.data!)}');
                            //     } else {
                            //       return const Text('loading');
                            //     }
                            //   },
                            // )
                       //     ),
                    //  )
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

  //Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
  //  var scanArea = (MediaQuery.of(context).size.width < 400 ||
    //        MediaQuery.of(context).size.height < 400)
     //   ? 200.0
     //   : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    // return QRView(
    //   key: qrKey,
    //   onQRViewCreated: _onQRViewCreated,
    //   overlay: QrScannerOverlayShape(
    //     borderColor: Colors.red,
    //     borderRadius: 10,
    //     borderLength: 30,
    //     borderWidth: 10,
    //     cutOutSize: scanArea,
    //   ),
    //   onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    // );
 // }

  // void _onQRViewCreated(QRViewController controller) {
  //   setState(() {
  //     this.controller = controller;
  //   });
  //   controller.scannedDataStream.listen((scanData) {
  //     setState(() {
  //       result = scanData;
  //     });
  //   });
  // }

  // void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
  //   print('${DateTime.now().toIso8601String()}_onPermissionSet $p');
  //   if (!p) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('no Permission')),
  //     );
  //   }
  // }

  @override
  void dispose() {
    //controller?.dispose();
    super.dispose();
  }
}
