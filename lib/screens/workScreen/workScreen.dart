import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qfix_nitmo_new/screens/workScreen/devices/mobileWork.dart';
import 'package:qfix_nitmo_new/screens/workScreen/devices/tabletWork.dart';
import 'package:qfix_nitmo_new/ui/responsiveLayout.dart';


class WorkScreen extends StatefulWidget {
  static String routeName = "/complete";

  const WorkScreen({Key? key,required this.taskData, required this.markUpdateTask}) : super(key: key);
  final markUpdateTask;
  final taskData;

  @override
  State<WorkScreen> createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: MobileWork(markUpdateTask: widget.markUpdateTask , taskData: widget.taskData),
      tabletBody: TabletWork(markUpdateTask: widget.markUpdateTask , taskData: widget.taskData),
    );
  }
}
