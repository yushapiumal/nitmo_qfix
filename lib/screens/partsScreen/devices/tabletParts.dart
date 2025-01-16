import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';



class TabletParts extends StatefulWidget {
  const TabletParts({Key? key, required this.taskData, this.markUpdateTask})
      : super(key: key);
  final taskData;
  final markUpdateTask;
  @override
  State<TabletParts> createState() => _TabletPartsState();
}

class _TabletPartsState extends State<TabletParts>
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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));

    for (var element in widget.taskData.contract['coverage']) {
      contractList.add(element);
    }
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
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).size.width / 20,
        left: MediaQuery.of(context).size.width / 10,
        right: MediaQuery.of(context).size.width / 10,
      ),
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorsRes.warmGreyColor,
          style: BorderStyle.solid,
          width: 1.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          hint: Text('Please select product'),
          items: contractList.map((con) {
            return DropdownMenuItem(
              value: con['serial'],
              child: Text(
                con['family'] + ' / ' + con['serial'],
                style: TextStyle(fontSize: 18),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              coverageDropdownValue = value.toString();
              itemSelected = true;
              _textValidate = false;
            });
          },
          isExpanded: false,
          value: itemSelected ? coverageDropdownValue.toString() : null,
        ),
      ),
    );
  }

  cellHeight() {
    return TableRow(
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
          return Container(
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width / 10,
              right: MediaQuery.of(context).size.width / 10,
              top: MediaQuery.of(context).size.width / 15,
              bottom: MediaQuery.of(context).size.width / 15,
            ),
            child: Table(
              columnWidths: {
                0: FlexColumnWidth(1.5),
                1: FlexColumnWidth(0.5),
                2: FlexColumnWidth(4),
              },
              children: [
                TableRow(
                  children: [
                    Text(
                      "Family",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      ":",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      element['family'],
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                cellHeight(),
                TableRow(
                  children: [
                    Text(
                      "Model",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      ":",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      element['model'],
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                cellHeight(),
                TableRow(
                  children: [
                    Text(
                      "Serial",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      ":",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      element['serial'],
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                cellHeight(),
                TableRow(
                  children: [
                    Text(
                      "Make",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      ":",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      element['make'],
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                cellHeight(),
                TableRow(
                  children: [
                    Text(
                      "Detail",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      ":",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      element['desc'],
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 18,
                      ),
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
    return Container(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width / 12,
        right: MediaQuery.of(context).size.width / 12,
      ),
      child: Column(
        children: [
          Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  validator: (value) {
                    if (value!.isNotEmpty) {
                      return null;
                    } else {
                      return AppLocalizations.of(context)!.partsFiledError;
                    }
                  },
                  scrollPadding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom * 4),
                  maxLines: 4,
                  onChanged: (_) {
                    setState(() {
                      _textValidate = false;
                    });
                  },
                  controller: newPartsListController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(left: 15.0, top: 20),
                    errorStyle: TextStyle(
                      fontSize: 18,
                    ),
                    hintStyle: TextStyle(
                      color: ColorsRes.purpalColor,
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                    labelStyle: TextStyle(
                        color: ColorsRes.greyColor,
                        fontSize: 18,
                        fontWeight: FontWeight.normal),
                    filled: false,
                    focusColor: ColorsRes.warmGreyColor,
                    focusedBorder: OutlineInputBorder(
                      gapPadding: 2.0,
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: ColorsRes.warmGreyColor,
                      ),
                    ),
                    border: OutlineInputBorder(
                      gapPadding: 0.3,
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: ColorsRes.warmGreyColor,
                        width: 1,
                      ),
                    ),
                    labelText: AppLocalizations.of(context)!.partsFiled,
                    hintText: AppLocalizations.of(context)!.partsFiledError,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 90,
                ),
                Container(
                  margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width / 30,
                    right: MediaQuery.of(context).size.width / 30,
                    top: MediaQuery.of(context).size.width / 30,
                  ),
                  width: 400,
                  child: CupertinoButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.settings_solid,
                            color: Colors.black,
                            size: 35,
                          ),
                          SizedBox(width: 5),
                          Text(
                            AppLocalizations.of(context)!.orderBtnName,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      onPressed: btnDisable
                          ? null
                          : () async {
                              if (formKey.currentState!.validate() &&
                                  newPartsListController.text.isNotEmpty) {
                                setState(() {
                                  btnDisable = true;
                                });
                                var data = {
                                  'serial': coverageDropdownValue,
                                  'parts': newPartsListController.text
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
                      color: ColorsRes.secondaryButton),
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
    );
  }
}
