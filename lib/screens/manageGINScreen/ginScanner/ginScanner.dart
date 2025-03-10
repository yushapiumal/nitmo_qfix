import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qfix_nitmo_new/api/apiService.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';

class QRScannerPage extends StatefulWidget {
  final String ginCode;
  final VoidCallback? onReset;
  final String  itemName;
  const QRScannerPage({
    Key? key,
    required this.ginCode,
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
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GIN #${widget.ginCode} ${widget.itemName}'),
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
          Expanded(flex: 1, child: _buildQrView(context)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_flashOn(), _flipCamera()],
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                const SizedBox(height: 14),
                _buildScanResult(),
                if (loadingText) const Text('Loading...'),
                const SizedBox(height: 10),
                _buildScannedItemsList(),
                const SizedBox(height: 10),
                _buildSaveButton(),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _flashOn() {
    return IconButton(
      color: Colors.red,
      icon: Icon(flashOn ? Icons.flashlight_on : Icons.flashlight_off),
      onPressed: () async {
        await cameraController.toggleTorch();
        setState(() {
          flashOn = !flashOn;
        });
      },
    );
  }

  Widget _flipCamera() {
    return IconButton(
      color: Colors.red,
      icon: const Icon(Icons.flip_camera_ios),
      onPressed: () async {
        await cameraController.switchCamera();
        setState(() {
          flipCamera = !flipCamera;
        });
      },
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.itemName.isNotEmpty)
          Text(
            result == null
                ? 'Scan a code'
                : 'Last scanned: ${result!.rawValue} - ${widget.itemName}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          )
        else if (result == null)
          const Text(
            'Scan a code',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          )
        else if (result!.rawValue == widget.itemName)
          Text(
            'Last scanned: ${result!.rawValue}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          )
        else
          Text(
            'Error: "${result!.rawValue}" does not match "${widget.itemName}"',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
      ],
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
      elevation: 2,
      child: ListTile(
        title: Text(cartList[index]['item_name'] ?? 'Unknown Item'),
        subtitle: Text(cartList[index]['description'] ?? 'No description'),
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
  Widget _buildSaveButton() {
    return finalGRNIssueList.isNotEmpty
        ? SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton(
              onPressed: saveBtnDisable ? null : _submitGIN,
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
      await _fetchItemData(scannedCode);
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
  Future<void> _fetchItemData(String scannedCode) async {
    var getBin = await apiService.getBin(scannedCode);
    if (getBin != false) {
      if (!cartList.any((item) => item['bin_no'] == getBin['bin_no'])) {
        setState(() {
          cartList.add({
            "bin_no": getBin['bin_no'].toString(),
            "description": getBin['description'] ?? "-",
            "item_name": getBin['item_name'] ?? "-",
            "uom": getBin['uom'] ?? '',
            "balance": getBin['balance'] ?? 0,
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
    TextEditingController amountController = TextEditingController();
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
  Future<void> _submitGIN() async {
    if (finalGRNIssueList.length != cartList.length) {
      apiService.showToast('Please enter amounts for all items');
      return;
    }
    setState(() => saveBtnDisable = true);

    List lineItems = finalGRNIssueList.values
        .map((val) => {'bin_number': val['scanId'], 'quantity': val['amount']})
        .toList();

    var data = {
      'ref_type': 'GiN',
      'ref_number': widget.ginCode,
      'sid': '5555', // Example SID, adjust as needed
      'line_items': jsonEncode(lineItems),
    };

    bool submit = await apiService.saveStoreLedger('receive', data);
    if (submit) {
      widget.onReset?.call();
      Navigator.pop(context);
    }
    setState(() => saveBtnDisable = false);
  }
}
