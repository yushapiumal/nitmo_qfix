import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qfix_nitmo_new/screens/siteScreen/devices/mobileSites.dart';
import 'package:qfix_nitmo_new/screens/siteScreen/devices/tabletSites.dart';
import 'package:qfix_nitmo_new/ui/responsiveLayout.dart';

class SiteScreen extends StatefulWidget {
  static String routeName = "/delay";
  const SiteScreen({Key? key, required this.markUpdateTask}) : super(key: key);
  final markUpdateTask;
  @override
  State<SiteScreen> createState() => _SiteScreenState();
}

class _SiteScreenState extends State<SiteScreen> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: MobileSites(markUpdateTask: widget.markUpdateTask),
      tabletBody: TabletSites(markUpdateTask: widget.markUpdateTask),
    );
  }
}
