import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qfix_nitmo_new/screens/updateScreen/devices/mobileUpdate.dart';
import 'package:qfix_nitmo_new/screens/updateScreen/devices/tabletUpdate.dart';
import 'package:qfix_nitmo_new/ui/responsiveLayout.dart';


class UpdateScreen extends StatefulWidget {
  static String routeName = "/pending";

  const UpdateScreen({Key? key, required this.taskData, this.markUpdateTask})
      : super(key: key);
  final taskData;
  final markUpdateTask;
  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: MobileUpdate(
        markUpdateTask: widget.markUpdateTask,
        taskData: widget.taskData,
      ),
      tabletBody: TabletUpdate(
        markUpdateTask: widget.markUpdateTask,
        taskData: widget.taskData,
      ),
    );
  }
}
