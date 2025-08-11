import 'package:flutter/widgets.dart';
import 'package:qfix_nitmo_new/screens/CreateQuatationScreen/devices/mobileCreateQuation.dart';
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
import 'package:qfix_nitmo_new/screens/quatation/devices/mobileQuation.dart';
import 'package:qfix_nitmo_new/screens/quatation/quatation.dart';
import 'package:qfix_nitmo_new/screens/siteScreen/siteScreen.dart';
import 'package:qfix_nitmo_new/screens/splashScreen/splashScreen.dart';
import 'package:qfix_nitmo_new/screens/trackingScreen/trackingScreen.dart';
import 'package:qfix_nitmo_new/screens/updateScreen/updateScreen.dart';
import 'package:qfix_nitmo_new/screens/workScreen/workScreen.dart';


final Map<String, WidgetBuilder> routes = {
  NoInternetScreen.routeName: (context) => const NoInternetScreen(),
  SplashScreen.routeName: (context) => const SplashScreen(),
  LandingScreen.routeName: (context) => const LandingScreen(),
  LoginScreen.routeName: (context) => const LoginScreen(),
  HomeScreen.routeName: (context) =>   const HomeScreen(markUpdateTask: false, ),
  ProfileScreen.routeName: (context) => const ProfileScreen(),
  ManageScreen.routeName: (context) =>  const ManageScreen(taskData: [],markUpdateTask: false,),
  DetailScreen.routeName: (context) =>
      const DetailScreen(taskData: [], markUpdateTask: false),
  SiteScreen.routeName: (context) => const SiteScreen(markUpdateTask: false),
  WorkScreen.routeName: (context) => const WorkScreen(markUpdateTask: false, taskData: [],),
  PartsScreen.routeName: (context) =>
      const PartsScreen(taskData: [], markUpdateTask: false),
  TrackingDetails.routeName: (context) => const TrackingDetails(csrId: null),
  NotificationScreen.routeName: (context) => const NotificationScreen(),
  QRScanScreen.routeName: (context) => const QRScanScreen(),
  ManageGRNScreen.routeName: (context) => const ManageGRNScreen(),
  ManageGINScreen.routeName: (context) => const ManageGINScreen(),
  CheckStoreScreen.routeName: (context) => const CheckStoreScreen(),
  AddNewItemScreen.routeName: (context) => const AddNewItemScreen(),
  AddNewCSRScreen.routeName: (context) => const AddNewCSRScreen(),
  NotificationScreen.routeName: (context) => const NotificationScreen(),
  AboutScreen.routeName: (context) => const AboutScreen(),
  AttendanceScreen.routeName: (context) => const AttendanceScreen(),
  QuatationOrInvoice.routeName: (context) => const QuatationOrInvoice(),
  MobileCreateDocumentScreen.routeName: (context) => const MobileCreateDocumentScreen(documentType: 'Quotation'),
  UpdateScreen.routeName: (context) => const UpdateScreen(markUpdateTask: false, taskData: [],),
};
