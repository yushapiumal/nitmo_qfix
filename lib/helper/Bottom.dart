import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qfix_nitmo_new/api/apiService.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
import 'package:qfix_nitmo_new/helper/StringsRes.dart';


class MyBottomSheet extends StatefulWidget {
  const MyBottomSheet({
   
    required this.closeCard,
    this.submitFromBottomCard,
    this.gin,
    this.grn,
    this.item,
    this.grnCode,
    this.index,
  });

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

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => getTime());
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
          decoration: const BoxDecoration(
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
              margin: const EdgeInsets.only(top: 10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 20, top: 30),
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
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.black,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.search,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      alignment: Alignment.center,
                      child: Text('Selected ' + widget.item['bin_no'],
                          style: const TextStyle(fontSize: 16)),
                    ),
                    SizedBox(
                      height: 25,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              widget.item['item_name'].toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            '[ ' + widget.item['location'] + ' ]',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    gin ? ginUi_grnUi() : const SizedBox(),
                    grn ? ginUi_grnUi() : const SizedBox(),
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
                          style: ElevatedButton.styleFrom(
                            // minimumSize: Size(355, 55),
                            shape: const StadiumBorder(), backgroundColor: Colors.black,
                          ),
                          child: Text(
                            'Add',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
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
        const SizedBox(
          height: 20,
        ),
        Container(
          margin: const EdgeInsets.only(left: 20, right: 20),
          child: Table(
            children: [
              const TableRow(
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
                    '${widget.item['balance']} ${widget.item['uom']}',
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '${widget.item['min_level']} ${widget.item['uom']}',
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '${widget.item['max_level']} ${widget.item['uom']}',
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '${widget.item['reorder_level']} ${widget.item['uom']}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
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
              contentPadding: const EdgeInsets.only(left: 15.0),
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
        const SizedBox(
          height: 10,
        ),
        _validateAmount
            ? const Text(
                'Please add correct amount',
                style: TextStyle(color: Colors.red),
              )
            : const SizedBox(),
        const SizedBox(
          height: 20,
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
