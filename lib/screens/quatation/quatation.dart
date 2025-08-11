import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qfix_nitmo_new/screens/quatation/devices/mobileQuation.dart';
import 'package:qfix_nitmo_new/screens/quatation/devices/tabletQuation.dart';
import 'package:qfix_nitmo_new/ui/responsiveLayout.dart';

class QuatationOrInvoice extends StatefulWidget {
  static String routeName = "/QuatationOrInvoice";
  const QuatationOrInvoice({Key? key}) : super(key: key);

  @override
  State<QuatationOrInvoice> createState() => _QuatationOrInvoiceState();
}

class _QuatationOrInvoiceState extends State<QuatationOrInvoice> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: MobileQuotationOrInvoice(),
      tabletBody: const TabletQuotationOrInvoice(),
    );
  }
}
