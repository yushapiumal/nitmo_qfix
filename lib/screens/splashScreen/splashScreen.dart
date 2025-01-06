import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qfix_nitmo_new/ui/responsiveLayout.dart';

import 'devices/mobileSplash.dart';
import 'devices/tabletSplash.dart';


class SplashScreen extends StatelessWidget {
  static String routeName = "/splash";
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileBody: MobileSplash(),
      tabletBody: TabletSplash(),
    );
  }
}
