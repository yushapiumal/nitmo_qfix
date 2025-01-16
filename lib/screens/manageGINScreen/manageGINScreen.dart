import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:qfix_nitmo_new/screens/manageGINScreen/devices/mobileGINScreen.dart';
import 'package:qfix_nitmo_new/screens/manageGINScreen/devices/tabletGINScreen.dart';
import 'package:qfix_nitmo_new/ui/responsiveLayout.dart';

class ManageGINScreen extends StatelessWidget {
  static String routeName = "/manage-gri";
  const ManageGINScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: MobileGINScreen(),
      tabletBody: TabletGINScreen(),
    );
  }
}
