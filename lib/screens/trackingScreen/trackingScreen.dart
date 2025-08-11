import 'package:flutter/src/widgets/framework.dart';
import 'package:qfix_nitmo_new/screens/trackingScreen/devices/mobileTracking.dart';
import 'package:qfix_nitmo_new/screens/trackingScreen/devices/tabletTracking.dart';
import 'package:qfix_nitmo_new/ui/responsiveLayout.dart';


class TrackingDetails extends StatefulWidget {
  static String routeName = "/tracking";

  const TrackingDetails({Key? key, required this.csrId}) : super(key: key);
  final csrId;

  @override
  State<TrackingDetails> createState() => _TrackingDetailsState();
}

class _TrackingDetailsState extends State<TrackingDetails> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: MobileTracking(csrId: widget.csrId),
      tabletBody: TabletTracking(csrId: widget.csrId),
    );
  }
}
