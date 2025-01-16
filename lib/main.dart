import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
import 'package:qfix_nitmo_new/l10n/l10n.dart';
import 'package:qfix_nitmo_new/provider/locale_provider.dart';
import 'api/geoShare.dart';
import 'firebase_options.dart';
import 'route.dart';
import 'screens/splashScreen/splashScreen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
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
   Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => LocaleProvider(),
        builder: (context, child) {
          final provider = Provider.of<LocaleProvider>(context);
          return OverlaySupport(
            child: MaterialApp(
              title: 'QFix',
              theme: ThemeData(
                textSelectionTheme: TextSelectionThemeData(
                  cursorColor: Colors.black,
                ),
                appBarTheme: AppBarTheme(
                  backgroundColor: ColorsRes.appBarBG,
                  iconTheme: IconThemeData(
                    color: Colors.white,
                  ),
                ),
                fontFamily: GoogleFonts.lato().fontFamily,
              ),
              navigatorKey: navigatorKey,
              supportedLocales: L10n.all,
              locale: provider.locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
               GlobalWidgetsLocalizations.delegate,
              ],
              debugShowCheckedModeBanner: false,
              initialRoute: SplashScreen.routeName,
              routes: routes,
            ),
          );
        },
      );
}
