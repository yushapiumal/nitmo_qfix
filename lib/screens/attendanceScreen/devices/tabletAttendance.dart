import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:qfix_nitmo_new/Constant/Slideanimation.dart';
import 'package:qfix_nitmo_new/api/apiService.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
import 'package:expandable/expandable.dart';
import 'package:qfix_nitmo_new/l10n/app_localizations.dart';


class TabletAttendance extends StatefulWidget {
  const TabletAttendance({Key? key}) : super(key: key);

  @override
  State<TabletAttendance> createState() => _TabletAttendanceState();
}

class _TabletAttendanceState extends State<TabletAttendance>
    with SingleTickerProviderStateMixin {
 AnimationController? _animationController;
  APIService apiService = APIService();
  List attendanceList = [];
  int attendanceCount = 0;

  @override
  void initState() {
    super.initState();
    getAttendance();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  getAttendance() async {
    var attendance = await apiService.getAttendance();
    setState(() {
      attendanceCount = attendance.length;
    });
    for (var attend in attendance) {
      attendanceList.add(attend);
    }
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
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          shadowColor: Colors.transparent,
          title: Text(
        AppLocalizations.of(context)!.attendance,
            style: const TextStyle(
              letterSpacing: 4,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Container(
          margin: EdgeInsets.only(top: 20),
          child: showBody(),
        ),
      ),
    );
  }

  Widget showBody() {
    return SlideAnimation(
      position: 4,
      itemCount: 8,
      slideDirection: SlideDirection.fromLeft,
      animationController: _animationController,
      child: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: attendanceCount,
          physics: ScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: [
                Container(
                  margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * .1,
                      right: MediaQuery.of(context).size.width * .1),
                  decoration: BoxDecoration(
                    color: ColorsRes.white,
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(41, 0, 0, 0),
                        offset: new Offset(2, 5),
                        blurRadius: 10.0,
                        spreadRadius: 0,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      attendCard(index),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            );
          }),
    );
  }

  daySplit(date, onlyDate) {
    var day = date.split('/');
    if (onlyDate) {
      String date = day[1];
      return date;
    }
    return DateFormat('MMM').format(DateTime(0, int.parse(day[0])));
    // if (onlyDate) {
    //   String x = day[1];
    //   List<String> c = x.split("");
    //   c.removeLast();
    //   return c.join();
    // }
    // return day[0];
  }

  Widget attendCard(index) {
    return ExpandableNotifier(
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 20),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.30),
                            blurRadius: 8,
                            spreadRadius: 6,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  daySplit(attendanceList[index]['date'], true),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 25,
                                      color: Colors.red),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                    daySplit(attendanceList[index]['date'],
                                            false)
                                        .toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 17,
                                        color: Colors.black))
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width / 20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 3,
                                child: Text(
                                  attendanceList[index]['sname'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xff676767),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 6,
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: 'SID ${attendanceList[index]['sid']}',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.amber,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 45,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width /8,
                                  child:  Text(
                                  AppLocalizations.of(context)!.intext,
                                    style: const TextStyle(
                                        fontSize:10,
                                        color: ColorsRes.grayColor,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width /8,
                                  child: Text(
                                    attendanceList[index]['in'] == false
                                        ? '-'
                                        : attendanceList[index]['in'],
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: ColorsRes.black,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width /8,
                                  child: Text(
                                  AppLocalizations.of(context)!.out,
                                    style: const TextStyle(
                                        fontSize:10,
                                        color: ColorsRes.grayColor,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Container(
                               width:
                                      MediaQuery.of(context).size.width /8,
                                  child: Text(
                                    attendanceList[index]['out'] == false
                                        ? '-'
                                        : attendanceList[index]['out'],
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: ColorsRes.black,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * .05,
                  right: MediaQuery.of(context).size.width * .05,
                  top: 5),
              child: Divider(
                color: Color(0xff26707070),
                thickness: 2,
              ),
            ),
            ScrollOnExpand(
              scrollOnExpand: true,
              scrollOnCollapse: false,
              child: ExpandablePanel(
                theme: const ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                  tapBodyToCollapse: true,
                ),
                header:  Padding(
                  padding: EdgeInsets.only(left: 10, top: 0),
                  child: Text(
                      AppLocalizations.of(context)!.viewProjects
                  ),
                ),
                collapsed: SizedBox(),
                expanded: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 10, left: 10),
                      child: attendanceList[index]['project'] == false ||
                              attendanceList[index]['task'] == false
                          ? Text(   AppLocalizations.of(context)!.noProjectsOrTasksFound)
                          : Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6)),
                              ),
                              child: Table(
                                border: const TableBorder.symmetric(
                                    inside: BorderSide(
                                        width: 1, color: Colors.black)),
                                defaultVerticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                children: [
                                  TableRow(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[350],
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(6),
                                            topRight: Radius.circular(6)),
                                      ),
                                      children:  [
                                        Text(
                                          AppLocalizations.of(context)!.projects,
                                          textScaleFactor: 1,
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          AppLocalizations.of(context)!.tasks,
                                          textScaleFactor: 1,
                                          textAlign: TextAlign.center,
                                        ),
                                      ]),
                                   TableRow(children: [
                                    Text(
                                     AppLocalizations.of(context)!.workedHoursFormatted,
                                      // data.boilerPlate['wrkd_hours_fmtd'] == null
                                      //     ? " - "
                                      //     : data.boilerPlate['wrkd_hours_fmtd']
                                      //         .toString(),
                                      textScaleFactor: 1,
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'late',
                                      // data.boilerPlate['late'] == null
                                      //     ? " - "
                                      //     : data.boilerPlate['late'].toString(),
                                      textScaleFactor: 1,
                                      textAlign: TextAlign.center,
                                    ),
                                  ]),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
                builder: (_, collapsed, expanded) {
                  return Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    child: Expandable(
                      collapsed: collapsed,
                      expanded: expanded,
                      theme: const ExpandableThemeData(crossFadePoint: 0),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
