import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:location/location.dart' as loc;
import 'package:qfix_nitmo_new/Constant/SmartKitColor.dart';
import 'package:qfix_nitmo_new/api/apiService.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
import 'package:qfix_nitmo_new/helper/DesignConfig.dart';
import 'package:qfix_nitmo_new/screens/detailScreen/detailScreen.dart';
import 'package:qfix_nitmo_new/screens/homeScreen/homeScreen.dart';
import 'package:qfix_nitmo_new/screens/partsScreen/partsScreen.dart';
import 'package:qfix_nitmo_new/screens/siteScreen/siteScreen.dart';
import 'package:qfix_nitmo_new/screens/trackingScreen/trackingScreen.dart';
import 'package:qfix_nitmo_new/screens/updateScreen/updateScreen.dart';
import 'package:qfix_nitmo_new/screens/workScreen/devices/mobileWork.dart';
import 'package:qfix_nitmo_new/screens/workScreen/workScreen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:signature/signature.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class MobileManage extends StatefulWidget {
  MobileManage({Key? key, required this.taskData, required this.markUpdateTask})
      : super(key: key);
  final markUpdateTask;
  final taskData;
  @override
  State<MobileManage> createState() => _MobileManageState();
}

class _MobileManageState extends State<MobileManage> {
  final LocalStorage storage = LocalStorage('qfix');
  int? selectedIndex = 0;
  String headerText = 'Details';
  APIService apiService = APIService();
  ChoiceChip? choiceChip;
  late List<Widget> fragments;
  bool updateStatus = false;
  String? _currentAddress;
  Position? _currentPosition;
  bool isPendingEnabled = false;
  int? id;

  @override
  void initState() {
    super.initState();
    fragments = [
      DetailScreen(taskData: widget.taskData, markUpdateTask: markUpdateTask),
      SiteScreen(markUpdateTask: markUpdateTask),
      WorkScreen(
        markUpdateTask: markUpdateTask,
        taskData: widget.taskData,
      ),
      PartsScreen(
        taskData: widget.taskData,
        markUpdateTask: markUpdateTask,
      ),
      TrackingDetails(csrId: widget.taskData.csr_id),
      UpdateScreen(taskData: widget.taskData, markUpdateTask: markUpdateTask),
    ];
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    locationAccessPermissions();
  }

  void updateTabSelection(int index, String buttonText) {
    setState(() {
      selectedIndex = index;
      headerText = buttonText;
    });
  }

  update(bool update) {
    if (update) {
      updateStatus = true;
    } else {
      updateStatus = false;
    }
  }

  locationAccessPermissions() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  markUpdateTask(type, buttonAction, detail) async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      locationAccessPermissions();
      return true;
    } else {
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      var updates = {
        'geo': '${_currentPosition!.longitude}, ${_currentPosition!.latitude}',
        'cts': timestamp.toString(),
        'typ': type + '/' + buttonAction,
        'fix': jsonEncode(detail),
        'sid': storage.getItem('sId'),
      };
      var submit = await apiService.markUpdateTask(
          widget.taskData.csr_id.toString(), updates);

      return submit;
    }
  }

  @override
  void dispose() {
    fragments = [];
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    // Show confirmation dialog
    final shouldNavigate = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.areyousure),
            content: Text(AppLocalizations.of(context)!.detailsScreen),
            actions: <Widget>[
              TextButton(
                onPressed: () =>
                    Navigator.pop(context, false), // User chose not to leave
                child: Text(AppLocalizations.of(context)!.no),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                  if (selectedIndex == 0) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomeScreen(
                                  markUpdateTask: widget.markUpdateTask,
                                )));
                  } // User confirmed they want to leave
                  else {
                    setState(() {
                      selectedIndex = 0;
                      headerText = "Details";
                    });
                  }
                },
                child: Text(AppLocalizations.of(context)!.yes),
              ),
            ],
          ),
        ) ??
        false;

    return shouldNavigate; // Return whether navigation should occur
  }

  String? complexity;
  bool btnDisable = false;
  toggleComplexity() async {
    var _duration = Duration(milliseconds: 2500);
    if (complexity == 'L1') {
      setState(() {
        complexity = 'L2';
      });
    } else if (complexity == 'L2') {
      setState(() {
        complexity = 'L3';
      });
    } else if (complexity == 'L3') {
      setState(() {
        complexity = 'L1';
      });
    }
    return Timer(_duration, callComplexityChangeApi);
  }

  callComplexityChangeApi() async {
    setState(() {
      btnDisable = true;
    });
    var submit = await markUpdateTask('complexity', complexity, false);
    if (submit || !submit) {
      setState(() {
        btnDisable = false;
      });
    }
  }

  void _showDialog(titleText, type) {
    if (type == 'reschedule') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ActivityModel(
              titleText: titleText,
              type: type,
              markUpdateTask: widget.markUpdateTask);
        },
      );
    }
    if (type == 'complete') {
      showModalBottomSheet(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        context: context,
        builder: (BuildContext context) {
          return Container(
            // Content of the bottom sheet
            height: MediaQuery.of(context).size.height /
                1.3, // Set the desired height
            child: ActivityModel(
              titleText: titleText,
              type: type,
              markUpdateTask: markUpdateTask,
            ),
          );
        },
      );
    }
  }

  appTopBar() {
    complexity = widget.taskData.complexity;
    return AppBar(
      elevation: 4,
      shadowColor: Colors.black,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
        ),
        onPressed: () {
          _onWillPop();
        },
      ),
      actions: [
        selectedIndex == 0
            ? GestureDetector(
                onDoubleTap: () {
                  btnDisable ? false : toggleComplexity();
                },
                child: Container(
                  margin: EdgeInsets.only(right: 12),
                  height: 28.0,
                  width: 28.0,
                  decoration: DesignConfig.complexityIcon(complexity),
                  child: Padding(
                    padding: EdgeInsets.all(2),
                    child: Center(
                      child: Text(
                        complexity.toString(),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              )
            : SizedBox()
      ],
      title: Text(
        'CSR #${widget.taskData.csr_id}',
        style: const TextStyle(
          color: ColorsRes.appBarText,
          letterSpacing: 4,
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: appTopBar(),
        //  title: Text(headerText),

        resizeToAvoidBottomInset: false,
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            fragments[selectedIndex!],
          ],
        ),

        floatingActionButton: SpeedDial(
          activeChild: CircleAvatar(
            radius: 28,
            child: ClipOval(
              child: Image.asset(
                'assets/img/clouse.png', // Open FAB image
                height: 40,
                width: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
          curve: Curves.bounceIn,
          overlayColor: Colors.black,
          overlayOpacity: 0.5,
          tooltip: 'Speed Dial',
          heroTag: 'speed-dial-hero-tag',
          backgroundColor: Colors.amber,
          foregroundColor: Colors.white,
          direction: SpeedDialDirection.up,
          elevation: 8.0,
          shape: CircleBorder(),
          children: [
            SpeedDialChild(
                child: const Icon(Icons.pending_actions_outlined),
                backgroundColor: const Color.fromARGB(255, 0, 255, 200),
                // Change color dynamically
                label: AppLocalizations.of(context)!.site,
                labelBackgroundColor: Color.fromARGB(255, 0, 255, 200),
                onTap: () async {
                  setState(() {
                    btnDisable = true; // Disable the Start button
                  });
                  var submit =
                      await markUpdateTask('site', 'on-the-way', false);
                  setState(() {
                    btnDisable = submit;
                    isPendingEnabled = submit;
                  });
                }),
            SpeedDialChild(
              child: Icon(
                btnDisable ? Icons.check : Icons.handyman_outlined,
                color: Colors.white,
              ),
              backgroundColor: btnDisable ? Colors.green : Colors.amber,
              label: btnDisable
                  ? AppLocalizations.of(context)!.finish
                  : AppLocalizations.of(context)!.start,
              labelBackgroundColor: btnDisable ? Colors.green : Colors.amber,
              onTap: btnDisable
                  ? () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Confirm"),
                            content: Text(
                              AppLocalizations.of(context)!.askfinish,
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text(
                                  AppLocalizations.of(context)!.no,
                                ),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                              ),
                              TextButton(
                                child: Text(
                                  AppLocalizations.of(context)!.yes,
                                ),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  _showDialog(
                                      AppLocalizations.of(context)!
                                          .markAsComplete,
                                      'complete');
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  : () async {
                      // Start work confirmation dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Confirm"),
                            content: Text(
                              AppLocalizations.of(context)!.askstart,
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text(
                                  AppLocalizations.of(context)!.no,
                                ),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                              ),
                              TextButton(
                                child: Text(
                                  AppLocalizations.of(context)!.yes,
                                ),
                                onPressed: () async {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                  setState(() {
                                    btnDisable =
                                        true; // Disable the Start button
                                  });
                                  var submit = await markUpdateTask(
                                      'work', 'start-work', false);
                                  setState(() {
                                    btnDisable =
                                        submit; // Keep Start disabled on success
                                    isPendingEnabled =
                                        submit; // Enable Pending button on success
                                  });
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
            ),
            SpeedDialChild(
              child: const Icon(Icons.pending_actions_outlined),
              backgroundColor: btnDisable
                  ? Colors.orange
                  : Colors.grey, // Change color dynamically
              label: AppLocalizations.of(context)!.update,
              labelBackgroundColor: Colors.orange,
              onTap: btnDisable
                  ? () {
                      setState(() {
                        selectedIndex = 2;
                        headerText = AppLocalizations.of(context)!.update;
                      });
                    }
                  : () {
                      Fluttertoast.showToast(
                        msg: AppLocalizations.of(context)!.startworkfirst,
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.orange,
                        textColor: Colors.black,
                      );
                    }, // Show toast if not started
            ),
            SpeedDialChild(
              child: const Icon(Icons.build_outlined),
              backgroundColor: btnDisable
                  ? const Color.fromARGB(255, 0, 132, 255)
                  : Colors.grey,
              label: AppLocalizations.of(context)!.parts,
              labelBackgroundColor: Color.fromARGB(255, 0, 132, 255),
              onTap: btnDisable
                  ? () {
                      setState(() {
                        selectedIndex = 3;
                        headerText = AppLocalizations.of(context)!.parts;
                      });
                    }
                  : () {
                      Fluttertoast.showToast(
                        msg: AppLocalizations.of(context)!.startworkfirst,
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: const Color.fromARGB(255, 0, 132, 255),
                        textColor: Colors.black,
                      );
                    }, // Show toast if not started
            ),
            SpeedDialChild(
              child: const Icon(Icons.access_time_rounded),
              backgroundColor: btnDisable
                  ? const Color.fromARGB(255, 215, 130, 226)
                  : const Color.fromARGB(255, 158, 158, 158),
              label: AppLocalizations.of(context)!.timeline,
              labelBackgroundColor: Color.fromARGB(255, 215, 130, 226),
              onTap: btnDisable
                  ? () {
                      setState(() {
                        selectedIndex = 4;
                        headerText = AppLocalizations.of(context)!.timeline;
                      });
                    }
                  : () {
                      Fluttertoast.showToast(
                        msg: AppLocalizations.of(context)!.startworkfirst,
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor:
                            const Color.fromARGB(255, 215, 130, 226),
                        textColor: Colors.black,
                      );
                    }, // Show toast if not started
            ),
          ],
          // Set the default and active children for the FAB
          child: CircleAvatar(
            backgroundColor: Colors.amber,
            radius: 28,
            child: ClipOval(
              child: Image.asset(
                'assets/img/technician.png', // Closed FAB image
                height: 40,
                width: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
