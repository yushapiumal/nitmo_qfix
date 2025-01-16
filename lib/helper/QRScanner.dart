import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:octo_image/octo_image.dart';
import 'package:qfix_nitmo_new/api/apiService.dart';
import 'package:qfix_nitmo_new/helper/Bottom.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
import 'package:qfix_nitmo_new/helper/Slidable.dart';
import 'package:qfix_nitmo_new/helper/Slide_action.dart';
//import 'package:qr_code_scanner/qr_code_scanner.dart';



class QRScanner extends StatefulWidget {
  const QRScanner({
    Key? key,
    required this.ginTemplate,
    this.storeTemplate,
    this.grnTemplate,
    this.grnCode,
    this.refNo,
    this.prnNo,
    this.formReset,
  }) : super(key: key);
  final ginTemplate;
  final storeTemplate;
  final grnTemplate;
  final grnCode;
  final refNo;
  final prnNo;
  final formReset;
  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> with TickerProviderStateMixin {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  APIService apiService = APIService();
 // Barcode? result;
 // QRViewController? controller;
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
     // controller!.pauseCamera();
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
    return Column(
      children: [
      //  Expanded(flex: 1, child: _buildQrView(context)),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Row(
                children: [
                  BottomAppBar(
                    child: Container(
                      color: Colors.transparent,
                      width: MediaQuery.of(context).size.width,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0)),
                          color: ColorsRes.backgroundColor,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () async {
                              //  await controller?.toggleFlash();
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
                               // await controller?.flipCamera();
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
                    color: Colors.transparent,
                  )
                ],
              ),
              SizedBox(
                height: 14,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // if (result == null)
                  //   Center(
                  //     child: Text(
                  //       'Scan a code',
                  //       style: TextStyle(
                  //         fontSize: 16,
                  //         fontWeight: FontWeight.w500,
                  //       ),
                  //     ),
                  //   )
                  // else
                  //   Center(
                  //     child: Text('Last scanned code : ${result!.code}'),
                  //   ),
                ],
              ),
              loadingText ? Text('Loading...') : SizedBox(),
              SizedBox(
                height: 5,
              ),
              widget.ginTemplate ? showGINTemplate() : SizedBox(),
              widget.grnTemplate ? showGRNTemplate() : SizedBox(),
              widget.storeTemplate ? showStoreTemplate() : SizedBox(),
              SizedBox(
                height: 10,
              ),
              saveBTN(),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }

  cameraPauseIcon() {
    if (widget.storeTemplate) {
      return IconButton(
        onPressed: () async {
          if (!pause) {
          //  await controller?.pauseCamera();
            setState(() {
              pause = true;
              cartList = [];
              scanCodeList = [];
             // result = null;
            });
          } else {
           // await controller?.resumeCamera();
            setState(() {
              pause = false;
              cartList = [];
              scanCodeList = [];
            //  result = null;
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
         // await controller?.pauseCamera();
          setState(() {
            pause = true;
          });
        } else {
         // await controller?.resumeCamera();
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

  saveBTN() {
    if (widget.ginTemplate) {
      return finalGINIssueList.length > 0
          ? SizedBox(
              width: 200, // <-- Your width
              height: 50, // <-- Your height
              child: Container(
                child: ElevatedButton(
                  onPressed: () {
                    saveBtnDisable ? false : submitGINote();
                  },
                  child: Text(
                    saveBtnDisable ? 'Wait...' : 'Save',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(
                    // minimumSize: Size(355, 55),
                    shape: StadiumBorder(), backgroundColor: Colors.black,
                  ),
                ),
              ),
            )
          : SizedBox();
    }
    if (widget.grnTemplate) {
      return finalGRNIssueList.length > 0
          ? SizedBox(
              width: 200, // <-- Your width
              height: 50, // <-- Your height
              child: Container(
                child: ElevatedButton(
                  onPressed: () {
                    saveBtnDisable ? false : submitGRNote();
                  },
                  child: Text(
                    saveBtnDisable ? 'Wait...' : 'Save',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(
                    // minimumSize: Size(355, 55),
                    shape: StadiumBorder(), backgroundColor: Colors.black,
                  ),
                ),
              ),
            )
          : SizedBox();
    }
    if (widget.storeTemplate) {
      return SizedBox();
    }
  }

  Widget showGINTemplate() {
    if (scanCodeList.length == 0) {
      return SizedBox();
    }
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 10),
        itemCount: cartList.length,
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return listItem(index);
        },
      ),
    );
  }

  Widget showGRNTemplate() {
    // if (result == null) {
    //   return SizedBox();
    // }
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 10),
        itemCount: cartList.length,
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return listItem(index);
        },
      ),
    );
  }

  Widget showStoreTemplate() {
    // if (result == null) {
    //   return SizedBox();
    // }

    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 10),
        itemCount: cartList.length,
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return showStoreData(index);
        },
      ),
    );
  }

  Widget showStoreData(int index) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(top: 15, start: 10, end: 10),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    'Added on ${cartList[index]['created_on']}',
                    style: TextStyle(
                        color: ColorsRes.black,
                        fontWeight: FontWeight.normal,
                        fontSize: 14),
                  ),
                ),
                Spacer(), // Defaults to a flex of one.
                Padding(
                  padding:
                      EdgeInsetsDirectional.only(start: 5, top: 5, bottom: 5),
                  child: GestureDetector(
                    child: Text(
                      cartList[index]['category'],
                      style: TextStyle(
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
          Container(
            height: MediaQuery.of(context).size.height * 0.40,
            child: SingleChildScrollView(
              child: itemData(index),
            ),
          ),
        ],
      ),
    );
  }

  itemData(int index) {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        Text(
          cartList[index]['description'],
          style: TextStyle(
            fontSize: 16,
            color: ColorsRes.black,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        textBox(Icons.tag, 'BIN No', cartList[index]['bin_no']),
        textBox(Icons.location_pin, 'Location', cartList[index]['location']),
        textBox(Icons.check, 'Balance',
            cartList[0]['balance'].toString() + ' ${cartList[index]['uom']}'),
        textBox(
            Icons.other_houses_outlined,
            'Reorder',
            cartList[index]['reorder_level'].toString() +
                ' ${cartList[index]['uom']}'),
        textBox(
            Icons.minimize_outlined,
            'Min',
            cartList[index]['min_level'].toString() +
                ' ${cartList[index]['uom']}'),
        textBox(
            Icons.published_with_changes_rounded,
            'Max',
            cartList[index]['max_level'].toString() +
                ' ${cartList[index]['uom']}'),
        SizedBox(
          height: 40,
        ),
      ],
    );
  }

  textBox(icon, text, amount) {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(bottom: 0.0, left: 1),
        child: ListTile(
          // leading: Container(
          //   height: 25,
          //   width: 25,
          //   alignment: Alignment.center,
          //   decoration: DesignConfig.boxDecorationBorderButtonColor(
          //       ColorsRes.yellowColor, 100),
          //   child: Icon(
          //     icon,
          //     color: ColorsRes.yellowColor,
          //     size: 18,
          //   ),
          // ),
          title: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: ColorsRes.black,
                fontWeight: FontWeight.normal,
                letterSpacing: 0.5,
                fontSize: 16),
          ),

          // subtitle: Text(cartList[0]['bin_no'],
          //     style: TextStyle(
          //         fontSize: 10,
          //         color: ColorsRes.greyColor.withOpacity(0.7),
          //         fontWeight: FontWeight.normal)),
          trailing: Text(
            amount,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: ColorsRes.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
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
             // await controller?.pauseCamera();
              showBarCard(index, cartList[index]);
            } else {
              setState(() {
                flashOn = false;
                pause = true;
                isCardOpen = true;
                flipCamera = false;
              });
             // await controller?.pauseCamera();
              removeFromList(cartList[index]["bin_no"]);
              cartList.removeWhere((element) {
                return element['bin_no'] == cartList[index]["bin_no"];
              });
            }
            return false;
          },
        ),
        delegate: SlidableBehindDelegate(),
        actionExtentRatio: 0.25,
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(cartList[index]["item_name"]),
                        SizedBox(height: 10),
                        Text(cartList[index]["description"]),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        showQuantity(index),
                        SizedBox(height: 10),
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
        actions: [
          IconSlideAction(
            fontSize: 14,
            caption: 'Add Amount',
            color: Color.fromARGB(255, 1, 203, 85),
            icon: Icons.check_circle_outline_sharp,
            onTap: () async {
              setState(() {
                flashOn = false;
                pause = true;
                isCardOpen = true;
                flipCamera = false;
              });
             // await controller?.pauseCamera();
              showBarCard(index, cartList[index]);
            },
          ),
        ],
        secondaryActions: [
          // IconSlideAction(
          //   fontSize: 14,
          //   caption: 'Replace',
          //   color: Colors.grey.shade200,
          //   icon: Icons.replay,
          //   onTap: () async {
          //     setState(() {
          //       flashOn = false;
          //       pause = true;
          //       isCardOpen = true;
          //       flipCamera = false;
          //     });
          //     await controller?.pauseCamera();
          //     showBarCard(index, cartList[index]);
          //   },
          //   closeOnTap: false,
          // ),
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
              //await controller?.pauseCamera();
              removeFromList(cartList[index]["bin_no"]);
              cartList.removeWhere((element) {
                return element['bin_no'] == cartList[index]["bin_no"];
              });
            },
          ),
        ],
      ),
    );
  }

  showQuantity(index) {
    if (widget.ginTemplate) {
      if (finalGINIssueList[cartList[index]["bin_no"]] != null) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              finalGINIssueList[cartList[index]["bin_no"]]['amount']
                      .toString() +
                  ' ' +
                  cartList[index]["uom"],
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
              style: TextStyle(color: Colors.red),
            ),
            Text(
              ' / ',
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
            Text(
              cartList[index]["balance"].toString() +
                  ' ' +
                  cartList[index]["uom"],
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
          ],
        );
      }
      return Text(
        cartList[index]["balance"].toString() + ' ' + cartList[index]["uom"],
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.fade,
      );
    }

    if (widget.grnTemplate) {
      if (finalGRNIssueList[cartList[index]["bin_no"]] != null) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              finalGRNIssueList[cartList[index]["bin_no"]]['amount']
                      .toString() +
                  ' ' +
                  cartList[index]["uom"],
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
              style: TextStyle(color: Colors.green),
            ),
            Text(
              ' / ',
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
            Text(
              cartList[index]["balance"].toString() +
                  ' ' +
                  cartList[index]["uom"],
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
          ],
        );
      }
      return Text(
        cartList[index]["balance"].toString() + ' ' + cartList[index]["uom"],
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.fade,
      );
    }
  }

  closeCard() async {
    setState(() {
      flashOn = false;
      pause = false;
      isCardOpen = false;
      flipCamera = false;
      // result = null;
    });
   // await controller?.resumeCamera();
  }

  Map<String, dynamic> finalGINIssueList = {};
  Map<String, dynamic> finalGRNIssueList = {};
  submitFromBottomCard(index, scanId, issueData) async {
    if (widget.ginTemplate) {
      finalGINIssueList[scanId] = issueData;
    }
    if (widget.grnTemplate) {
      finalGRNIssueList[scanId] = issueData;
    }
  }

  removeFromList(binNo) {
    if (widget.ginTemplate) {
      if (finalGINIssueList.length > 0) {
        finalGINIssueList.removeWhere((key, value) => key == binNo);
      }
    }
    if (widget.grnTemplate) {
      if (finalGRNIssueList.length > 0) {
        finalGRNIssueList.removeWhere((key, value) => key == binNo);
      }
    }
    scanCodeList.removeWhere((element) {
      return element == binNo;
    });
  }

  submitGINote() async {
    if (finalGINIssueList.length != cartList.length) {
      await apiService
          .showToast('GIN is not complete. please complete the list');
    } else {
      setState(() {
        saveBtnDisable = true;
      });
      var line_items = [];
      finalGINIssueList.values.forEach((val) {
        line_items
            .add({'bin_number': val['scanId'], 'quantity': val['amount']});
      });

      var data = {
        'ref_type': 'GIN',
        'ref_number': widget.refNo,
        'sid': '5555',
        'line_items': jsonEncode(line_items)
      };

      var submit = await apiService.saveStoreLedger('issue', data);
      if (submit) {
        widget.formReset();
      }
      setState(() {
        saveBtnDisable = false;
      });
    }
  }

  submitGRNote() async {
    if (finalGRNIssueList.length != cartList.length) {
      await apiService
          .showToast('GRN is not complete. please complete the list');
    } else {
      setState(() {
        saveBtnDisable = true;
      });
      List line_items = [];

      finalGRNIssueList.values.forEach((val) {
        line_items
            .add({'bin_number': val['scanId'], 'quantity': val['amount']});
      });

      var data = {
        'ref_type': 'GRN',
        'ref_number': widget.refNo,
        'prn_number': widget.prnNo,
        'sid': '5555',
        'line_items': jsonEncode(line_items)
      };

      var submit = await apiService.saveStoreLedger('receive', data);

      if (submit) {
        widget.formReset();
        // Navigator.pushNamed(context, ManageGRNScreen.routeName);
      }
      setState(() {
        saveBtnDisable = false;
      });
    }
  }

  Future showBarCard(index, item) {
    return showModalBottomSheet(
      elevation: 0,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
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
        grn: widget.grnTemplate,
        item: item,
        grnCode: widget.grnCode,
        index: index,
      ),
    );
  }

  // Widget _buildQrView(BuildContext context) {
  //   // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
  //   var scanArea = (MediaQuery.of(context).size.width < 400 ||
  //           MediaQuery.of(context).size.height < 400)
  //       ? 200.0
  //       : 300.0;
  //   // To ensure the Scanner view is properly sizes after rotation
  //   // we need to listen for Flutter SizeChanged notification and update controller
  //   // return QRView(
  //   //   key: qrKey,
  //   //   onQRViewCreated: _onQRViewCreated,
  //   //   overlay: QrScannerOverlayShape(
  //   //     borderColor: Colors.red,
  //   //     borderRadius: 10,
  //   //     borderLength: 30,
  //   //     borderWidth: 10,
  //   //     cutOutSize: scanArea,
  //   //   ),
  //   //   onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
  //   // );
  // }

  // void _onQRViewCreated(QRViewController controller) {
  //   setState(() {
  //     this.controller = controller;
  //   });
  //   controller.scannedDataStream.listen((scanData) {
  //     setState(() {
  //       result = scanData;
  //       pause = true;
  //       loadingText = true;
  //     });
  //     if (result != null) {
  //       manageScannedQR();
  //       controller.pauseCamera();
  //       setState(() {
  //         loadingText = false;
  //       });
  //     }
  //   });
  // }

  // manageScannedQR() async {
  //   var checkArray;
  //   if (result != null) {
  //     if (scanCodeList.length == 0) {
  //       scanCodeList.add(result!.code);
  //     } else {
  //       checkArray = scanCodeList.where((element) => element == result!.code);
  //       if (checkArray.isEmpty) {
  //         scanCodeList.add(result!.code);
  //         apiService.showToast('Scanned successfully');
  //         print('Scanned successfully');
  //       } else {
  //         apiService.showToast('Already scanned');
  //         print('Already scanned');
  //       }
  //     }
  //     // GOOD ISSUE NOTE
  //     if (widget.ginTemplate) {
  //       await callBin();
  //     }

  //     // GOOD RECEIVE NOTE
  //     if (widget.grnTemplate) {
  //       await callBin();
  //     }

  //     // STORE VIEW
  //     if (widget.storeTemplate) {
  //       await callBin();
  //     }
  //   }
  // }

  // void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
  //   print('${DateTime.now().toIso8601String()}_onPermissionSet $p');
  //   if (!p) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('No Permission')),
  //     );
  //   }
  // }

  callBin() async {
    var lastCode;
    lastCode = scanCodeList[0];
    if (scanCodeList.length > 0) {
      lastCode = scanCodeList[scanCodeList.length - 1];
    }
    var getBin = await apiService.getBin(lastCode);

    if (getBin != false) {
      var checkAlreadyIn =
          cartList.where((element) => element['bin_no'] == getBin['bin_no']);

      if (checkAlreadyIn.isEmpty) {
        cartList.add({
          "bin_no": getBin['bin_no'].toString(),
          "description":
              getBin['description'] == null ? "-" : getBin['description'],
          "item_name":
              getBin['item_name'] == null || getBin['item_name'] == false
                  ? "-"
                  : getBin['item_name'],
          "category": getBin['category'] == null ? "-" : getBin['category'],
          "location": getBin['location'] == null ? "-" : getBin['location'],
          "min_level": getBin['min_level'] == null ? "-" : getBin['min_level'],
          "max_level": getBin['max_level'] == null ? "-" : getBin['max_level'],
          "reorder_level":
              getBin['reorder_level'] == null ? "-" : getBin['reorder_level'],
          "uom": getBin['uom'] == null ? '' : getBin['uom'],
          "cts": getBin['cts'] == null ? 0 : getBin['cts'],
          "uts": getBin['uts'] == null ? 0 : getBin['uts'],
          "balance": getBin['balance'] == null ? 0 : getBin['balance'],
          "created_on":
              getBin['created_on'] == null ? "" : getBin['created_on'],
        });
      } else {
        await apiService.showToast('Item already added');
      }
      setState(() {
        pause = true;
        loadingText = false;
      });
     // controller!.pauseCamera();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
   // controller?.dispose();
    super.dispose();
  }
}

  