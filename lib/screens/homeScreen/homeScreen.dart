import 'package:flutter/material.dart';
import 'package:qfix_nitmo_new/ui/responsiveLayout.dart';

import 'devices/mobileHome.dart';
import 'devices/tableHome.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = "/home";

  const HomeScreen({Key? key, required this.markUpdateTask}) : super(key: key);
  final  markUpdateTask;



  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: MobileHome(markUpdateTask:widget.markUpdateTask), // Use widget to access parent properties
      tabletBody: TabletHome(markUpdateTask:widget.markUpdateTask), // Use widget to access parent properties
    );
  }
}
