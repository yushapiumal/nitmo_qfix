import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:qfix_nitmo_new/Constant/Slideanimation.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
import 'package:qfix_nitmo_new/helper/QRScanner.dart';
import 'package:qfix_nitmo_new/helper/StringsRes.dart';
import 'package:qfix_nitmo_new/screens/manageStoreScreen/checkStoreScreen.dart';
import 'package:qfix_nitmo_new/widgets/widgets.dart';

class TabletGRNScreen extends StatefulWidget {
  const TabletGRNScreen({Key? key}) : super(key: key);

  @override
  State<TabletGRNScreen> createState() => _TabletGRNScreenState();
}

class _TabletGRNScreenState extends State<TabletGRNScreen>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();

  TextEditingController grnCodeController = new TextEditingController();
  TextEditingController prnCodeController = new TextEditingController();
  AnimationController? _animationController;
  bool _validateGRN = false;
  bool _validatePRN = false;
  String headerTitle = "New Goods Receive Note";
  bool showQRScan = false;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  formReset() {
    setState(() {
      headerTitle = "New Goods Receive Note";
      showQRScan = false;
      grnCodeController.clear();
      prnCodeController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: ColorsRes.backgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: 30,
            ),
            onPressed: () {
              if (showQRScan) {
                formReset();
              } else {
                Navigator.popAndPushNamed(context, CheckStoreScreen.routeName);
                // Navigator.of(context).pop();
              }
            },
          ),
          shadowColor: Colors.transparent,
          title: Text(
            headerTitle.toUpperCase(),
            style: TextStyle(
              letterSpacing: 4,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: showBody(),
      ),
    );
  }

  Widget showBody() {
    return !showQRScan
        ? Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width / 12,
                    vertical: MediaQuery.of(context).size.width / 40),
                child: SlideAnimation(
                  position: 3,
                  itemCount: 10,
                  slideDirection: SlideDirection.fromRight,
                  animationController: _animationController,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: 14,
                        ),
                        child: Center(
                          child: Text(
                            'Please Enter GRN Code and PRN Code',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width / 35,
                      ),
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            showGRNField(),
                            showValidation1(),
                            SizedBox(
                              height: MediaQuery.of(context).size.width / 25,
                            ),
                            showPRNField(),
                            showValidation2(),
                            SizedBox(
                              height: MediaQuery.of(context).size.width / 25,
                            ),
                            buttonSubmit(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        : QRScanner(
            ginTemplate: false,
            storeTemplate: false,
            grnTemplate: true,
            grnCode: 0,
            refNo: grnCodeController.text,
            prnNo: prnCodeController.text,
            formReset: formReset,
          );
  }

  Widget showValidation1() {
    if (_validateGRN) {
      return Column(
        children: [
          Text(
            'Please enter correct GRN Code',
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      );
    }

    return Container();
  }

  Widget showValidation2() {
    if (_validatePRN) {
      return Column(
        children: [
          Text(
            'Please enter correct PRN Code',
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      );
    }

    return Container();
  }

 Widget showGRNField() {
  return TextField(
    onChanged: (_) {
      setState(() {
        _validateGRN = false; // Reset validation state
      });
    },
    controller: grnCodeController,
    keyboardType: TextInputType.text,
    decoration: InputDecoration(
      contentPadding: EdgeInsets.only(left: 15.0),
      hintStyle: TextStyle(
        color: ColorsRes.purpalColor,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
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
      hintText: StringsRes.grnCodeTxt,
    ),
  );
}

Widget showPRNField() {
  return TextField(
    onChanged: (_) {
      setState(() {
        _validatePRN = false; // Reset validation state
      });
    },
    controller: prnCodeController,
    keyboardType: TextInputType.text,
    decoration: InputDecoration(
      contentPadding: EdgeInsets.only(left: 15.0),
      hintStyle: TextStyle(
        color: ColorsRes.purpalColor,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
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
      hintText: StringsRes.prnCodeTxt,
    ),
  );
}


  Widget buttonSubmit() {
    return Container(
      margin: EdgeInsets.only(
        left: MediaQuery.of(context).size.width / 30,
        right: MediaQuery.of(context).size.width / 30,
      ),
      width: 400,
      child: CupertinoButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.add,
              color: Colors.black,
              size: 35,
            ),
            SizedBox(width: 5),
            Text(
              "Add New GRN",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        onPressed: () {
          formSubmit();
        },
        color: ColorsRes.secondaryButton,
      ),
    );
  }

  formSubmit() async {
    if (formKey.currentState!.validate() &&
        grnCodeController.text.isNotEmpty &&
        prnCodeController.text.isNotEmpty) {
      setState(() {
        showQRScan = true;
        headerTitle = 'GRN #' + grnCodeController.text;
      });
    }
  }
}
