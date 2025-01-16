import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:qfix_nitmo_new/screens/manageGRNScreen/devices/mobileGRNScreen.dart';
import 'package:qfix_nitmo_new/screens/manageGRNScreen/devices/tabletGRNScreen.dart';
import 'package:qfix_nitmo_new/ui/responsiveLayout.dart';

class ManageGRNScreen extends StatelessWidget {
  static String routeName = "/manage-grn";
  const ManageGRNScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: MobileGRNScreen(),
      tabletBody: TabletGRNScreen(),
    );
  }
}
