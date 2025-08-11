import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:qfix_nitmo_new/screens/addNewCsrScreen/devices/mobileNewCsr.dart';
import 'package:qfix_nitmo_new/screens/addNewCsrScreen/devices/tabletNewCsr.dart';
import 'package:qfix_nitmo_new/ui/responsiveLayout.dart';


class AddNewCSRScreen extends StatefulWidget {
  static String routeName = "/new-csr";
  const AddNewCSRScreen({Key? key}) : super(key: key);

  @override
  State<AddNewCSRScreen> createState() => _AddNewCSRScreenState();
}

class _AddNewCSRScreenState extends State<AddNewCSRScreen> {
  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileBody: MobileNewCsr(),
      tabletBody: TabletNewCsr(),
    );
  }
}
