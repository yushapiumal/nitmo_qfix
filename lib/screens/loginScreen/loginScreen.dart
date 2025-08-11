import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qfix_nitmo_new/screens/loginScreen/devices/mobileLogin.dart';
import 'package:qfix_nitmo_new/screens/loginScreen/devices/tabletLogin.dart';
import 'package:qfix_nitmo_new/ui/responsiveLayout.dart';


class LoginScreen extends StatelessWidget {
  static String routeName = "/login";
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: MobileLogin(),
      tabletBody: const TabletLogin(),
    );
  }
}
