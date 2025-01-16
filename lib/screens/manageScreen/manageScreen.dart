import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qfix_nitmo_new/screens/manageScreen/devices/mobileManage.dart';
import 'package:qfix_nitmo_new/screens/manageScreen/devices/tabletManage.dart';
import 'package:qfix_nitmo_new/ui/responsiveLayout.dart';

class ManageScreen extends StatefulWidget {
  static String routeName = "/manage";
  const ManageScreen({Key? key, required this.taskData}) : super(key: key);
  final taskData;

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: MobileManage(taskData: widget.taskData),
      tabletBody: TabletManage(taskData: widget.taskData),
    );
  }
}
