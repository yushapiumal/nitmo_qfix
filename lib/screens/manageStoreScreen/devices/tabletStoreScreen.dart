import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:localstorage/localstorage.dart';
import 'package:qfix_nitmo_new/Constant/SmartKitColor.dart';
import 'package:qfix_nitmo_new/api/apiService.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
import 'package:qfix_nitmo_new/helper/QRScanner.dart';
import 'package:qfix_nitmo_new/screens/addNewItemScreen/addNewItemScreen.dart';
import 'package:qfix_nitmo_new/screens/manageGINScreen/manageGINScreen.dart';
import 'package:qfix_nitmo_new/screens/manageGRNScreen/manageGRNScreen.dart';

class TabletStoreScreen extends StatefulWidget {
  const TabletStoreScreen({Key? key}) : super(key: key);

  @override
  State<TabletStoreScreen> createState() => _TabletStoreScreenState();
}

class _TabletStoreScreenState extends State<TabletStoreScreen>
    with TickerProviderStateMixin {
  final LocalStorage storage = LocalStorage('qfix');
  APIService apiService = APIService();
  String headerTitle = "Check Store";
  bool ginAccess = false;
  bool grnAccess = false;
  bool checkStoreAccess = false;
  bool addItemAccess = false;
  String myName = "";
  String myId = "";
  @override
  void initState() {
    super.initState();

    storage.ready.then((_) => {
          setState(() {
            myId = storage.getItem('sId');
            myName = storage.getItem('name');
          }),

          //'tech' => 'Technician',
          //'cro' => 'Customer Relations',
          //'admin' => 'Admin',
          //'stk_control' => 'Stock Control'
          if (storage.getItem('role') == 'admin')
            {
              setState(() {
                ginAccess = true;
                grnAccess = true;
                checkStoreAccess = true;
                addItemAccess = true;
              }),
            },

          if (storage.getItem('role') == 'stk_control')
            {
              setState(() {
                ginAccess = true;
                grnAccess = true;
                checkStoreAccess = true;
                addItemAccess = true;
              }),
            },

          if (storage.getItem('role') == 'tech')
            {
              setState(() {
                ginAccess = false;
                grnAccess = false;
                checkStoreAccess = true;
                addItemAccess = false;
              }),
            },
        });
  }

  formReset() {
    setState(() {
      headerTitle = "Check Store";
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: ColorsRes.backgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: 30,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          shadowColor: Colors.transparent,
          title: Text(
            headerTitle.toUpperCase(),
            style: TextStyle(
              letterSpacing: 4,
            ),
          ),
          bottom: PreferredSize(
            child: Divider(
              color: ColorsRes.greyColor,
              height: 2.3,
            ),
            preferredSize: Size(50, 5),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: showQRScanner(),
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          animatedIconTheme: IconThemeData(
            size: 35,
          ),
          curve: Curves.bounceIn,
          overlayColor: Colors.black,
          overlayOpacity: 0.5,
          onOpen: () => print('OPENING DIAL'),
          onClose: () => print('DIAL CLOSED'),
          tooltip: 'Speed Dial',
          heroTag: 'speed-dial-hero-tag',
          backgroundColor: ColorsRes.secondaryButton,
          foregroundColor: Colors.black,
          elevation: 8.0,
          shape: CircleBorder(),
          children: [
            SpeedDialChild(
                child: Icon(
                  Icons.description_outlined,
                  size: 35,
                ),
                backgroundColor: eStudy2,
                label: 'New GIN',
                labelStyle: TextStyle(
                  fontSize: 18,
                ),
                onTap: () {
                  if (ginAccess) {
                    Navigator.popAndPushNamed(
                        context, ManageGINScreen.routeName);
                  } else {
                    apiService.showToast('You do not have permission');
                  }
                }),
            SpeedDialChild(
              child: Icon(
                Icons.edit_note_rounded,
                size: 35,
              ),
              backgroundColor: Colors.amber,
              label: 'New GRN',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () {
                if (grnAccess) {
                  Navigator.popAndPushNamed(context, ManageGRNScreen.routeName);
                } else {
                  apiService.showToast('You do not have permission');
                }
              },
            ),
            SpeedDialChild(
              child: Icon(
                Icons.new_label_outlined,
                size: 35,
              ),
              backgroundColor: smartkey2,
              label: 'New Item',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () {
                if (addItemAccess) {
                  Navigator.popAndPushNamed(
                      context, AddNewItemScreen.routeName);
                } else {
                  apiService.showToast('You do not have permission');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  showQRScanner() {
    return QRScanner(
      ginTemplate: false,
      storeTemplate: true,
      grnTemplate: false,
      grnCode: 0,
      refNo: '',
      prnNo: '',
      formReset: formReset,
    );
  }
}
