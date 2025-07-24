import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qfix_nitmo_new/api/apiService.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
import 'package:vibration/vibration.dart';
import 'package:qfix_nitmo_new/helper/vibration_helper.dart';

class QRScannerPage extends StatefulWidget {
  final String grnCode;
  final VoidCallback? onReset;
  final String itemName;
  const QRScannerPage({
    Key? key,
    required this.grnCode,
    this.onReset,
    required this.itemName,
  }) : super(key: key);

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final APIService apiService = APIService();
  final MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  Barcode? result; // Latest scanned barcode
  bool flashOn = false;
  bool flipCamera = false;
  bool pause = false;
  bool loadingText = false;
  List<Map<String, dynamic>> cartList = [];
  List<String> scanCodeList = [];
  Map<String, dynamic> finalGRNIssueList = {};
  bool saveBtnDisable = false;
  late TextEditingController amountController;
  bool _hasVibrated = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      cameraController.stop();
    } else if (Platform.isIOS) {
      cameraController.start();
    }
  }

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController();
  }

  @override
  void dispose() {
    cameraController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void _triggerVibration() {
    if (Platform.isAndroid) {
      Vibration.vibrate(duration: 500);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GRN #${widget.grnCode} ${widget.itemName}'),
        centerTitle: true,
        backgroundColor: ColorsRes.backgroundColor,
        leading: IconButton(
          color: Colors.black,
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            widget.onReset?.call();
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(flex: 2, child: _buildQrView(context)),
          Expanded(
              //  flex: 1,
              child: Row(children: [
            BottomAppBar(
                color: Colors.transparent,
                child: Container(
                    color: Colors.transparent,
                    width: MediaQuery.of(context).size.width / 1.1,
                    child: Container(
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0),
                            ),
                            color: Colors.black12),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FlashToggleButton(
                                  flashcameraController: cameraController),
                              FlipCameraButton(
                                  flipcameraController: cameraController),
                              CameraPauseIcon(
                                storeTemplate: true,
                                onPause: () {
                                  print("Camera Paused");
                                },
                                onResume: () {
                                  print("Camera Resumed");
                                },
                                cameraController: cameraController,
                              ),
                            ]))))
          ])),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                const SizedBox(height: 14),
                _buildScanResult(),
                if (loadingText) const Text('Loading...'),
                const SizedBox(height: 10),
                const SizedBox(height: 10),
                _buildSaveButton(0),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // QR Scanner View
  Widget _buildQrView(BuildContext context) {
    var scanArea = MediaQuery.of(context).size.width * 0.5; // Responsive size
    return Stack(
      children: [
        MobileScanner(
          controller: cameraController,
          onDetect: (BarcodeCapture barcodeCapture) {
            setState(() {
              result = barcodeCapture.barcodes.first;
              pause = true;
              loadingText = true;
            });
            if (result != null) {
              _manageScannedQR();
            }
          },
          fit: BoxFit.cover,
        ),
        Center(
          child: Container(
            width: scanArea,
            height: scanArea,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 4),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        if (loadingText) const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  // Display last scanned code
  Widget _buildScanResult() {
    if (result == null || result!.rawValue == widget.itemName) {
      _hasVibrated = false;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (result == null)
          Text(
            'Scan a code${widget.itemName.isNotEmpty ? ' - ${widget.itemName}' : ''}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          )
        else if (result!.rawValue == widget.itemName)
          _buildScannedItemsList()
        else
          _buildErrorDisplay(),
      ],
    );
  }

  Widget _buildErrorDisplay() {
    if (!_hasVibrated) {
      VibrationHelper.triggerVibration();
      _hasVibrated = true;
    }

    return Text(
      'Error: "${result!.rawValue}" does not match "${widget.itemName}"',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.red,
      ),
    );
  }

  // List of scanned items
  Widget _buildScannedItemsList() {
    if (cartList.isEmpty) return const SizedBox();
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: cartList.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) => _buildListItem(index),
      ),
    );
  }

  // Individual scanned item
  Widget _buildListItem(int index) {
    return Card(
      elevation: 3,
      child: ListTile(
        title: Text(cartList[index]['item_name'] ?? 'Unknown Item'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "Max: ${cartList[index]['max_level'] ?? 'not loaded'} ${cartList[index]['uom'] ?? ''}"),
            Text(
                "Min: ${cartList[index]['min_level'] ?? 'not loaded'} ${cartList[index]['uom'] ?? ''}"),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (finalGRNIssueList[cartList[index]['bin_no']] != null)
              Text(
                '${finalGRNIssueList[cartList[index]['bin_no']]['amount']} ${cartList[index]['uom']}',
                style: const TextStyle(color: Colors.green),
              ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  cartList.removeAt(index);
                  scanCodeList.removeAt(index);
                  finalGRNIssueList.remove(cartList[index]['bin_no']);
                });
              },
            ),
          ],
        ),
        onTap: () => _showAmountDialog(index),
      ),
    );
  }

  // Save button
  Widget _buildSaveButton(int index) {
    return finalGRNIssueList.isNotEmpty
        ? SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                double maxLevel = double.tryParse(
                        cartList[index]['max_level']?.toString() ?? '0') ??
                    0;
                double enteredAmount =
                    double.tryParse(amountController.text) ?? 0;
                if (enteredAmount > maxLevel) {
                  _triggerVibration();
                  print("Entered value exceeds the valid limit");
                  Fluttertoast.showToast(
                    msg: "Entered amount exceeds the maximum level!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                } else {
                  print("Amount is within the limit.");
                  if (!saveBtnDisable) {
                    Navigator.pop(context, enteredAmount);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                backgroundColor: Colors.black,
              ),
              child: Text(
                saveBtnDisable ? 'Wait...' : 'Save',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          )
        : const SizedBox();
  }

  // Handle QR scan
  Future<void> _manageScannedQR() async {
    if (result == null || result!.rawValue == null) return;
    String scannedCode = result!.rawValue!;
    setState(() => loadingText = true);
    if (!scanCodeList.contains(scannedCode)) {
      scanCodeList.add(scannedCode);
      apiService.showToast('Scanned successfully');
      await callBin(scannedCode);
    } else {
      apiService.showToast('Already scanned');
      setState(() {
        loadingText = false;
        pause = true;
      });
      await cameraController.stop();
    }
  }

  // Fetch item data from API
  Future<void> callBin(String scannedCode) async {
    var getBin = await apiService.getBin(scannedCode);
    if (getBin != false) {
      if (!cartList.any((item) => item['bin_no'] == getBin['bin_no'])) {
        setState(() {
          cartList.add({
            "bin_no": getBin['bin_no'].toString(),
            "description": getBin['description'] ?? "-",
            "item_name": getBin['item_name'] ?? "-",
            "uom": getBin['uom'] ?? '',
            "max_level": getBin['max_level'] ?? "-",
            "min_level": getBin['min_level'] ?? "-",
          });
          pause = true;
          loadingText = false;
        });
        await cameraController.stop();
      } else {
        apiService.showToast('Item already added');
        setState(() {
          loadingText = false;
          pause = true;
        });
        await cameraController.stop();
      }
    }
  }

  // Show dialog to input amount
  Future<void> _showAmountDialog(int index) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Amount for ${cartList[index]['item_name']}'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Amount'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                finalGRNIssueList[cartList[index]['bin_no']] = {
                  'scanId': cartList[index]['bin_no'],
                  'amount': amountController.text,
                };
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Submit GRN data
  Future<void> _submitGRN() async {
    if (finalGRNIssueList.length != cartList.length) {
      apiService.showToast('Please enter amounts for all items');
      return;
    }
    setState(() => saveBtnDisable = true);
    List lineItems = finalGRNIssueList.values
        .map((val) => {'bin_number': val['scanId'], 'quantity': val['amount']})
        .toList();

    var data = {
      'ref_type': 'GRN',
      'ref_number': widget.grnCode,
      'sid': '5555',
      'line_items': jsonEncode(lineItems),
    };

    bool submit = await apiService.saveStoreLedger('receive', data);
    if (submit) {
      widget.onReset?.call();
      Navigator.pop(context, amountController.text);
    }
    setState(() => saveBtnDisable = false);
  }
}
