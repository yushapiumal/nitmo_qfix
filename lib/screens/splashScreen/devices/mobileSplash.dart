import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
import 'package:qfix_nitmo_new/Constant/Slideanimation.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
import 'package:qfix_nitmo_new/screens/homeScreen/homeScreen.dart';
import 'package:qfix_nitmo_new/screens/landingScreen/landingScreen.dart';

class MobileSplash extends StatefulWidget {
  const MobileSplash({Key? key}) : super(key: key);

  @override
  State<MobileSplash> createState() => _MobileSplashState();
}

class _MobileSplashState extends State<MobileSplash>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  final LocalStorage storage = LocalStorage('qfix');

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    startTime();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  startTime() async {
    var _duration = Duration(milliseconds: 3500);
    return Timer(_duration, navigationPage);
  }

  Future<void> navigationPage() async {
    await storage.ready.then((_) => {
          if (storage.getItem('token') != null)
            {Navigator.popAndPushNamed(context, HomeScreen.routeName)}
          else
            {Navigator.popAndPushNamed(context, LandingScreen.routeName)}
        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return true as Future<bool>;
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: ColorsRes.backgroundColor,
          shadowColor: Colors.transparent,
        ),
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              color: ColorsRes.backgroundColor,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SlideAnimation(
                        position: 5,
                        itemCount: 8,
                        slideDirection: SlideDirection.fromBottom,
                        animationController: _animationController,
                        child: Column(
                          children: [
                            Container(
                              child: Image.asset(
                                'assets/icon/qfix-logo.png',
                                width: MediaQuery.of(context).size.width / 3.4,
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
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
