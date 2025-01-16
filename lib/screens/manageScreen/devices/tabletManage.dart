import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
import 'package:location/location.dart';
import 'package:qfix_nitmo_new/api/apiService.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
import 'package:qfix_nitmo_new/helper/DesignConfig.dart';
import 'package:qfix_nitmo_new/screens/detailScreen/detailScreen.dart';
import 'package:qfix_nitmo_new/screens/homeScreen/homeScreen.dart';
import 'package:qfix_nitmo_new/screens/partsScreen/partsScreen.dart';
import 'package:qfix_nitmo_new/screens/siteScreen/siteScreen.dart';
import 'package:qfix_nitmo_new/screens/trackingScreen/trackingScreen.dart';
import 'package:qfix_nitmo_new/screens/workScreen/workScreen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart' as geo;


class TabletManage extends StatefulWidget {
  const TabletManage({Key? key, required this.taskData}) : super(key: key);
  final taskData;
  @override
  State<TabletManage> createState() => _TabletManageState();
}

class _TabletManageState extends State<TabletManage> {
  final LocalStorage storage = LocalStorage('qfix');
  int? selectedIndex = 0;
  String headerText = 'Details';
  APIService apiService = APIService();
  ChoiceChip? choiceChip;
  late List<Widget> fragments;
  bool updateStatus = false;
  String? _currentAddress;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();

    fragments = [
      DetailScreen(taskData: widget.taskData, markUpdateTask: markUpdateTask),
      SiteScreen(markUpdateTask: markUpdateTask),
      WorkScreen(markUpdateTask: markUpdateTask),
      PartsScreen(
        taskData: widget.taskData,
        markUpdateTask: markUpdateTask,
      ),
      TrackingDetails(csrId: widget.taskData.csr_id),
    ];
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    //locationAccessPermissions();
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

  // locationAccessPermissions() async {
  //   final hasPermission = await _handleLocationPermission();
  //   if (!hasPermission) return;
  //   await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
  //       .then((Position position) {
  //     setState(() => _currentPosition = position);
  //   }).catchError((e) {
  //     debugPrint(e);
  //   });
  // }

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
     // locationAccessPermissions();
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
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text(AppLocalizations.of(context)!.areyousure),
            content: new Text(AppLocalizations.of(context)!.goTaskScreen),
            actions: <Widget>[
              TextButton(
                onPressed: () =>
                    Navigator.pop(context), // Navigator.of(context).pop(false),
                child: new Text(AppLocalizations.of(context)!.no),
              ),
              TextButton(
                // onPressed: () => Navigator.of(context).pop(true),
                onPressed: () =>
                    Navigator.pushNamed(context, HomeScreen.routeName),
                child: new Text(AppLocalizations.of(context)!.yes),
              ),
            ],
          ),
        )) ??
        false;
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

  appTopBar() {
    complexity = widget.taskData.complexity;
    return AppBar(
      elevation: 4,
      shadowColor: Colors.black,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          size: 30,
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
                  height: MediaQuery.of(context).size.width / 24,
                  width: MediaQuery.of(context).size.width / 24,
                  decoration: DesignConfig.complexityIcon(complexity),
                  child: Padding(
                    padding: EdgeInsets.all(2),
                    child: Center(
                      child: Text(
                        complexity.toString(),
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              )
            : SizedBox()
      ],
      title: Text(
        'CSR #${widget.taskData.csr_id}',
        style: TextStyle(
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
        resizeToAvoidBottomInset: false,
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            fragments[selectedIndex!],
          ],
        ),
        bottomNavigationBar: updateStatus
            ? Container(height: 0)
            : BottomAppBar(
                color: ColorsRes.backgroundColor,
                child: Container(
                  height: MediaQuery.of(context).size.height / 12,
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                      color: ColorsRes.backgroundColor,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15.0,
                          offset: Offset(
                            0.0,
                            -8.8,
                          ),
                        )
                      ],
                    ),
                    // padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Column(
                          children: [
                            IconButton(
                              onPressed: () {
                                updateTabSelection(0, "Details");
                              },
                              iconSize: 27.0,
                              icon: selectedIndex == 0
                                  ? Icon(
                                      Icons.description_outlined,
                                      color: ColorsRes.appBarBG,
                                      size: 35,
                                    )
                                  : Icon(
                                      Icons.description_outlined,
                                      color: ColorsRes.grayColor,
                                      size: 35,
                                    ),
                            ),
                            Text(
                              AppLocalizations.of(context)!.csr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: selectedIndex == 0
                                    ? ColorsRes.appBarBG
                                    : ColorsRes.grayColor,
                                fontSize: 18,
                              ),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            IconButton(
                              onPressed: () {
                                updateTabSelection(1, "Site");
                              },
                              iconSize: 27.0,
                              icon: selectedIndex == 1
                                  ? Icon(
                                      // Icons.schedule,
                                      Icons.business_outlined,
                                      color: ColorsRes.appBarBG,
                                      size: 35,
                                    )
                                  : Icon(
                                      Icons.business_outlined,
                                      color: ColorsRes.grayColor,
                                      size: 35,
                                    ),
                            ),
                            Text(
                              AppLocalizations.of(context)!.site,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: selectedIndex == 1
                                    ? ColorsRes.appBarBG
                                    : ColorsRes.grayColor,
                                fontSize: 18,
                              ),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            IconButton(
                              onPressed: () {
                                updateTabSelection(2, "Work");
                              },
                              iconSize: 27.0,
                              icon: selectedIndex == 2
                                  ? Icon(
                                      Icons.handyman_outlined,
                                      color: ColorsRes.appBarBG,
                                      size: 35,
                                    )
                                  : Icon(
                                      Icons.handyman_outlined,
                                      color: ColorsRes.grayColor,
                                      size: 35,
                                    ),
                            ),
                            Text(
                              AppLocalizations.of(context)!.work,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: selectedIndex == 2
                                    ? ColorsRes.appBarBG
                                    : ColorsRes.grayColor,
                                fontSize: 18,
                              ),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            IconButton(
                              onPressed: () {
                                updateTabSelection(3, "Parts");
                              },
                              iconSize: 27.0,
                              icon: selectedIndex == 3
                                  ? Icon(
                                      // Icons.pending_actions,
                                      Icons.build_outlined,
                                      color: ColorsRes.appBarBG,
                                      size: 35,
                                    )
                                  : Icon(
                                      Icons.build_outlined,
                                      color: ColorsRes.grayColor,
                                      size: 35,
                                    ),
                            ),
                            Text(
                              AppLocalizations.of(context)!.parts,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: selectedIndex == 3
                                    ? ColorsRes.appBarBG
                                    : ColorsRes.grayColor,
                                fontSize: 18,
                              ),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            IconButton(
                              onPressed: () {
                                updateTabSelection(4, "Time Line");
                              },
                              iconSize: 27.0,
                              icon: selectedIndex == 4
                                  ? Icon(
                                      // Icons.pending_actions,
                                      Icons.access_time_rounded,
                                      color: ColorsRes.appBarBG,
                                      size: 35,
                                    )
                                  : Icon(
                                      Icons.access_time_rounded,
                                      color: ColorsRes.grayColor,
                                      size: 35,
                                    ),
                            ),
                            Text(
                              AppLocalizations.of(context)!.timeline,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: selectedIndex == 4
                                    ? ColorsRes.appBarBG
                                    : ColorsRes.grayColor,
                                fontSize: 18,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
