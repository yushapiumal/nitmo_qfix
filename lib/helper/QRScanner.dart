import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qfix_nitmo_new/api/apiService.dart';
import 'package:qfix_nitmo_new/helper/Bottom.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
import 'package:qfix_nitmo_new/helper/Slidable.dart';
import 'package:qfix_nitmo_new/helper/Slide_action.dart';
import 'package:qfix_nitmo_new/screens/manageGRNScreen/manageGRNScreen.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({
    required this.ginTemplate,
    this.storeTemplate,
    this.grnTemplate,
    this.grnCode,
    this.refNo,
    this.prnNo,
    this.formReset,
  });

  final bool ginTemplate;
  final bool? storeTemplate;
  final bool? grnTemplate;
  final String? grnCode;
  final String? refNo;
  final String? prnNo;
  final VoidCallback? formReset;

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> with TickerProviderStateMixin {
  final APIService apiService = APIService();
  final MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  Barcode? result;
  bool flashOn = false;
  bool flipCamera = false;
  bool pause = false;
  bool isCardOpen = false;
  List cartList = [];
  List scanCodeList = [];
  int currentIndex = 0;
  int itemCount = 0;
  bool saveBtnDisable = false;
  bool loadingText = false;
  TextEditingController amountController = TextEditingController();
  final SlidableController slidableController = SlidableController();

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      cameraController.stop();
    } else if (Platform.isIOS) {
      cameraController.start();
    }
  }
  // String describeEnum(Object enumEntry) {
  //   if (enumEntry is Enum) {
  //     return enumEntry.name;
  //   }
  //   final String description = enumEntry.toString();
  //   final int indexOfDot = description.indexOf('.');
  //   assert(
  //     indexOfDot != -1 && indexOfDot < description.length - 1,
  //     'The provided object "$enumEntry" is not an enum.',
  //   );
  //   return description.substring(indexOfDot + 1);
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(flex: 1, child: _buildQrView(context)),
        Expanded(
          flex: 3,
          child: Column(
            children: [
              Row(
                children: [
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
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () async {
                                await cameraController.toggleTorch();
                                setState(() {
                                  flashOn = !flashOn;
                                });
                              },
                              iconSize: 27.0,
                              icon: Icon(
                                Icons.flashlight_on_outlined,
                                color: !flashOn
                                    ? ColorsRes.black
                                    : ColorsRes.secondaryButton,
                                size: 35,
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                await cameraController.switchCamera();
                                setState(() {
                                  flipCamera = !flipCamera;
                                });
                              },
                              iconSize: 27.0,
                              icon: Icon(
                                Icons.flip_camera_ios_outlined,
                                color: !flipCamera
                                    ? ColorsRes.black
                                    : ColorsRes.secondaryButton,
                                size: 35,
                              ),
                            ),
                            cameraPauseIcon(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (result == null)
                    const Center(
                      child: Text(
                        'Scan a code',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    Center(
                      child: Text('Last scanned code: ${result!.rawValue}'),
                    ),
                ],
              ),
              if (loadingText) const Text('Loading...'),
              const SizedBox(height: 5),
              widget.ginTemplate ? showGINTemplate() : const SizedBox(),
              widget.grnTemplate ?? false
                  ? showGRNTemplate()
                  : const SizedBox(),
              widget.storeTemplate ?? false
                  ? showStoreTemplate()
                  : const SizedBox(),
              const SizedBox(height: 10),
              saveBTN(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }

  Widget cameraPauseIcon() {
    if (widget.storeTemplate ?? false) {
      return IconButton(
        onPressed: () async {
          if (!pause) {
            await cameraController.stop();
            setState(() {
              pause = true;
              cartList = [];
              scanCodeList = [];
              result = null;
            });
          } else {
            await cameraController.start();
            setState(() {
              pause = false;
              cartList = [];
              scanCodeList = [];
              result = null;
            });
          }
        },
        iconSize: 27.0,
        icon: Icon(
          pause ? Icons.check_circle_outline : Icons.qr_code,
          color: pause ? ColorsRes.secondaryButton : ColorsRes.black,
          size: 35,
        ),
      );
    }
    return IconButton(
      onPressed: () async {
        if (!pause) {
          await cameraController.stop();
          setState(() {
            pause = true;
          });
        } else {
          await cameraController.start();
          setState(() {
            pause = false;
          });
        }
      },
      iconSize: 27.0,
      icon: Icon(
        pause ? Icons.check_circle_outline : Icons.qr_code,
        color: pause ? ColorsRes.secondaryButton : ColorsRes.black,
        size: 35,
      ),
    );
  }

  Widget saveBTN() {
    if (widget.ginTemplate) {
      return finalGINIssueList.isNotEmpty
          ? SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: saveBtnDisable ? null : submitGINote,
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
    if (widget.grnTemplate ?? false) {
      return finalGRNIssueList.isNotEmpty
          ? SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: saveBtnDisable ? null : submitGRNote,
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
    return const SizedBox();
  }

  Widget showGINTemplate() {
    if (scanCodeList.isEmpty) return const SizedBox();
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: cartList.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) => listItem(index),
      ),
    );
  }

  Widget showGRNTemplate() {
    if (result == null) return const SizedBox();
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: cartList.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) => listItem(index),
      ),
    );
  }

  Widget showStoreTemplate() {
    if (result == null) return const SizedBox();
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: cartList.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) => showStoreData(index),
    );
  }

  Widget showStoreData(int index) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsetsDirectional.only(top: 15, start: 10, end: 10),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'Added on ${cartList[index]['created_on']}',
                  style: const TextStyle(
                    color: ColorsRes.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsetsDirectional.only(
                    start: 5, top: 5, bottom: 5),
                child: GestureDetector(
                  child: Text(
                    cartList[index]['category'],
                    style: const TextStyle(
                      color: ColorsRes.yellowColor,
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.40,
          child: SingleChildScrollView(
            child: itemData(index),
          ),
        ),
      ],
    );
  }

  Widget itemData(int index) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          cartList[index]['description'],
          style: const TextStyle(
            fontSize: 16,
            color: ColorsRes.black,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        textBox(Icons.tag, 'BIN No', cartList[index]['bin_no']),
        textBox(Icons.location_pin, 'Location', cartList[index]['location']),
        textBox(Icons.check, 'Balance',
            '${cartList[index]['balance']} ${cartList[index]['uom']}'),
        textBox(Icons.other_houses_outlined, 'Reorder',
            '${cartList[index]['reorder_level']} ${cartList[index]['uom']}'),
        textBox(Icons.minimize_outlined, 'Min',
            '${cartList[index]['min_level']} ${cartList[index]['uom']}'),
        textBox(Icons.published_with_changes_rounded, 'Max',
            '${cartList[index]['max_level']} ${cartList[index]['uom']}'),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget textBox(IconData icon, String text, String amount) {
    return Padding(
      padding: const EdgeInsets.only(left: 1),
      child: ListTile(
        title: Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: ColorsRes.black,
            fontWeight: FontWeight.normal,
            letterSpacing: 0.5,
            fontSize: 16,
          ),
        ),
        trailing: Text(
          amount,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: ColorsRes.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget listItem(int index) {
    return Card(
      elevation: 0.1,
      child: Slidable(
        key: Key(cartList[index]["bin_no"]),
        direction: Axis.horizontal,
        controller: slidableController,
        slideToDismissDelegate: SlideToDismissDrawerDelegate(
          onWillDismiss: (actionType) async {
            if (actionType == SlideActionType.primary) {
              setState(() {
                flashOn = false;
                pause = true;
                isCardOpen = true;
                flipCamera = false;
              });
              await cameraController.stop();
              showBarCard(index, cartList[index]);
            } else {
              setState(() {
                flashOn = false;
                pause = true;
                isCardOpen = true;
                flipCamera = false;
              });
              await cameraController.stop();
              removeFromList(cartList[index]["bin_no"]);
              cartList.removeWhere(
                  (element) => element['bin_no'] == cartList[index]["bin_no"]);
            }
            return false;
          },
        ),
        delegate: const SlidableBehindDelegate(),
        actionExtentRatio: 0.25,
        actions: [
          IconSlideAction(
            fontSize: 14,
            caption: 'Add Amount',
            color: const Color.fromARGB(255, 1, 203, 85),
            icon: Icons.check_circle_outline_sharp,
            onTap: () async {
              setState(() {
                flashOn = false;
                pause = true;
                isCardOpen = true;
                flipCamera = false;
              });
              await cameraController.stop();
              showBarCard(index, cartList[index]);
            },
          ),
        ],
        secondaryActions: [
          IconSlideAction(
            fontSize: 14,
            caption: 'Remove',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () async {
              setState(() {
                flashOn = false;
                pause = true;
                isCardOpen = true;
                flipCamera = false;
              });
              await cameraController.stop();
              removeFromList(cartList[index]["bin_no"]);
              cartList.removeWhere(
                  (element) => element['bin_no'] == cartList[index]["bin_no"]);
            },
          ),
        ],
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(cartList[index]["item_name"]),
                        const SizedBox(height: 10),
                        Text(cartList[index]["description"]),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        showQuantity(index),
                        const SizedBox(height: 10),
                        Text(
                          cartList[index]["created_on"],
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget showQuantity(int index) {
    if (widget.ginTemplate) {
      if (finalGINIssueList[cartList[index]["bin_no"]] != null) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${finalGINIssueList[cartList[index]["bin_no"]]['amount']} ${cartList[index]["uom"]}',
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
              style: const TextStyle(color: Colors.red),
            ),
            const Text(' / '),
            Text(
              '${cartList[index]["balance"]} ${cartList[index]["uom"]}',
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
          ],
        );
      }
      return Text(
        '${cartList[index]["balance"]} ${cartList[index]["uom"]}',
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.fade,
      );
    }
    if (widget.grnTemplate ?? false) {
      if (finalGRNIssueList[cartList[index]["bin_no"]] != null) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${finalGRNIssueList[cartList[index]["bin_no"]]['amount']} ${cartList[index]["uom"]}',
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
              style: const TextStyle(color: Colors.green),
            ),
            const Text(' / '),
            Text(
              '${cartList[index]["balance"]} ${cartList[index]["uom"]}',
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
          ],
        );
      }
      return Text(
        '${cartList[index]["balance"]} ${cartList[index]["uom"]}',
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.fade,
      );
    }
    return const SizedBox();
  }

  void closeCard() async {
    setState(() {
      flashOn = false;
      pause = false;
      isCardOpen = false;
      flipCamera = false;
    });
    await cameraController.start();
  }

  Map<String, dynamic> finalGINIssueList = {};
  Map<String, dynamic> finalGRNIssueList = {};

  void submitFromBottomCard(int index, String scanId, dynamic issueData) {
    if (widget.ginTemplate) {
      finalGINIssueList[scanId] = issueData;
    }
    if (widget.grnTemplate ?? false) {
      finalGRNIssueList[scanId] = issueData;
    }
  }

  void removeFromList(String binNo) {
    if (widget.ginTemplate) {
      finalGINIssueList.remove(binNo);
    }
    if (widget.grnTemplate ?? false) {
      finalGRNIssueList.remove(binNo);
    }
    scanCodeList.remove(binNo);
  }

  Future<void> submitGINote() async {
    if (finalGINIssueList.length != cartList.length) {
      await apiService
          .showToast('GIN is not complete. Please complete the list');
      return;
    }
    setState(() => saveBtnDisable = true);
    List lineItems = finalGINIssueList.values
        .map((val) => {'bin_number': val['scanId'], 'quantity': val['amount']})
        .toList();

    var data = {
      'ref_type': 'GIN',
      'ref_number': widget.refNo,
      'sid': '5555',
      'line_items': jsonEncode(lineItems),
    };

    bool submit = await apiService.saveStoreLedger('issue', data);
    if (submit) {
      widget.formReset?.call();
    }
    setState(() => saveBtnDisable = false);
  }

  Future<void> submitGRNote() async {
    if (finalGRNIssueList.length != cartList.length) {
      await apiService
          .showToast('GRN is not complete. Please complete the list');
      return;
    }
    setState(() => saveBtnDisable = true);
    List lineItems = finalGRNIssueList.values
        .map((val) => {'bin_number': val['scanId'], 'quantity': val['amount']})
        .toList();

    var data = {
      'ref_type': 'GRN',
      'ref_number': widget.refNo,
      'prn_number': widget.prnNo,
      'sid': '5555',
      'line_items': jsonEncode(lineItems),
    };

    bool submit = await apiService.saveStoreLedger('receive', data);
    if (submit) {
      widget.formReset?.call();
      Navigator.pushNamed(context, ManageGRNScreen.routeName);
    }
    setState(() => saveBtnDisable = false);
  }

  Future<void> showBarCard(int index, dynamic item) {
    return showModalBottomSheet(
      elevation: 0,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(50.0),
          topRight: Radius.circular(50.0),
        ),
      ),
      context: context,
      builder: (context) => MyBottomSheet(
        closeCard: closeCard,
        submitFromBottomCard: submitFromBottomCard,
        gin: widget.ginTemplate,
        grn: widget.grnTemplate ?? false,
        item: item,
        grnCode: widget.grnCode,
        index: index,
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 300 ||
            MediaQuery.of(context).size.height < 300)
        ? 150.0
        : 150.0;

    return Stack(
      children: [
        MobileScanner(
          controller: cameraController,
          onDetect: (BarcodeCapture barcodeCapture) {
            setState(() {
              result = barcodeCapture
                  .barcodes.first; // Correctly assign Barcode object
              pause = true;
              loadingText = true;
            });
            if (result != null) {
              manageScannedQR();
            }
          },
          fit: BoxFit.cover,
        ),
        Center(
          child: Container(
            width: scanArea,
            height: scanArea,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 10),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        if (loadingText) const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Future<void> manageScannedQR() async {
    if (result == null || result!.rawValue == null) return;

    String scannedCode = result!.rawValue!;
    setState(() => loadingText = true);
    print('get=============>$scannedCode');

    if (!scanCodeList.contains(scannedCode)) {
      scanCodeList.add(scannedCode);
      apiService.showToast('Scanned successfully');
      print('Scanned successfully: $scannedCode');
    } else {
      apiService.showToast('Already scanned');
      print('Already scanned: $scannedCode');
      setState(() {
        loadingText = false;
        pause = true;
      });
      await cameraController.stop();
      return;
    }

    if (widget.ginTemplate ||
        (widget.grnTemplate ?? false) ||
        (widget.storeTemplate ?? false)) {
      await callBin();
      print("object");
      print(widget.storeTemplate);
      print(widget.grnTemplate);
      print(widget.ginTemplate);
    }
  }

  Future<void> callBin() async {
    String lastCode = scanCodeList.isEmpty ? '' : scanCodeList.last;
    var getBin = await apiService.getBin(lastCode);
    print('get1=============>$getBin');

    if (getBin != false) {
      var checkAlreadyIn =
          cartList.where((element) => element['bin_no'] == getBin['bin_no']);
      if (checkAlreadyIn.isEmpty) {
        cartList.add({
          "bin_no": getBin['bin_no'].toString(),
          "description": getBin['description'] ?? "-",
          "item_name": getBin['item_name'] ?? "-",
          "category": getBin['category'] ?? "-",
          "location": getBin['location'] ?? "-",
          "min_level": getBin['min_level'] ?? "-",
          "max_level": getBin['max_level'] ?? "-",
          "reorder_level": getBin['reorder_level'] ?? "-",
          "uom": getBin['uom'] ?? '',
          "cts": getBin['cts'] ?? 0,
          "uts": getBin['uts'] ?? 0,
          "balance": getBin['balance'] ?? 0,
          "created_on": getBin['created_on'] ?? "",
        });
        print('list=================$cartList');
      } else {
        await apiService.showToast('Item already added');
      }
      setState(() {
        pause = true;
        loadingText = false;
      });
      await cameraController.stop();
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    amountController.dispose();
    super.dispose();
  }
}
