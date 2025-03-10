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
  late StreamSubscription<List<ConnectivityResult>> subscription;
  late StreamSubscription<InternetConnectionStatus> internetSubscription;
  List<ConnectivityResult> result = [ConnectivityResult.none];
  bool hasConnection = false;

  @override
  void initState() {
    super.initState();
    initLocations();
    if (mounted) {
      setState(() => {});
    }

    subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> connectivityResult) {
      setState(() {
        result = connectivityResult;
      });
    });

    internetSubscription = InternetConnectionChecker.createInstance()
        .onStatusChange
        .listen((InternetConnectionStatus event) async {
      final hasInternet = event == InternetConnectionStatus.connected;
      setState(() {
        hasConnection = hasInternet;
      });
      await checkConnection();
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    internetSubscription.cancel();
    super.dispose();
  }

  Future<void> checkConnection() async {
    hasConnection = await InternetConnectionChecker.createInstance().hasConnection;
    result = await Connectivity().checkConnectivity();
    final text = hasConnection ? 'Connected with' : 'No Internet';
    final color = hasConnection ? Colors.green : Colors.red;

    print('hasConnection: $hasConnection');
    print('result: $result');
    print('text: $text');
    print('color: $color');
    if (result.contains(ConnectivityResult.mobile)) {
      showSimpleNotification(
        Text(
          '$text : Mobile Network',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        background: color,
      );
    } else if (result.contains(ConnectivityResult.wifi)) {
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
                textSelectionTheme: const TextSelectionThemeData(
                  cursorColor: Colors.black,
                ),
                appBarTheme: const AppBarTheme(
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