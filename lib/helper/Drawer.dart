import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:qfix_nitmo_new/api/apiService.dart';
import 'package:qfix_nitmo_new/l10n/app_localizations.dart';
import 'package:qfix_nitmo_new/screens/aboutScreen/aboutScreen.dart';
import 'package:qfix_nitmo_new/screens/addNewCsrScreen/addNewCsrScreen.dart';
import 'package:qfix_nitmo_new/screens/attendanceScreen/attendanceScreen.dart';
import 'package:qfix_nitmo_new/screens/landingScreen/landingScreen.dart';
import 'package:qfix_nitmo_new/screens/manageStoreScreen/checkStoreScreen.dart';
import 'package:qfix_nitmo_new/screens/profileScreen/profileScreen.dart';
import 'package:qfix_nitmo_new/screens/quatation/quatation.dart';
import 'package:qfix_nitmo_new/ui/responsiveLayout.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final LocalStorage storage = LocalStorage('qfix');

  String myName = "";
  String myId = "";
  APIService apiService = APIService();

  bool ginAccess = false;
  bool grnAccess = false;
  bool checkStoreAccess = false;
  bool addItemAccess = false;
  bool attendance = false;
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
                attendance = true;
              }),
            },

          if (storage.getItem('role') == 'stk_control')
            {
              setState(() {
                ginAccess = true;
                grnAccess = true;
                checkStoreAccess = true;
                addItemAccess = true;
                attendance = false;
              }),
            },

          if (storage.getItem('role') == 'tech')
            {
              setState(() {
                ginAccess = false;
                grnAccess = false;
                checkStoreAccess = true;
                addItemAccess = false;
                attendance = false;
              }),
            },
        });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(
                  "${AppLocalizations.of(context)!.name} : $myName",
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                ),
                accountEmail: Text(
                 "${AppLocalizations.of(context)!.sid} : $myId",
                  style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                ),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.5), BlendMode.dstATop),
                    image: const AssetImage(
                      'assets/img/coverBG.jpg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                currentAccountPicture: Container(
                  width: 100.0,
                  height: 100.0,
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    image: const DecorationImage(
                      image: AssetImage(
                        'assets/img/avatar1.png',
                      ),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                    border: Border.all(
                      color: Colors.red,
                      width: 3.0,
                    ),
                  ),
                ),
                //  CircleAvatar(
                //   radius: 40,
                //   backgroundColor: Colors.cyan[100],
                //   child: Image.asset(
                //     'assets/img/avatar1.png',
                //     fit: BoxFit.cover,
                //     width: 48,
                //   ),
                // ),
              ),
              ListTile(
                  leading: const Icon(Icons.person_pin_circle_rounded,
                      color: Colors.black),
                  title: Text(AppLocalizations.of(context)!.customerService),
                  onTap: () {
                    Navigator.popAndPushNamed(
                        context, AddNewCSRScreen.routeName);
                  }),
              // ListTile(
              //     leading: const Icon(Icons.description_outlined, color: Colors.black),
              //     title: const Text("New GIN"),
              //     // Groot Issue Note
              //     onTap: () {
              //       if (ginAccess) {
              //         Navigator.popAndPushNamed(
              //             context, ManageGINScreen.routeName);
              //       } else {
              //         apiService.showToast(AppLocalizations.of(context)!.permissionError);
              //       }
              //     }),
              // ListTile(
              //     leading: const Icon(Icons.edit_note_rounded, color: Colors.black),
              //     title: const Text("New GRN"),
              //     // Groot receive Note
              //     onTap: () {
              //       if (grnAccess) {
              //         Navigator.popAndPushNamed(
              //             context, ManageGRNScreen.routeName);
              //       } else {
              //         apiService.showToast(AppLocalizations.of(context)!.permissionError);
              //       }
              //     }),
              ListTile(
                  leading: const Icon(Icons.store, color: Colors.black),
                  title: Text(AppLocalizations.of(context)!.inventoryControl),
                  onTap: () {
                    if (checkStoreAccess) {
                      Navigator.popAndPushNamed(
                          context, CheckStoreScreen.routeName);
                    } else {
                      apiService.showToast(
                          AppLocalizations.of(context)!.permissionError);
                    }
                  }),
                  ListTile(
                  leading: const Icon(Icons.store, color: Colors.black),
                  title: const Text("Quotation/Invoice"),
                  onTap: () {
                    if (checkStoreAccess) {
                      Navigator.popAndPushNamed(
                          context, QuatationOrInvoice.routeName);
                    } else {
                      apiService.showToast(
                          AppLocalizations.of(context)!.permissionError);
                    }
                  }),


              ListTile(
                  leading:
                      const Icon(Icons.access_time_outlined, color: Colors.black),
                  title: Text(AppLocalizations.of(context)!.attendanceMenu),
                  onTap: () {
                    if (attendance) {
                      Navigator.popAndPushNamed(
                          context, AttendanceScreen.routeName);
                    } else {
                      apiService.showToast(
                          AppLocalizations.of(context)!.permissionError);
                    }
                  }),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.black),
                title: Text(AppLocalizations.of(context)!.settings),
                onTap: () async {
                  Navigator.popAndPushNamed(context, ProfileScreen.routeName);
                },
              ),
              ListTile(
                  leading: const Icon(Icons.info, color: Colors.black),
                  title: Text(AppLocalizations.of(context)!.about),
                  onTap: () {
                    Navigator.popAndPushNamed(context, AboutScreen.routeName);
                  }),
              ListTile(
                  leading: const Icon(Icons.power_settings_new, color: Colors.black),
                  title: Text(AppLocalizations.of(context)!.logout),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title:
                            Text(AppLocalizations.of(context)!.areyousure),
                        content: Text(
                            AppLocalizations.of(context)!.doyouwantlogout),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(
                                context), // Navigator.of(context).pop(false),
                            child: Text(AppLocalizations.of(context)!.no),
                          ),
                          TextButton(
                            // onPressed: () => Navigator.of(context).pop(true),
                            onPressed: () {
                              storage.clear();
                              Navigator.popAndPushNamed(
                                  context, LandingScreen.routeName);
                            },
                            child: Text(AppLocalizations.of(context)!.yes),
                          ),
                        ],
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
      tabletBody: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(
                  "Name : $myName",
                  style: const TextStyle(fontSize: 20, color: Colors.black),
                ),
                accountEmail: Text(
                  "S.ID : $myId",
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                ),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.5), BlendMode.dstATop),
                    image: const AssetImage(
                      'assets/img/coverBG.jpg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                currentAccountPicture: Container(
                  width: 100.0,
                  height: 100.0,
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    image: const DecorationImage(
                      image: AssetImage(
                        'assets/img/avatar1.png',
                      ),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                    border: Border.all(
                      color: Colors.red,
                      width: 3.0,
                    ),
                  ),
                ),
              ),
              ListTile(
                  leading: const Icon(
                    Icons.person_pin_circle_rounded,
                    color: Colors.black,
                    size: 35,
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.customerService,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  onTap: () {
                    Navigator.popAndPushNamed(
                        context, AddNewCSRScreen.routeName);
                  }),
              // ListTile(
              //     leading: const Icon(
              //       Icons.store,
              //       color: Colors.black,
              //       size: 35,
              //     ),
              //     title: Text(
              //       AppLocalizations.of(context)!.inventoryControl,
              //       style: const TextStyle(
              //         fontSize: 18,
              //       ),
              //     ),
              //     onTap: () {
              //       if (checkStoreAccess) {
              //         Navigator.popAndPushNamed(
              //             context, CheckStoreScreen.routeName);
              //       } else {
              //         apiService.showToast(
              //             AppLocalizations.of(context)!.permissionError);
              //       }
              //     }),
              ListTile(
                  leading: const Icon(
                    Icons.access_time_outlined,
                    color: Colors.black,
                    size: 35,
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.attendanceMenu,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  onTap: () {
                    if (attendance) {
                      Navigator.popAndPushNamed(
                          context,AttendanceScreen.routeName);
                    } else {
                      apiService.showToast(
                          AppLocalizations.of(context)!.permissionError);
                    }
                  }),
              const Divider(),
              ListTile(
                leading: const Icon(
                  Icons.settings,
                  color: Colors.black,
                  size: 35,
                ),
                title: Text(
                  AppLocalizations.of(context)!.settings,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
                onTap: () async {
                  Navigator.popAndPushNamed(context, ProfileScreen.routeName);
                },
              ),
              ListTile(
                  leading: const Icon(
                    Icons.info,
                    color: Colors.black,
                    size: 35,
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.about,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  onTap: () {
                    Navigator.popAndPushNamed(context, AboutScreen.routeName);
                  }),
              ListTile(
                  leading: const Icon(
                    Icons.power_settings_new,
                    color: Colors.black,
                    size: 35,
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.logout,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title:
                             Text(AppLocalizations.of(context)!.areyousure),
                        content:  Text(
                            AppLocalizations.of(context)!.doyouwantlogout),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(
                                context), // Navigator.of(context).pop(false),
                            child:  Text(AppLocalizations.of(context)!.no),
                          ),
                          TextButton(
                            // onPressed: () => Navigator.of(context).pop(true),
                            onPressed: () {
                              storage.clear();
                              Navigator.popAndPushNamed(
                                  context, LandingScreen.routeName);
                            },
                            child: Text(AppLocalizations.of(context)!.yes),
                          ),
                        ],
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
