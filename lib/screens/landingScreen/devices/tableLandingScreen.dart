import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:localstorage/localstorage.dart';
import 'package:octo_image/octo_image.dart';
import 'package:provider/provider.dart';
import 'package:qfix_nitmo_new/Constant/Slideanimation.dart';
import 'package:qfix_nitmo_new/api/apiService.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
import 'package:qfix_nitmo_new/helper/DesignConfig.dart';
import 'package:qfix_nitmo_new/helper/StringsRes.dart';
import 'package:qfix_nitmo_new/provider/locale_provider.dart';
import 'package:qfix_nitmo_new/screens/loginScreen/loginScreen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class TableLandingScreen extends StatefulWidget {
  const TableLandingScreen({Key? key}) : super(key: key);

  @override
  State<TableLandingScreen> createState() => _TableLandingScreenState();
}

class _TableLandingScreenState extends State<TableLandingScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  TextEditingController tenantCodeController = TextEditingController();
  final LocalStorage storage = LocalStorage('qfix');
  bool _validate = false;
  APIService apiService = APIService();
  int selectedBg = 0;
  List backgroundArray = [
    "assets/img/d_1.webp",
    "assets/img/d_2.webp",
    "assets/img/d_3.webp",
    "assets/img/d_5.webp",
    "assets/img/d_6.webp",
  ];
  bool btnDisable = false;
  double foo = 100.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );
    _timer = startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController!.dispose();
    super.dispose();
  }

  Timer startTimer() {
    const duration = Duration(seconds: 5);
    return Timer.periodic(duration, (timer) {
      if (!mounted) {
        // Stop the timer if the widget is no longer mounted
        timer.cancel();
        return;
      }
      setState(() {
        selectedBg = (selectedBg + 1) % 5;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return true as Future<bool>;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          child: Stack(
            children: [
              Transform.translate(
                offset: new Offset(0.0, 0.0),
                child: Image.asset(
                  backgroundArray[selectedBg],
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SlideAnimation(
                    position: 1,
                    itemCount: 8,
                    slideDirection: SlideDirection.fromTop,
                    animationController: _animationController,
                    child: Column(
                      children: [
                        Container(
                          child: Image.asset(
                            'assets/icon/qfix-logo.png',
                            width: MediaQuery.of(context).size.width / 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        // Text(
                        //   'Please enter your company name',
                        //   style: TextStyle(
                        //     fontSize: 18,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        SizedBox(
                          height: 10,
                        ),
                        showTenantCodePicker(),
                        _validate
                            ? Text(
                                AppLocalizations.of(context)!.errorCompanyCode,
                                style: TextStyle(
                                  color: Colors.red[800],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              )
                            : SizedBox()
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 22,
                  ),
                  SlideAnimation(
                    position: 3,
                    itemCount: 8,
                    slideDirection: SlideDirection.fromBottom,
                    animationController: _animationController,
                    child: GestureDetector(
                      onTap: () {
                        btnDisable ? false : checkTenant();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(
                            // top: MediaQuery.of(context).size.height / 50,
                            left: MediaQuery.of(context).size.width / 8,
                            right: MediaQuery.of(context).size.width / 8),
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height / 60,
                          bottom: MediaQuery.of(context).size.height / 60,
                        ),
                        decoration: DesignConfig.boxDecorationContainer(
                            ColorsRes.primaryButton, 10.0),
                        child: Text(
                          btnDisable
                              ? AppLocalizations.of(context)!.checking
                              : AppLocalizations.of(context)!.login,
                          style: TextStyle(
                              fontSize: 18,
                              color: ColorsRes.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  SlideAnimation(
                    position: 3,
                    itemCount: 8,
                    slideDirection: SlideDirection.fromBottom,
                    animationController: _animationController,
                    child: langPicker(),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  checkTenant() async {
    if (tenantCodeController.text.isNotEmpty) {
      setState(() {
        btnDisable = true;
      });
      var text = tenantCodeController.text.toLowerCase();
      var check =
          await apiService.checkTenant(text.replaceAll(RegExp(r"\s+"), ""));
      if (check) {
        setState(() {
          btnDisable = false;
        });
        Navigator.popAndPushNamed(context, LoginScreen.routeName);
      } else {
        setState(() {
          btnDisable = false;
        });
      }
    } else {
      setState(() {
        _validate = true;
      });
    }
  }

  Widget langPicker() {
    final provider = Provider.of<LocaleProvider>(context);
    final locale = provider.locale ?? Locale('en');

    var selectedLang = storage.getItem('lang');

    return Container(
      margin: EdgeInsets.only(
        top: 20.0,
        left: 30.0,
        right: 30.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            child: ElevatedButton(
              child: Text(
                'EN',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                provider.setLocale(Locale('en'));
                storage.setItem('lang', 'en');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: (selectedLang == 'en') ? Colors.amber[100] : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // <-- Radius
                ),
              ),
            ),
          ),
          GestureDetector(
            child: ElevatedButton(
              child: Text(
                'සිං',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                provider.setLocale(Locale('si'));
                storage.setItem('lang', 'si');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: (selectedLang == 'si') ? Colors.amber[100] : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // <-- Radius
                ),
              ),
            ),
          ),
          GestureDetector(
            child: ElevatedButton(
              child: Text(
                'தமிழ்',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                provider.setLocale(Locale('ta'));
                storage.setItem('lang', 'ta');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: (selectedLang == 'ta') ? Colors.amber[100] : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // <-- Radius
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget showTenantCodePicker() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 8,
          vertical: MediaQuery.of(context).size.width / 45),
      child: SlideAnimation(
        position: 3,
        itemCount: 10,
        slideDirection: SlideDirection.fromRight,
        animationController: _animationController,
        child: TextFormField(
          validator: (val) {
            if (val!.isNotEmpty) {
              return null;
            } else {
              return 'Please enter username';
            }
          },
          onChanged: (_) {
            setState(() {
              _validate = false;
            });
          },
          controller: tenantCodeController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height / 60,
              horizontal: MediaQuery.of(context).size.height / 60,
            ),
            hintStyle: TextStyle(
                color: ColorsRes.purpalColor,
                fontSize: 18,
                fontWeight: FontWeight.normal),
            labelStyle: TextStyle(
                color: ColorsRes.black,
                fontSize: 18,
                fontWeight: FontWeight.normal),
            filled: false,
            focusColor: ColorsRes.black,
            focusedBorder: OutlineInputBorder(
              gapPadding: 0.0,
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: ColorsRes.black,
              ),
            ),
            border: OutlineInputBorder(
              gapPadding: 0.0,
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: ColorsRes.black,
                width: 1.5,
              ),
            ),
            labelText: AppLocalizations.of(context)!
                .companycode, //StringsRes.emailText,
            hintText: AppLocalizations.of(context)!
                .companycode, //StringsRes.emailAddressText,
          ),
        ),
      ),
    );
  }
}
