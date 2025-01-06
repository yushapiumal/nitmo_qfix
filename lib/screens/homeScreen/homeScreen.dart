import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qfix_nitmo_new/ui/responsiveLayout.dart';

import 'devices/mobileHome.dart';
import 'devices/tableHome.dart';

class HomeScreen extends StatelessWidget {
  static String routeName = "/home";
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: MobileHome(),
      tabletBody: TabletHome(),
    );
  }
}
