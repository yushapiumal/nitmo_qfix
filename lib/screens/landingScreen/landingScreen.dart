import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:qfix_nitmo_new/screens/landingScreen/devices/mobileLandingScreen.dart';
import 'package:qfix_nitmo_new/screens/landingScreen/devices/tableLandingScreen.dart';
import 'package:qfix_nitmo_new/ui/responsiveLayout.dart';

class LandingScreen extends StatelessWidget {
  static String routeName = "/landing";
  const LandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: MobileLandingScreen(),
      tabletBody: TableLandingScreen(),
    );
  }
}
