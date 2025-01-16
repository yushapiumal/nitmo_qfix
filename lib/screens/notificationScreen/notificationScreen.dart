

import 'package:flutter/material.dart';
import 'package:qfix_nitmo_new/screens/notificationScreen/devices/tabletNotification.dart';
import 'package:qfix_nitmo_new/ui/responsiveLayout.dart';

import 'devices/mobileNotification.dart';

class NotificationScreen extends StatefulWidget {
  static String routeName = "/notification";

  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: MobileNotification(),
      tabletBody: TabletNotification(),
    );
  }
}
