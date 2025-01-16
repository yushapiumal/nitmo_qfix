import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:intl/intl.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
import 'package:qfix_nitmo_new/screens/workScreen/devices/mobileWork.dart';


class TabletWork extends StatefulWidget {
  const TabletWork({Key? key, required this.markUpdateTask}) : super(key: key);
  final markUpdateTask;

  @override
  State<TabletWork> createState() => _TabletWorkState();
}

class _TabletWorkState extends State<TabletWork> with TickerProviderStateMixin {
  AnimationController? _animationController;
  bool btnDisable = false;
  String startWorkBtn = "Start Work";
  String markAsDelayBtn = "Mark as Delay";
  String rescheduleBtn = "Reschedule";
  String markAsCompleteBtn = "Mark as Complete";

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
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
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: ColorsRes.backgroundColor,
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height / 18),
              // helpingText(),
              buttonStart(),
              buttonDelay(),
              buttonReschedule(),
              buttonComplete(),
              btnDisable
                  ? Container(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 90),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                new AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        ),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  // void _showDialog(titleText, type) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return ActivityModel(
  //           titleText: titleText,
  //           type: type,
  //           markUpdateTask: widget.markUpdateTask);
  //     },
  //   );
  // }

  Widget helpingText() {
    return Container(
      margin: EdgeInsets.only(
        left: MediaQuery.of(context).size.width / 30,
        right: MediaQuery.of(context).size.width / 30,
        top: MediaQuery.of(context).size.width / 30,
      ),
      width: 600,
      child: Text(
        "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, ",
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget buttonStart() {
    return Container(
      margin: EdgeInsets.only(
        left: MediaQuery.of(context).size.width / 30,
        right: MediaQuery.of(context).size.width / 30,
        top: MediaQuery.of(context).size.width / 30,
      ),
      width: 600,
      child: CupertinoButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.play,
                color: Colors.black,
                size: 35,
              ),
              SizedBox(width: 5),
              Text(
                startWorkBtn,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          onPressed: btnDisable
              ? null
              : () async {
                  setState(() {
                    btnDisable = true;
                  });
                  var submit =
                      await widget.markUpdateTask('work', 'start-work', false);
                  if (submit || !submit) {
                    setState(() {
                      btnDisable = false;
                    });
                  }
                },
          color: ColorsRes.secondaryButton),
    );
  }

  Widget buttonDelay() {
    return Container(
      margin: EdgeInsets.only(
        left: MediaQuery.of(context).size.width / 30,
        right: MediaQuery.of(context).size.width / 30,
        top: MediaQuery.of(context).size.width / 30,
      ),
      width: 600,
      child: CupertinoButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.hourglass,
                color: Colors.black,
                size: 35,
              ),
              SizedBox(width: 5),
              Text(
                markAsDelayBtn,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
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
          color: ColorsRes.secondaryButton),
    );
  }

  Widget buttonComplete() {
    return Container(
      margin: EdgeInsets.only(
        left: MediaQuery.of(context).size.width / 30,
        right: MediaQuery.of(context).size.width / 30,
        top: MediaQuery.of(context).size.width / 30,
      ),
      width: 600,
      child: CupertinoButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.checkmark_seal,
                color: Colors.black,
                size: 35,
              ),
              SizedBox(width: 5),
              Text(
                "Mark as Complete",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          onPressed: btnDisable
              ? null
              : () {
                  //_showDialog("Mark As Complete", 'complete');
                },
          color: ColorsRes.secondaryButton),
    );
  }

  Widget buttonReschedule() {
    return Container(
      margin: EdgeInsets.only(
        left: MediaQuery.of(context).size.width / 30,
        right: MediaQuery.of(context).size.width / 30,
        top: MediaQuery.of(context).size.width / 30,
      ),
      width: 600,
      child: CupertinoButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.calendar,
                color: Colors.black,
                size: 35,
              ),
              SizedBox(width: 5),
              Text(
                "Reschedule",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          onPressed: btnDisable
              ? null
              : () {
                 // _showDialog("Reschedule", 'reschedule');
                },
          color: ColorsRes.secondaryButton),
    );
  }
}

// class ActivityModel extends StatefulWidget {
//   const ActivityModel(
//       {Key? key, required this.titleText, this.type, this.markUpdateTask})
//       : super(key: key);
//   final titleText;
//   final type;
//   final markUpdateTask;

//   @override
//   State<ActivityModel> createState() => _ActivityModelState();
// }

// class _ActivityModelState extends State<ActivityModel> {
//   SignatureController _signatureController = SignatureController(
//     penStrokeWidth: 2,
//     penColor: Colors.black,
//     exportBackgroundColor: Colors.white,
//     onDrawStart: () {},
//     onDrawEnd: () {},
//   );

//   File? signaturefile;
//   String? rescheduleTime;
//   TextEditingController completeDescription = TextEditingController();
//   CalendarController _calendarController = CalendarController();
//   bool _textValidate = false;
//   bool btnDisable = false;
//   @override
//   Widget build(BuildContext context) {
//     final minDate = DateTime.now().add(Duration(days: 1));

//     return Padding(
//       padding: EdgeInsets.all(0),
//       child: AlertDialog(
//         title: Text(
//           widget.titleText,
//           style: TextStyle(
//             fontSize: 20,
//           ),
//         ),
//         content: widget.type == 'complete'
//             ? SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.only(top: 0),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: <Widget>[
//                       Padding(
//                         padding: EdgeInsets.only(top: 5),
//                         // child:  TextField(
//                         //   decoration: InputDecoration(
//                         //       border: OutlineInputBorder(),
//                         //       filled: true,
//                         //       hintText: "description..."),
//                         //   keyboardType: TextInputType.multiline,
//                         //   maxLines: 5,
//                         // ),
//                         child: TextField(
//                           scrollPadding: EdgeInsets.only(
//                               bottom:
//                                   MediaQuery.of(context).viewInsets.bottom * 4),
//                           maxLines: 4,
//                           onChanged: (_) {
//                             setState(() {
//                               _textValidate = false;
//                             });
//                           },
//                           controller: completeDescription,
//                           keyboardType: TextInputType.name,
//                           decoration: InputDecoration(
//                             contentPadding:
//                                 EdgeInsets.only(left: 15.0, top: 20),
//                             hintStyle: TextStyle(
//                               color: ColorsRes.purpalColor,
//                               fontSize: 16,
//                               fontWeight: FontWeight.normal,
//                             ),
//                             labelStyle: TextStyle(
//                                 color: ColorsRes.greyColor,
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.normal),
//                             filled: false,
//                             focusColor: ColorsRes.warmGreyColor,
//                             focusedBorder: OutlineInputBorder(
//                               gapPadding: 2.0,
//                               borderRadius: BorderRadius.circular(24),
//                               borderSide: BorderSide(
//                                 color: ColorsRes.warmGreyColor,
//                               ),
//                             ),
//                             border: OutlineInputBorder(
//                               gapPadding: 0.3,
//                               borderRadius: BorderRadius.circular(24),
//                               borderSide: BorderSide(
//                                 color: ColorsRes.warmGreyColor,
//                                 width: 1,
//                               ),
//                             ),
//                             labelText: 'Description',
//                             hintText: 'Please enter description',
//                           ),
//                         ),
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       _textValidate
//                           ? Text(
//                               "please enter complete description",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(color: Colors.red, fontSize: 12),
//                             )
//                           : SizedBox(),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       Text("customer signature", textAlign: TextAlign.center),
//                       Padding(
//                         padding: const EdgeInsets.only(top: 5),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             border: Border.all(
//                                 color: ColorsRes.warmGreyColor,
//                                 width: 1,
//                                 style: BorderStyle.solid),
//                             borderRadius: BorderRadius.all(
//                               Radius.circular(20),
//                             ),
//                           ),
//                           child: Signature(
//                             height: 100,
//                             width: 200,
//                             controller: _signatureController,
//                             backgroundColor: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//             : SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.only(top: 0),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.only(top: 5),
//                         child: TimePickerSpinner(
//                           is24HourMode: false,
//                           normalTextStyle:
//                               TextStyle(fontSize: 14, color: Color(0xffb3b8bd)),
//                           highlightedTextStyle:
//                               TextStyle(fontSize: 19, color: Colors.black),
//                           spacing: 50,
//                           itemHeight: 50,
//                           isForce2Digits: true,
//                           onTimeChange: (time) {
//                             String formattedDate =
//                                 DateFormat('kk:mm').format(time);
//                             setState(() {
//                               rescheduleTime = formattedDate;
//                             });
//                           },
//                         ),
//                       ),
//                       Divider(),
//                       Padding(
//                         padding: const EdgeInsets.only(top: 5),
//                         child: Container(
//                           width: 229,
//                           height: 300,
//                           child: SfCalendar(
//                             controller: _calendarController,
//                             minDate: minDate,
//                             view: CalendarView.month,
//                             showNavigationArrow: true,
//                             todayHighlightColor: Colors.grey,
//                             headerStyle: CalendarHeaderStyle(
//                                 textAlign: TextAlign.center,
//                                 textStyle: TextStyle(
//                                     color: Colors.black,
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.bold)),
//                             monthViewSettings: MonthViewSettings(
//                               appointmentDisplayMode:
//                                   MonthAppointmentDisplayMode.appointment,
//                               agendaStyle:
//                                   AgendaStyle(backgroundColor: Colors.grey),
//                               monthCellStyle: MonthCellStyle(
//                                 todayBackgroundColor: Colors.grey,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//         actions: [
//           TextButton(
//             child: Text("CANCEL"),
//             onPressed: btnDisable
//                 ? null
//                 : () {
//                     setState(() {
//                       _signatureController.clear();
//                       completeDescription.clear();
//                       _textValidate = false;
//                     });

//                     Navigator.of(context).pop();
//                   },
//           ),
//           widget.type == 'complete'
//               ? TextButton(
//                   child: Text("CLEAR"),
//                   onPressed: btnDisable
//                       ? null
//                       : () {
//                           setState(() {
//                             _signatureController.clear();
//                           });
//                         },
//                 )
//               : SizedBox(),
//           TextButton(
//             child: Text(btnDisable ? "WAIT..." : "SUBMIT"),
//             onPressed: btnDisable
//                 ? null
//                 : () async {
//                     if (widget.type == 'complete') {
//                       if (completeDescription.text.isEmpty) {
//                         setState(() {
//                           _textValidate = true;
//                         });
//                       } else {
//                         setState(() {
//                           btnDisable = true;
//                         });
//                         final signatureSVG = await _signatureController
//                             .toRawSVG(width: 50, height: 50);
//                         var data = {
//                           'completeNote': completeDescription.text,
//                           'signature': signatureSVG,
//                         };

//                         var submit = await widget.markUpdateTask(
//                           'work',
//                           'complete',
//                           jsonEncode(data),
//                         );

//                         if (submit || !submit) {
//                           setState(() {
//                             btnDisable = false;
//                           });
//                           Navigator.of(context).pop();
//                         }
//                       }
//                     }
//                     if (widget.type == 'reschedule') {
//                       setState(() {
//                         btnDisable = true;
//                       });
//                       var data = {
//                         'rescheduleTime': rescheduleTime,
//                         'rescheduleDate':
//                             _calendarController.selectedDate.toString()
//                       };
//                       var submit = await widget.markUpdateTask(
//                         'work',
//                         'reschedule',
//                         data,
//                       );

//                       if (submit || !submit) {
//                         setState(() {
//                           btnDisable = false;
//                         });
//                         Navigator.of(context).pop();
//                       }
//                     }
//                   },
//           ),
//         ],
//       ),
//     );
//   }
// }
