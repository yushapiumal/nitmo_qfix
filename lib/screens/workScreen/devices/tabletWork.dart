import 'dart:convert';
import 'dart:io';

import 'dart:ui';
import 'package:qfix_nitmo_new/l10n/app_localizations.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:intl/intl.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
import 'package:qfix_nitmo_new/screens/workScreen/devices/reviews_slider.dart';
import 'package:signature/signature.dart';



class TabletWork extends StatefulWidget {
  const TabletWork({Key? key, required this.taskData, required this.markUpdateTask}) : super(key: key);
  final markUpdateTask;
  final taskData;

  @override
  State<TabletWork> createState() => _TabletWorkState();
}

class _TabletWorkState extends State<TabletWork> with TickerProviderStateMixin {
  AnimationController? _animationController;
  bool btnDisable = false;
  // String startWorkBtn =  "Start Work";//
  // String markAsDelayBtn = "Mark as Delay";
  // String rescheduleBtn = "Reschedule";
  // String markAsCompleteBtn = "Mark as Complete";

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: ColorsRes.backgroundColor,
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height / 99),
              // helpingText(),
              //buttonStart(),
              buttonDelay(),
              buttonReschedule(),
            //  buttonComplete(),
              btnDisable
                  ? Container(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 90),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  // void _showDialog(titleText, type) {
  //   if (type == 'reschedule') {
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return ActivityModel(
  //             titleText: titleText,
  //             type: type,
  //             markUpdateTask: widget.markUpdateTask);
  //       },
  //     );
  //   }
  //   if (type == 'complete') {
  //     showModalBottomSheet(
  //       isScrollControlled: true,
  //       shape: const RoundedRectangleBorder(
  //         borderRadius: BorderRadius.only(
  //           topLeft: Radius.circular(20.0),
  //           topRight: Radius.circular(20.0),
  //         ),
  //       ),
  //       context: context,
  //       builder: (BuildContext context) {
          // return Container(
          //   // Content of the bottom sheet
          //   height: MediaQuery.of(context).size.height /
          //       1.3, // Set the desired height
          //   child: ActivityModel(
          //     titleText: titleText,
          //     type: type,
          //     markUpdateTask: widget.markUpdateTask,
          //   ),
          // );
      //  },
  //    );
  //  }
 // }

  Widget helpingText() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      width: 600,
      child: const Text(
        "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, ",
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget buttonStart() {
  return Container(
    margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
    width: 600,
    child: CupertinoButton(
      onPressed: btnDisable
          ? null
          : () async {
              print("result++++++++++++++++++++>${widget.markUpdateTask}");
              setState(() {
                btnDisable = true;
              });
          
              var submit = await widget.markUpdateTask('work', 'start-work',false);

           
              if (submit != null) {
                setState(() {
                  btnDisable = false; 
                });
              } else {
             
                setState(() {
                  btnDisable = false; 
                });
              }
            },
      color: ColorsRes.secondaryButton,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.play,
            color: Colors.black,
          ),
          const SizedBox(width: 5),
          Text(
            AppLocalizations.of(context)!.startWork,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
} 
  Widget buttonDelay() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      width: 600,
      child: CupertinoButton(
          onPressed: btnDisable
              ? null
              : () async {
                  setState(() {
                    btnDisable = true;
                  });
                  var submit = await widget.markUpdateTask(
                      'work', 'mark-as-delay', false);
                  if (submit || !submit) {
                    setState(() {
                      btnDisable = false;
                    });
                  }
                },
          color: ColorsRes.secondaryButton,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.hourglass,
                color: Colors.black,
              ),
              const SizedBox(width: 5),
              Text(
                AppLocalizations.of(context)!.markAsDelay,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )),
    );
  }

  Widget buttonComplete() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      width: 600,
      child: CupertinoButton(
          onPressed: btnDisable
              ? null
              : () {
                  // _showDialog(
                  //     AppLocalizations.of(context)!.markAsComplete, 'complete');
                },
          color: ColorsRes.secondaryButton,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.checkmark_seal,
                color: Colors.black,
              ),
              const SizedBox(width: 5),
              Text(
                AppLocalizations.of(context)!.markAsComplete,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )),
    );
  }

  Widget buttonReschedule() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      width: 600,
      child: CupertinoButton(
          onPressed: btnDisable
              ? null
              : () {
                  // _showDialog(
                  //     AppLocalizations.of(context)!.reschedule, 'reschedule');
                },
          color: ColorsRes.secondaryButton,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.calendar,
                color: Colors.black,
              ),
              const SizedBox(width: 5),
              Text(
                AppLocalizations.of(context)!.reschedule,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],     
          )),
    );
  }
}

