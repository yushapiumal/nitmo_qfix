import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qfix_nitmo_new/screens/detailScreen/devices/mobileDetails.dart';
import 'package:qfix_nitmo_new/screens/detailScreen/devices/tabletDetails.dart';
import 'package:qfix_nitmo_new/ui/responsiveLayout.dart';


class DetailScreen extends StatefulWidget {
  static String routeName = "/start";
  const DetailScreen(
      {Key? key, required this.taskData, required this.markUpdateTask})
      : super(key: key);

  final taskData;
  final markUpdateTask;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: MobileDetails(
          taskData: widget.taskData, markUpdateTask: widget.markUpdateTask),
      tabletBody: TabletDetails(
          taskData: widget.taskData, markUpdateTask: widget.markUpdateTask),
    );
  }
}
