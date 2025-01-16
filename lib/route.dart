import 'package:flutter/widgets.dart';
import 'package:qfix_nitmo_new/screens/aboutScreen/aboutScreen.dart';
import 'package:qfix_nitmo_new/screens/addNewCsrScreen/addNewCsrScreen.dart';
import 'package:qfix_nitmo_new/screens/addNewItemScreen/addNewItemScreen.dart';
import 'package:qfix_nitmo_new/screens/attendanceScreen/attendanceScreen.dart';
import 'package:qfix_nitmo_new/screens/detailScreen/detailScreen.dart';
import 'package:qfix_nitmo_new/screens/homeScreen/homeScreen.dart';
import 'package:qfix_nitmo_new/screens/landingScreen/landingScreen.dart';
import 'package:qfix_nitmo_new/screens/loginScreen/loginScreen.dart';
import 'package:qfix_nitmo_new/screens/manageGINScreen/manageGINScreen.dart';
import 'package:qfix_nitmo_new/screens/manageGRNScreen/manageGRNScreen.dart';
import 'package:qfix_nitmo_new/screens/manageScreen/manageScreen.dart';
import 'package:qfix_nitmo_new/screens/manageStoreScreen/checkStoreScreen.dart';
import 'package:qfix_nitmo_new/screens/noInternetScreen/noInterneteScreen.dart';
import 'package:qfix_nitmo_new/screens/notificationScreen/notificationScreen.dart';
import 'package:qfix_nitmo_new/screens/partsScreen/partsScreen.dart';
import 'package:qfix_nitmo_new/screens/profileScreen/profileScreen.dart';
import 'package:qfix_nitmo_new/screens/qrScanScreen/qrScreen.dart';
import 'package:qfix_nitmo_new/screens/siteScreen/siteScreen.dart';
import 'package:qfix_nitmo_new/screens/splashScreen/splashScreen.dart';
import 'package:qfix_nitmo_new/screens/trackingScreen/trackingScreen.dart';
import 'package:qfix_nitmo_new/screens/workScreen/workScreen.dart';


final Map<String, WidgetBuilder> routes = {
  NoInternetScreen.routeName: (context) => NoInternetScreen(),
  SplashScreen.routeName: (context) => SplashScreen(),
  LandingScreen.routeName: (context) => LandingScreen(),
  LoginScreen.routeName: (context) => LoginScreen(),
  HomeScreen.routeName: (context) => HomeScreen(),
  ProfileScreen.routeName: (context) => ProfileScreen(),
  ManageScreen.routeName: (context) => ManageScreen(taskData: []),
  DetailScreen.routeName: (context) =>
      DetailScreen(taskData: [], markUpdateTask: false),
  SiteScreen.routeName: (context) => SiteScreen(markUpdateTask: false),
  WorkScreen.routeName: (context) => WorkScreen(markUpdateTask: false),
  PartsScreen.routeName: (context) =>
      PartsScreen(taskData: [], markUpdateTask: false),
  TrackingDetails.routeName: (context) => TrackingDetails(csrId: null),
  NotificationScreen.routeName: (context) => NotificationScreen(),
  QRScanScreen.routeName: (context) => QRScanScreen(),
  ManageGRNScreen.routeName: (context) => ManageGRNScreen(),
  ManageGINScreen.routeName: (context) => ManageGINScreen(),
  CheckStoreScreen.routeName: (context) => CheckStoreScreen(),
  AddNewItemScreen.routeName: (context) => AddNewItemScreen(),
  AddNewCSRScreen.routeName: (context) => AddNewCSRScreen(),
  NotificationScreen.routeName: (context) => NotificationScreen(),
  AboutScreen.routeName: (context) => AboutScreen(),
  AttendanceScreen.routeName: (context) => AttendanceScreen(),
};
