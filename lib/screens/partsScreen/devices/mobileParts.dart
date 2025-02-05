import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:qfix_nitmo_new/api/apiService.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:qfix_nitmo_new/widgets/widgets.dart';



class MobileParts extends StatefulWidget {
  const MobileParts({Key? key, required this.taskData, this.markUpdateTask})
      : super(key: key);
  final taskData;
  final markUpdateTask;

  @override
  State<MobileParts> createState() => _MobilePartsState();
}

class _MobilePartsState extends State<MobileParts>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  final formKey = GlobalKey<FormState>();
  LocalStorage storage = LocalStorage('qfix');
  var contractList = [];
  String coverageDropdownValue = 'Please select product';
  bool itemSelected = false;
  TextEditingController newPartsListController = TextEditingController();
  bool _textValidate = false;

  bool btnDisable = false;
  APIService apiService = APIService();
  int counter = 0;
  List existPartsList = [];
  bool isLongPressedIncrease = false;
  bool isLongPressedDecrease = false;
  List partList = [];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));

    for (var element in widget.taskData.contract['coverage']) {
      contractList.add(element);
    }
    setState(() {
      existPartsList = widget.taskData.parts;
    });
    var other = {
      'family': 'Other',
      'model': false,
      'desc': false,
      'serial': 'other',
      'make': false
    };
    contractList.add(other);
  }

  @override
  void dispose() {
    _animationController!.dispose();

    super.dispose();
  }

  Widget helpingText() {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 20),
      width: 600,
      child: Text(
        "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, ",
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget selectItem() {
    return Container(
      padding: EdgeInsets.only(
        left: 30,
        right: 30,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(
              top: 10,
            ),
            width: MediaQuery.of(context).size.width / 1.5,
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ColorsRes.warmGreyColor,
                style: BorderStyle.solid,
                width: 0.80,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                hint: Text('Please select product'),
                items: contractList.map((con) {
                  return DropdownMenuItem(
                    value: con['serial'],
                    child: Text(con['family'] + ' / ' + con['serial']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    coverageDropdownValue = value.toString();
                    itemSelected = true;
                    _textValidate = false;
                  });
                },
                isExpanded: true,
                value: itemSelected ? coverageDropdownValue.toString() : null,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.8),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
           child:const Icon(
             Icons.select_all,
                color: Colors.black,
      
             
            ),
          ),
        ],
      ),
    );

  }

  cellHeight() {
    return const TableRow(
      children: [
        TableCell(
          child: SizedBox(
            height: 10,
          ),
        ),
        TableCell(
          child: SizedBox(
            height: 10,
          ),
        ),
        TableCell(
          child: SizedBox(
            height: 10,
          ),
        ),
      ],
    );
  }

  showSelectedItemData() {
    if (contractList.length > 0) {
      for (var element in contractList) {
        if (element['serial'] == coverageDropdownValue.toString()) {
          if (element['serial'] == 'other') {
            return Text(AppLocalizations.of(context)!.partsFiled);
          }

          return Container(
            padding: EdgeInsets.only(left: 20, right: 5),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(1.5),
                1: FlexColumnWidth(0.5),
                2: FlexColumnWidth(4),
              },
              children: [
                TableRow(
                  children: [
                    const Text(
                      "Family",
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      ":",
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      element['family'],
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                cellHeight(),
                TableRow(
                  children: [
                    Text(
                      "Model",
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      ":",
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      element['model'],
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                cellHeight(),
                TableRow(
                  children: [
                    Text(
                      "Serial",
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      ":",
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      element['serial'],
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                cellHeight(),
                TableRow(
                  children: [
                    Text(
                      "Make",
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      ":",
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      element['make'],
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                cellHeight(),
                TableRow(
                  children: [
                    Text(
                      "Detail",
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      ":",
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      element['desc'],
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                cellHeight(),
              ],
            ),
          );
        }
      }
    }
    return SizedBox();
  }

  showInputField() {
    var fontSize = MediaQuery.of(context).size.width / 25;

    if (storage.getItem('lang') == 'si') {
      fontSize = MediaQuery.of(context).size.width / 30;
    }

    return Container(
      padding: EdgeInsets.only(
        left: 30,
        right: 30,
      ),
      child: Column(
        children: [
          Form(
            key: formKey,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: textField(
                        newPartsListController,
                        AppLocalizations.of(context)!.partsFiled,
                        AppLocalizations.of(context)!.partsFiledError,
                        TextInputType.text,
                        false,
                        formKey,
                        1,
                      ),
                    ),
                    Container(
                      // width: MediaQuery.of(context).size.width / 5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            child: Container(
                              width: 30,
                              height: 30,
                              child: Icon(
                                Icons.check,
                                color: Colors.green,
                                size: 20,
                              ),
                              // margin: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onTap: () {
                              if (newPartsListController.text.isEmpty) {
                                apiService.showToast('Please add item');
                              } else {
                                setState(() {
                                  partList.add({
                                    'part': newPartsListController.text,
                                    'qty': 1
                                  });
                                  newPartsListController.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 90,
                ),
                partList.length > 0
                    ? Container(
                        height: MediaQuery.of(context).size.height / 4,
                        child: SingleChildScrollView(
                          child: Table(columnWidths: {
                            0: FlexColumnWidth(0.8),
                            1: FlexColumnWidth(0.7),
                            2: FlexColumnWidth(0.2),
                          }, children: [
                            const TableRow(
                              children: [
                                TableCell(
                                  child: Text(
                                    'Parts',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                TableCell(
                                  child: Text(
                                    'Qty',
                                    textAlign: TextAlign.center,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                TableCell(
                                  child: Text(
                                    '',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            cellHeight(),
                            ...partList
                                .expand((item) => [
                                      TableRow(
                                        children: [
                                          TableCell(
                                            child: Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Text(
                                                item['part'],
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Container(
                                              child: Row(
                                                children: [
                                                  GestureDetector(
                                                    child: Container(
                                                      width: 24,
                                                      height: 24,
                                                      margin:
                                                          EdgeInsets.all(15),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[200],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: const Icon(
                                                        Icons.remove,
                                                        color: Colors.red,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      setState(() {
                                                        if (item['qty'] > 1) {
                                                          item['qty']--;
                                                        }
                                                      });
                                                    },
                                                  ),
                                                  Text(
                                                    "${item['qty']}",
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                  ),
                                                  GestureDetector(
                                                    child: Container(
                                                      width: 24,
                                                      height: 24,
                                                      margin:
                                                          EdgeInsets.all(15),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[200],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: const Icon(
                                                        Icons.add,
                                                        color: Colors.green,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      setState(() {
                                                        item['qty']++;
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: GestureDetector(
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                  top: 10,
                                                ),
                                                width: 30,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  color: Colors.red[100],
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                  size: 20,
                                                ),
                                              ),
                                              onTap: () {
                                                print('click remove');
                                                setState(() {
                                                  partList.remove(item);
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Add a space row with 10 pixels height
                                      TableRow(
                                        children: [
                                          TableCell(
                                            child: Container(height: 10),
                                          ),
                                          TableCell(
                                            child: Container(height: 10),
                                          ),
                                          TableCell(
                                            child: Container(height: 10),
                                          ),
                                        ],
                                      ),
                                    ])
                                .toList(),
                          ]),
                        ),
                      )
                    : SizedBox(),
                Container(
                  margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width / 30,
                    right: MediaQuery.of(context).size.width / 30,
                    top: MediaQuery.of(context).size.width / 30,
                  ),
                  width: 300,
                  child: CupertinoButton(
                      onPressed: btnDisable
                          ? null
                          : () async {
                              if (partList.length == 0) {
                                apiService.showToast('Please add parts list');
                              } else {
                                setState(() {
                                  btnDisable = true;
                                });
                                var data = {
                                  'serial': coverageDropdownValue,
                                  'parts': partList
                                };
                                var submit = await widget.markUpdateTask(
                                    'parts',
                                    'order-new-parts',
                                    jsonEncode(data));
                                if (submit || !submit) {
                                  setState(() {
                                    coverageDropdownValue =
                                        'Please select product';
                                    btnDisable = false;
                                    itemSelected = false;
                                  });
                                  newPartsListController.clear();
                                }
                              }
                            },
                      color: ColorsRes.secondaryButton,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            CupertinoIcons.settings_solid,
                            color: Colors.black,
                          ),
                          SizedBox(width: 5),
                          Text(
                            AppLocalizations.of(context)!.orderBtnName,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: fontSize,
                            ),
                          ),
                        ],
                      )),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsRes.appBG,
      body: SingleChildScrollView(
        child: Container(
          color: ColorsRes.backgroundColor,
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height / 99),
              // helpingText(),
              Align(
                child: selectItem(),
                alignment: Alignment.center,
              ),
              SizedBox(
                height: 20,
              ),
              itemSelected ? showSelectedItemData() : SizedBox(),
              SizedBox(
                height: 20,
              ),
              itemSelected ? showInputField() : SizedBox(),
              btnDisable
                  ? Container(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                new AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        ),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton.small(
      //   backgroundColor: Colors.black45,
      //   elevation: 10,
      //   onPressed: () {},
      //   child: Icon(
      //     Icons.sticky_note_2_outlined,
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }
}
