import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
import 'package:octo_image/octo_image.dart';
import 'package:qfix_nitmo_new/Constant/Slideanimation.dart';
import 'package:qfix_nitmo_new/api/apiService.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
import 'package:qfix_nitmo_new/helper/StringsRes.dart';
import 'package:qfix_nitmo_new/l10n/app_localizations.dart';
import 'package:qfix_nitmo_new/screens/homeScreen/homeScreen.dart';
import 'package:qfix_nitmo_new/screens/landingScreen/landingScreen.dart';


class MobileLogin extends StatefulWidget {
  // const MobileLogin({Key? key}) : super(key: key);

  @override
  State<MobileLogin> createState() => _MobileLoginState();
}

class _MobileLoginState extends State<MobileLogin>
    with SingleTickerProviderStateMixin {
  final LocalStorage storage = LocalStorage('qfix');
  final formKey = GlobalKey<FormState>();

  late FirebaseMessaging messaging;
  bool _obscureTextPassword = true;
  AnimationController? _animationController;
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  bool _validate = false;
  String errorMsg = "";
  APIService apiServer = APIService();
  String? _deviceId;
  bool loader = false;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    setFirebaseToken();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  setFirebaseToken() async {
    messaging = FirebaseMessaging.instance;
    // await storage.ready.then((_) => {
    messaging.getToken().then((value) {
      // print('messaging token ${value}');
      storage.setItem('messageToken', value);
    });
    // });
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  Widget showEmail() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 12,
          vertical: MediaQuery.of(context).size.width / 40),
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
              return AppLocalizations.of(context)!.errorUsername;
            }
          },
          onChanged: (_) {
            setState(() {
              errorMsg = "";
              _validate = false;
            });
          },
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(left: 15.0),
            hintStyle: TextStyle(
                color: ColorsRes.purpalColor,
                fontSize: 16,
                fontWeight: FontWeight.normal),
            labelStyle: TextStyle(
                color: ColorsRes.warmGreyColor,
                fontSize: 16,
                fontWeight: FontWeight.normal),
            filled: false,
            focusColor: ColorsRes.black,
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
            labelText:
                AppLocalizations.of(context)!.username, //StringsRes.emailText,
            hintText: "", //StringsRes.emailAddressText,
          ),
        ),
      ),
    );
  }

  Widget showPassword() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 12,
          vertical: MediaQuery.of(context).size.width / 40),
      child: SlideAnimation(
        position: 4,
        itemCount: 10,
        slideDirection: SlideDirection.fromRight,
        animationController: _animationController,
        child: TextFormField(
          validator: (val) {
            if (val!.isNotEmpty) {
              return null;
            } else {
              return AppLocalizations.of(context)!.errorPassword;
            }
          },
          onChanged: (_) {
            setState(() {
              errorMsg = "";
              _validate = false;
            });
          },
          obscureText: _obscureTextPassword,
          controller: passwordController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(left: 15.0),
            hintStyle: TextStyle(
                color: ColorsRes.purpalColor,
                fontSize: 16,
                fontWeight: FontWeight.normal),
            labelStyle: TextStyle(
                color: ColorsRes.warmGreyColor,
                fontSize: 16,
                fontWeight: FontWeight.normal),
            filled: false,
            focusColor: ColorsRes.black,
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
            labelText: AppLocalizations.of(context)!.password,
            hintText: "",
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  _obscureTextPassword = !_obscureTextPassword;
                });
              },
              child: Icon(
                _obscureTextPassword ? Icons.visibility_off : Icons.visibility,
                color: ColorsRes.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  checkEmailValidate() {
    bool emailValid = RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
        .hasMatch(emailController.text);
    setState(() {
      errorMsg = AppLocalizations.of(context)!.errorEmail;
      _validate = !emailValid;
    });
  }

  login() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        loader = true;
      });
      // checkEmailValidate();
      if (!_validate) {
        setState(() {
          errorMsg = "";
        });
        var log = await apiServer.login(
            emailController.text, passwordController.text);

        if (log) {
          Navigator.popAndPushNamed(context, HomeScreen.routeName);
        } else {
          setState(() {
            loader = false;
          });
        }
      }
    }
    // if (emailController.text.isEmpty || passwordController.text.isEmpty) {
    //   setState(() {
    //     errorMsg = "Please enter login details";
    //     _validate = true;
    //   });
    // } else {
    //   setState(() {
    //     loader = true;
    //   });
    //   // checkEmailValidate();
    //   if (!_validate) {
    //     setState(() {
    //       errorMsg = "";
    //     });
    //     var log = await apiServer.login(
    //         emailController.text, passwordController.text);

    //     if (log) {
    //       Navigator.popAndPushNamed(context, HomeScreen.routeName);
    //     } else {
    //       setState(() {
    //         loader = false;
    //       });
    //     }
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
      ),
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: ColorsRes.backgroundColor,
          appBar: AppBar(
            backgroundColor: ColorsRes.backgroundColor,
            shadowColor: Colors.transparent,
            leading: SlideAnimation(
              position: 1,
              itemCount: 8,
              slideDirection: SlideDirection.fromTop,
              animationController: _animationController,
              child: GestureDetector(
                onTap: () {
                  Navigator.popAndPushNamed(context, LandingScreen.routeName);
                },
                child: Padding(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width / 20),
                  child: Icon(Icons.close, color: ColorsRes.purpalColor),
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Image.asset(
                          'assets/icon/qfix-logo.png',
                          width: MediaQuery.of(context).size.width / 5,
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
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.width / 10,
                              left: MediaQuery.of(context).size.height / 22,
                              right: MediaQuery.of(context).size.height / 18,
                              bottom: 10.0),
                          child: SlideAnimation(
                            position: 2,
                            itemCount: 10,
                            slideDirection: SlideDirection.fromRight,
                            animationController: _animationController,
                            child: Text(
                              AppLocalizations.of(context)!.login,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: ColorsRes.purpalColor,
                                fontSize: 28,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height / 20),
                      showEmail(),
                      showPassword(),

                      SizedBox(height: MediaQuery.of(context).size.height / 60),
                      GestureDetector(
                        onTap: () async {
                          await apiServer.showToast(
                              AppLocalizations.of(context)!
                                  .contactAdministrator);
                        },
                        child: SlideAnimation(
                          position: 5,
                          itemCount: 10,
                          slideDirection: SlideDirection.fromRight,
                          animationController: _animationController,
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height / 99,
                                right: MediaQuery.of(context).size.width / 12,
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.forgotPassword,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: ColorsRes.purpalColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height / 20),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              loader
                                  ? Container(
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              new AlwaysStoppedAnimation<Color>(
                                                  Colors.blue),
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                              SizedBox(
                                width: 20,
                              ),
                              SlideAnimation(
                                position: 6,
                                itemCount: 10,
                                slideDirection: SlideDirection.fromRight,
                                animationController: _animationController,
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      login();
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          right: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              15),
                                      padding: EdgeInsets.all(20.0),
                                      decoration: BoxDecoration(
                                          color: ColorsRes.secondaryButton,
                                          shape: BoxShape.circle),
                                      child: Icon(Icons.arrow_forward,
                                          color: ColorsRes.black),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Padding(
                      //   padding: EdgeInsets.only(
                      //     top: MediaQuery.of(context).size.height / 15,
                      //   ),
                      //   child: Column(
                      //     children: [
                      //       SlideAnimation(
                      //         position: 7,
                      //         itemCount: 10,
                      //         slideDirection: SlideDirection.fromRight,
                      //         animationController: _animationController,
                      //         child: Text(
                      //           StringsRes.loginWithSocialMediaText,
                      //           textAlign: TextAlign.center,
                      //           style: TextStyle(
                      //             color: ColorsRes.purpalColor,
                      //             fontSize: 16,
                      //             fontWeight: FontWeight.normal,
                      //           ),
                      //         ),
                      //       ),
                      //       SizedBox(
                      //         height: MediaQuery.of(context).size.height / 99,
                      //       ),
                      //       Row(
                      //         mainAxisAlignment: MainAxisAlignment.center,
                      //         children: [
                      //           SlideAnimation(
                      //             position: 8,
                      //             itemCount: 10,
                      //             slideDirection: SlideDirection.fromRight,
                      //             animationController: _animationController,
                      //             child: Container(
                      //               decoration: DesignConfig.buttonShadowColor(
                      //                   ColorsRes.greyColor, 10.0),
                      //               child: SvgPicture.asset(
                      //                 "assets/svg/fb.svg",
                      //               ),
                      //             ),
                      //           ),
                      //           SizedBox(width: 10.0),
                      //           SlideAnimation(
                      //             position: 9,
                      //             itemCount: 10,
                      //             slideDirection: SlideDirection.fromRight,
                      //             animationController: _animationController,
                      //             child: Container(
                      //               decoration: DesignConfig.buttonShadowColor(
                      //                   ColorsRes.greyColor, 10.0),
                      //               child: SvgPicture.asset(
                      //                 "assets/svg/google.svg",
                      //               ),
                      //             ),
                      //           )
                      //         ],
                      //       )
                      //     ],
                      //   ),
                      // ),
                      SizedBox(height: MediaQuery.of(context).size.height / 25),
                      // SlideAnimation(
                      //   position: 10,
                      //   itemCount: 10,
                      //   slideDirection: SlideDirection.fromBottom,
                      //   animationController: _animationController,
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     children: [
                      //       Padding(
                      //         padding: EdgeInsets.only(
                      //             top: 15.0,
                      //             left: MediaQuery.of(context).size.width / 12,
                      //             right: 10.0),
                      //         child: Text(
                      //           StringsRes.doNotHaveAccountText,
                      //           textAlign: TextAlign.center,
                      //           style: TextStyle(
                      //             color: ColorsRes.greyColor,
                      //             fontSize: 16,
                      //             fontWeight: FontWeight.normal,
                      //           ),
                      //         ),
                      //       ),
                      //       GestureDetector(
                      //         onTap: () {},
                      //         child: Padding(
                      //           padding: EdgeInsets.only(
                      //               top: 15.0,
                      //               right: MediaQuery.of(context).size.width / 12),
                      //           child: Text(
                      //             StringsRes.signUpText,
                      //             textAlign: TextAlign.center,
                      //             style: TextStyle(
                      //               color: ColorsRes.purpalColor,
                      //               fontSize: 16,
                      //               fontWeight: FontWeight.normal,
                      //               decoration: TextDecoration.underline,
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
