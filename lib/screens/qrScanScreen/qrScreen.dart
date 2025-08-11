import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:qfix_nitmo_new/screens/qrScanScreen/devices/mobileQrScanScreen.dart';
import 'package:qfix_nitmo_new/ui/responsiveLayout.dart';

import 'devices/tableQrScanScreen.dart';


class QRScanScreen extends StatelessWidget {
  static String routeName = "/qr-scan";
  const QRScanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileBody: MobileQRScanScreen(),
      tabletBody: TabletQRScanScreen(),
    );
  }
}
