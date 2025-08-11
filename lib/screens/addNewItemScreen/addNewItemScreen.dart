import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:qfix_nitmo_new/screens/addNewItemScreen/devices/mobileNewItemScreen.dart';
import 'package:qfix_nitmo_new/screens/addNewItemScreen/devices/tabletNewItemScreen.dart';
import 'package:qfix_nitmo_new/ui/responsiveLayout.dart';


class AddNewItemScreen extends StatelessWidget {
  static String routeName = "/new-item";
  const AddNewItemScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileBody: MobileNewItemScreen(),
      tabletBody: TabletNewItemScreen(),
    );
  }
}
