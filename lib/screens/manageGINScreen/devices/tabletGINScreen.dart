import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:qfix_nitmo_new/Constant/Slideanimation.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
import 'package:qfix_nitmo_new/helper/QRScanner.dart';
import 'package:qfix_nitmo_new/screens/manageStoreScreen/checkStoreScreen.dart';
import 'package:qfix_nitmo_new/widgets/widgets.dart';

class TabletGINScreen extends StatefulWidget {
  const TabletGINScreen({Key? key}) : super(key: key);

  @override
  State<TabletGINScreen> createState() => _TabletGINScreenState();
}

class _TabletGINScreenState extends State<TabletGINScreen>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  TextEditingController ginCodeController = new TextEditingController();
  AnimationController? _animationController;
  bool _validateGIN = false;
  String headerTitle = "New Goods Issue Note";
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
      headerTitle = "New Goods Issue Note";
      showQRScan = false;
      ginCodeController.clear();
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
          // bottom: PreferredSize(
          //   child: Divider(
          //     color: ColorsRes.greyColor,
          //     height: 2.3,
          //   ),
          //   preferredSize: Size(50, 5),
          // ),
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
                      const Padding(
                        padding: EdgeInsets.only(
                          top: 14,
                        ),
                        child: Center(
                          child: Text(
                            'Please Enter GIN Code',
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
                            SizedBox(
                              height: 20,
                            ),
                            showValidation(),
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
            ginTemplate: true,
            storeTemplate: false,
            grnTemplate: false,
            grnCode: "0",
            refNo: ginCodeController.text,
            prnNo: '',
            formReset: formReset,
          );
  }

  Widget showValidation() {
    return _validateGIN
        ? const Column(
            children: [
              Text(
                'Please enter correct GIN Code',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          )
        : Container();
  }

Widget showGRNField() {
  return TextField(
    onChanged: (_) {
      setState(() {
        _validateGIN = false; // Reset validation state
      });
    },
    controller: ginCodeController,
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
      hintText: 'GIN Code',
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
        onPressed: () {
          formSubmit();
        },
        color: ColorsRes.secondaryButton,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.add,
              color: Colors.black,
              size: 35,
            ),
            SizedBox(width: 5),
            Text(
              "Issue New GIN",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  formSubmit() async {
    if (formKey.currentState!.validate() && ginCodeController.text.isNotEmpty) {
      setState(() {
        showQRScan = true;
        headerTitle = 'GIN #' + ginCodeController.text;
      });
    }

    // if (ginCodeController.text.isEmpty) {
    //   setState(() {
    //     _validateGIN = true;
    //   });
    // } else {
    //   setState(() {
    //     showQRScan = true;
    //     headerTitle = 'GIN #' + ginCodeController.text;
    //   });
    // }
  }
}
