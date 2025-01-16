import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qfix_nitmo_new/screens/partsScreen/devices/mobileParts.dart';
import 'package:qfix_nitmo_new/screens/partsScreen/devices/tabletParts.dart';
import 'package:qfix_nitmo_new/ui/responsiveLayout.dart';


class PartsScreen extends StatefulWidget {
  static String routeName = "/parts";

  const PartsScreen({Key? key, required this.taskData, this.markUpdateTask})
      : super(key: key);
  final taskData;
  final markUpdateTask;
  @override
  State<PartsScreen> createState() => _PartsScreenState();
}

class _PartsScreenState extends State<PartsScreen> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: MobileParts(
        taskData: widget.taskData,
        markUpdateTask: widget.markUpdateTask,
      ),
      tabletBody: TabletParts(
        taskData: widget.taskData,
        markUpdateTask: widget.markUpdateTask,
      ),
    );
  }
}
