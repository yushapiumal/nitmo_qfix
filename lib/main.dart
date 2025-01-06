import 'dart:async';


import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:overlay_support/overlay_support.dart';
import 'api/geoShare.dart';
import 'firebase_options.dart';
import 'route.dart';
import 'screens/splashScreen/splashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(const NitmoAPP());
}

class NitmoAPP extends StatefulWidget {
  const NitmoAPP({Key? key}) : super(key: key);

  @override
  State<NitmoAPP> createState() => _NitmoAPPState();
}

class _NitmoAPPState extends State<NitmoAPP> {
  late StreamSubscription subscription;
  late StreamSubscription internetSubscription;
  ConnectivityResult result = ConnectivityResult.none;
  bool hasInternetConnection = false;
  bool hasConnection = false;

  @override
  void initState() {
    super.initState();
    initLocations();
    if (mounted) {
      setState(() => {});
    }

    subscription = Connectivity().onConnectivityChanged.listen((result) {
          setState(() {
            this.result = result as ConnectivityResult;
          });
        });

 internetSubscription = InternetConnectionChecker.createInstance()
    .onStatusChange
    .listen((event) {
  final hasInternet = event == InternetConnectionStatus.connected;
  setState(() {
    hasConnection = hasInternet;
  });
  checkConnection();
});

  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
    internetSubscription.cancel();
  }

void checkConnection() async {
  // Check internet connectivity
  final hasConnection = await InternetConnectionChecker.createInstance().hasConnection;

  // Check network type (WiFi/Mobile/None)
  final result = await Connectivity().checkConnectivity();

  // Determine notification text and color
  final text = hasConnection ? 'Connected with' : 'No Internet';
  final color = hasConnection ? Colors.green : Colors.red;

  // Show appropriate notification based on connectivity result
  if (result == ConnectivityResult.mobile) {
    showSimpleNotification(
      Text(
        '$text : Mobile Network',
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      background: color,
    );
  } else if (result == ConnectivityResult.wifi) {
    showSimpleNotification(
      Text(
        '$text : WiFi Network',
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      background: color,
    );
  } else {
    showSimpleNotification(
      Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      background: color,
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        title: 'QFix',
        theme: ThemeData(
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Colors.black,
          ),
          appBarTheme: const AppBarTheme(
          //  backgroundColor: ColorsRes.appBarBG,
            iconTheme: IconThemeData(
              color: Colors.white,
            ), // set backbutton color here which will reflect in all screens.
          ),
          fontFamily: GoogleFonts.lato().fontFamily,
        ),

        debugShowCheckedModeBanner: false,
        // home: MapScreen(),
        initialRoute: SplashScreen.routeName,
        routes: routes,
      ),
    );
  }
}
