import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:qfix_nitmo_new/ui/responsiveLayout.dart';


import 'devices/mobileStoreScreen.dart';
import 'devices/tabletStoreScreen.dart';

class CheckStoreScreen extends StatelessWidget {
  static String routeName = "/manage-store";
  const CheckStoreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: MobileStoreScreen(),
      tabletBody: TabletStoreScreen(),
    );
  }
}
