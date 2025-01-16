import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qfix_nitmo_new/api/apiService.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
import 'package:qfix_nitmo_new/helper/StringsRes.dart';


class MyBottomSheet extends StatefulWidget {
  const MyBottomSheet({
    Key? key,
    required this.closeCard,
    this.submitFromBottomCard,
    this.gin,
    this.grn,
    this.item,
    this.grnCode,
    this.index,
  }) : super(key: key);

  final closeCard;
  final submitFromBottomCard;
  final gin;
  final grn;
  final item;
  final grnCode;
  final index;

  @override
  _MyBottomSheetState createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet> {
  final _formKeyDialog = GlobalKey<FormState>();
  bool gin = false;
  bool grn = false;
  String scanId = "";
  int? grnCode;
  int? index;
  TextEditingController amountController = TextEditingController();
  bool _validateAmount = false;
  @override
  void initState() {
    super.initState();
    gin = widget.gin;
    grn = widget.grn;
    grnCode = widget.grnCode;
    index = widget.index;

    _timer = new Timer.periodic(Duration(seconds: 1), (Timer t) => getTime());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
    bool gin = false;
    bool grn = false;
    int grnCode;
    int index;
    List item;
    _validateAmount = false;
  }

  APIService apiService = APIService();

  late Timer _timer;
  final DateTime now = DateTime.now();
  String? _dateTime;
  getTime() async {
    String formattedDateTime = "";
    String suffix = 'th';
    final int digit = now.day % 10;
    if ((digit > 0 && digit < 4) && (now.day < 11 || now.day > 13)) {
      suffix = <String>['st', 'nd', 'rd'][digit - 1];
    }

    formattedDateTime = DateFormat("d'$suffix' MMM yyyy - kk:mm:ss")
        .format(DateTime.now())
        .toString();

    setState(() {
      _dateTime = formattedDateTime;
    });
  }

  String capitalize(String s) => s.toUpperCase();
  @override
  Widget build(BuildContext context) {
    double maxHeight = MediaQuery.of(context).size.height * 0.6;

    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      print('portrait');
    } else {
      maxHeight = MediaQuery.of(context).size.height * 0.9;
    }

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 30.0),
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          decoration: BoxDecoration(
            // gradient: UiUtils.buildLinerGradient([Theme.of(context).scaffoldBackgroundColor, Theme.of(context).canvasColor], Alignment.topCenter, Alignment.bottomCenter),
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50.0),
            ),
          ),
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Form(
            key: _formKeyDialog,
            child: Container(
              margin: EdgeInsets.only(top: 10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.only(end: 20, top: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // SizedBox(
                          //   width: 10,
                          // ),
                          IconButton(
                            onPressed: () {
                              widget.closeCard();
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: Colors.black,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.search,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 8),
                      alignment: Alignment.center,
                      child: Text('Selected ' + widget.item['bin_no'],
                          style: TextStyle(fontSize: 16)),
                    ),
                    SizedBox(
                      height: 25,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              widget.item['item_name'].toUpperCase(),
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            '[ ' + widget.item['location'] + ' ]',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    gin ? ginUi_grnUi() : SizedBox(),
                    grn ? ginUi_grnUi() : SizedBox(),
                    SizedBox(
                      width: 200, // <-- Your width
                      height: 50, // <-- Your height
                      child: Container(
                        child: ElevatedButton(
                          onPressed: () {
                            if (amountController.text.isEmpty ||
                                int.parse(amountController.text) >
                                    widget.item['balance']) {
                              setState(() {
                                _validateAmount = true;
                              });
                            } else {
                              submitBtn();
                            }
                          },
                          child: Text(
                            'Add',
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
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  validate() {
    var res = true;

    if (widget.gin) {
      widget.item['balance'] < int.parse(amountController.text)
          ? res = false
          : res = true;
    }
    if (widget.grn) {
      res = true;
    }
    return res;
  }

  submitBtn() async {
    if (validate()) {
      var details = {
        'index': index,
        'grnCode': grnCode,
        'scanId': widget.item['bin_no'],
        'amount': amountController.text
      };
      if (gin || grn) {
        widget.submitFromBottomCard(index, widget.item['bin_no'], details);
      }
      apiService.showToast('amount added');
      Navigator.pop(context);
    }
  }

  Widget ginUi_grnUi() {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        Container(
          margin: EdgeInsets.only(left: 20, right: 20),
          child: Table(
            children: [
              TableRow(
                children: [
                  Text(
                    "In-Stock",
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "Min-Level",
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "Max-Level",
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "Reorder-Level",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              TableRow(
                children: [
                  Text(
                    widget.item['balance'].toString() +
                        ' ' +
                        widget.item['uom'].toString(),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    widget.item['min_level'].toString() +
                        ' ' +
                        widget.item['uom'].toString(),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    widget.item['max_level'].toString() +
                        ' ' +
                        widget.item['uom'].toString(),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    widget.item['reorder_level'].toString() +
                        ' ' +
                        widget.item['uom'].toString(),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: TextField(
            onChanged: (_) {
              setState(() {
                _validateAmount = false;
              });
            },
            controller: amountController,
            autofocus: true,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(left: 15.0),
              hintStyle: TextStyle(
                  color: ColorsRes.purpalColor,
                  fontSize: 16,
                  fontWeight: FontWeight.normal),
              labelStyle: TextStyle(
                color: ColorsRes.greyColor,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              filled: false,
              focusColor: ColorsRes.warmGreyColor,
              focusedBorder: OutlineInputBorder(
                gapPadding: 0.0,
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: ColorsRes.warmGreyColor,
                ),
              ),
              border: OutlineInputBorder(
                gapPadding: 0.0,
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: ColorsRes.warmGreyColor,
                  width: 1,
                ),
              ),
              // labelText: StringsRes.grnCodeTxt,
              hintText: StringsRes.amountTxt,
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        _validateAmount
            ? Text(
                'Please add correct amount',
                style: TextStyle(color: Colors.red),
              )
            : SizedBox(),
        SizedBox(
          height: 20,
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
