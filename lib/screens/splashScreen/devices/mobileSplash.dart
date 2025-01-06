import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';

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
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    startTime();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  startTime() async {
    const duration = Duration(milliseconds: 3500);
    Timer(duration, navigationPage);
  }

  Future<void> navigationPage() async {
    await storage.ready;
    if (storage.getItem('token') != null) {
      // Navigate to HomeScreen
    } else {
      // Navigate to LandingScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          shadowColor: Colors.transparent,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/icon/qfix-logo.png',
                  width: MediaQuery.of(context).size.width / 3.4,
                ),
              ),
              const SizedBox(height: 20),
              // Additional widgets
            ],
          ),
        ),
      ),
    );
  }
}
