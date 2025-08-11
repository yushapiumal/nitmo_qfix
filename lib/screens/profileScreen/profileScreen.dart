import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:qfix_nitmo_new/screens/profileScreen/device/mobileProfileScreen.dart';
import 'package:qfix_nitmo_new/screens/profileScreen/device/tabletProfileScreen.dart';
import 'package:qfix_nitmo_new/ui/responsiveLayout.dart';


class ProfileScreen extends StatefulWidget {
  static String routeName = "/profile";
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileBody: MobileProfileScreen(),
      tabletBody: TabletProfileScreen(),
    );
  }
}
