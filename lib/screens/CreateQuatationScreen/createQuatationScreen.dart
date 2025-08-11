import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qfix_nitmo_new/screens/CreateQuatationScreen/devices/mobileCreateQuation.dart';
import 'package:qfix_nitmo_new/screens/CreateQuatationScreen/devices/tabletCreateQuatation.dart';
import 'package:qfix_nitmo_new/ui/responsiveLayout.dart';

class CreateDoqument extends StatefulWidget {
  static String routeName = "/CreateDoqument";
  const CreateDoqument({Key? key}) : super(key: key);

  @override
  State<CreateDoqument> createState() => _CreateDoqumentState();
}

class _CreateDoqumentState extends State<CreateDoqument> {
  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileBody: MobileCreateDocumentScreen(documentType: '',),
      tabletBody: TabletCreateDocumentScreen(documentType: '',),
    );
  }
}


