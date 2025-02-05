import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:qfix_nitmo_new/Constant/Slideanimation.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
import 'package:qfix_nitmo_new/helper/QRScanner.dart';
import 'package:qfix_nitmo_new/helper/StringsRes.dart';
import 'package:qfix_nitmo_new/screens/manageStoreScreen/checkStoreScreen.dart';
import 'package:qfix_nitmo_new/widgets/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class MobileGRNScreen extends StatefulWidget {
  const MobileGRNScreen({Key? key}) : super(key: key);

  @override
  State<MobileGRNScreen> createState() => _MobileGRNScreenState();
}

class _MobileGRNScreenState extends State<MobileGRNScreen>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();

  TextEditingController grnCodeController = new TextEditingController();
  TextEditingController prnCodeController = new TextEditingController();
  AnimationController? _animationController;
  bool _validateGRN = false;
  bool _validatePRN = false;
  String headerTitle = "NEW GRN";
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
      headerTitle = "NEW GRN";
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
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 14,
                        ),
                        child: Center(
                          child: Text(
                           AppLocalizations.of(context)!.grnAndPrn,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            showGRNField(),
                            showValidation1(),
                            SizedBox(
                              height: 20,
                            ),
                            showPRNField(),
                            showValidation2(),
                            SizedBox(
                              height: 20,
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
      return  Column(
        children: [
          Text(
              AppLocalizations.of(context)!.grnError,
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
      return  Column(
        children: [
          Text(
            AppLocalizations.of(context)!.prnError,
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
        _validateGRN = false; // Reset validation state for GRN
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
      labelStyle: const TextStyle(
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
       hintText: AppLocalizations.of(context)!.grn,
      
    ),
  );
}

Widget showPRNField() {
  return TextField(
    onChanged: (_) {
      setState(() {
        _validatePRN = false; // Reset validation state for PRN
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
        hintText: AppLocalizations.of(context)!.prn,
    ),
  );
}

  Widget buttonSubmit() {
    return CupertinoButton(
        child: RichText(
          text: TextSpan(
            children: [
              WidgetSpan(
                child: Icon(
                  Icons.add,
                  size: 20,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: "Add New ",
                style: TextStyle(
                  fontSize: 17,
                  color: ColorsRes.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        onPressed: () {
          formSubmit();
        },
        color: ColorsRes.secondaryButton);
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
    // if (grnCodeController.text.isNotEmpty &&
    //     prnCodeController.text.isNotEmpty) {
    //   setState(() {
    //     showQRScan = true;
    //     headerTitle = 'GRN #' + grnCodeController.text;
    //   });
    // } else {
    //   if (grnCodeController.text.isEmpty) {
    //     setState(() {
    //       _validateGRN = true;
    //     });
    //   }
    //   if (prnCodeController.text.isEmpty) {
    //     setState(() {
    //       _validatePRN = true;
    //     });
    //   }
    // }
  }
}
