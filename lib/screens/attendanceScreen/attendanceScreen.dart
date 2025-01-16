import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:qfix_nitmo_new/screens/attendanceScreen/devices/mobileAttendace.dart';
import 'package:qfix_nitmo_new/screens/attendanceScreen/devices/tabletAttendance.dart';
import 'package:qfix_nitmo_new/ui/responsiveLayout.dart';

class AttendanceScreen extends StatefulWidget {
  static String routeName = "/attendance";
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: MobileAttendance(),
      tabletBody: TabletAttendance(),
    );
  }
}
