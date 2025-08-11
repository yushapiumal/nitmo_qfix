import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:qfix_nitmo_new/screens/aboutScreen/devices/mobileAbout.dart';
import 'package:qfix_nitmo_new/screens/aboutScreen/devices/tabletAbout.dart';
import 'package:qfix_nitmo_new/ui/responsiveLayout.dart';


class AboutScreen extends StatefulWidget {
  static String routeName = "/about";
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileBody: MobileAbout(),
      tabletBody: TabletAbout(),
    );
  }
}
