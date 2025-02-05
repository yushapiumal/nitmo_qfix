import 'dart:convert';
import 'dart:io';

import 'dart:ui';
import 'package:qfix_nitmo_new/screens/updateScreen/updateScreen.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:intl/intl.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:qfix_nitmo_new/screens/workScreen/devices/reviews_slider.dart';
import 'package:signature/signature.dart';

class MobileWork extends StatefulWidget {
  const MobileWork({Key? key, 
  required this.markUpdateTask,
  required this.taskData
  }) : super(key: key);
  final markUpdateTask;
  final taskData;
  @override
  State<MobileWork> createState() => _MobileWorkState();
}

class _MobileWorkState extends State<MobileWork> with TickerProviderStateMixin {
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
          color: ColorsRes.backgroundColor,
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height / 99),
              // helpingText(),
            //  buttonStart(),
              buttonDelay(),
              buttonReschedule(),
             // buttonComplete(),
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
              markUpdateTask:widget.markUpdateTask,
            ),
          );
        },
      );
    }
  }

  Widget helpingText() {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 20),
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
      margin: EdgeInsets.only(left: 20, right: 20, top: 20),
      width: 600,
      child: CupertinoButton(
          onPressed: btnDisable
              ? null
              : () async {
                Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateScreen( markUpdateTask:widget.markUpdateTask, taskData:widget.taskData,)));
              
                 
                },
          color: ColorsRes.secondaryButton,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.hourglass,
                color: Colors.black,
              ),
              SizedBox(width: 5),
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
      margin: EdgeInsets.only(left: 20, right: 20, top: 20),
      width: 600,
      child: CupertinoButton(
          onPressed: btnDisable
              ? null
              : () {
                  _showDialog(
                      AppLocalizations.of(context)!.markAsComplete, 'complete');
                },
          color: ColorsRes.secondaryButton,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.checkmark_seal,
                color: Colors.black,
              ),
              SizedBox(width: 5),
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
                  _showDialog(
                      AppLocalizations.of(context)!.reschedule, 'reschedule');
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

class ActivityModel extends StatefulWidget {
  const ActivityModel(
      {Key? key, required this.titleText, this.type, this.markUpdateTask})
      : super(key: key);
  final titleText;
  final type;
  final markUpdateTask;

  @override
  State<ActivityModel> createState() => _ActivityModelState();
}

class _ActivityModelState extends State<ActivityModel> {
  late double padding = 0.0;
  SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
    onDrawStart: () {},
    onDrawEnd: () {},
  );

  File? signaturefile;
  String? rescheduleTime;
  TextEditingController completeDescription = TextEditingController();
  TextEditingController customerName = TextEditingController();
  CalendarController _calendarController = CalendarController();
  bool _textValidate = false;
  bool _customerNameTextValidate = false;
  bool btnDisable = false;

  late int selectedValue1 = 0;
  void onChange1(int value) {
    setState(() {
      selectedValue1 = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final minDate = DateTime.now().add(Duration(days: 1));
    if (widget.type == 'complete') {
      setState(() {
        padding = 20.0; // Update the padding value if type is 'complete'
      });
    }
    return Padding(
      padding: EdgeInsets.all(padding),
      child: widget.type == 'complete'
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: TextField(
                        scrollPadding: EdgeInsets.only(
                            bottom:
                                MediaQuery.of(context).viewInsets.bottom * 4),
                        onChanged: (_) {
                          setState(() {
                            _customerNameTextValidate = false;
                          });
                        },
                        controller: customerName,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 15.0, top: 20),
                          hintStyle: TextStyle(
                            color: ColorsRes.purpalColor,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                          labelStyle: const TextStyle(
                              color: ColorsRes.greyColor,
                              fontSize: 16,
                              fontWeight: FontWeight.normal),
                          filled: false,
                          focusColor: ColorsRes.warmGreyColor,
                          focusedBorder: OutlineInputBorder(
                            gapPadding: 2.0,
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(
                              color: ColorsRes.warmGreyColor,
                            ),
                          ),
                          border: OutlineInputBorder(
                            gapPadding: 0.3,
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(
                              color: ColorsRes.warmGreyColor,
                              width: 1,
                            ),
                          ),
                          labelText:
                              AppLocalizations.of(context)!.customersName,
                          hintText:
                              AppLocalizations.of(context)!.customersNameError,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    _customerNameTextValidate
                        ? Text(
                            AppLocalizations.of(context)!.customersNameError,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          )
                        : SizedBox(),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: TextField(
                        scrollPadding: EdgeInsets.only(
                            bottom:
                                MediaQuery.of(context).viewInsets.bottom * 4),
                        maxLines: 6,
                        onChanged: (_) {
                          setState(() {
                            _textValidate = false;
                          });
                        },
                        controller: completeDescription,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 15.0, top: 20),
                          hintStyle: TextStyle(
                            color: ColorsRes.purpalColor,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                          labelStyle: const TextStyle(
                              color: ColorsRes.greyColor,
                              fontSize: 16,
                              fontWeight: FontWeight.normal),
                          filled: false,
                          focusColor: ColorsRes.warmGreyColor,
                          focusedBorder: OutlineInputBorder(
                            gapPadding: 2.0,
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: ColorsRes.warmGreyColor,
                            ),
                          ),
                          border: OutlineInputBorder(
                            gapPadding: 0.3,
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: ColorsRes.warmGreyColor,
                              width: 1,
                            ),
                          ),
                          labelText: AppLocalizations.of(context)!.description,
                          hintText:
                              AppLocalizations.of(context)!.descriptionError,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    _textValidate
                        ? Text(
                            AppLocalizations.of(context)!.descriptionError,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          )
                        : SizedBox(),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      AppLocalizations.of(context)!.customerSignature,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: ColorsRes.warmGreyColor,
                            width: 1,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Signature(
                            height: 200,
                            width: 400,
                            controller: _signatureController,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ReviewSlider(
                          onChange: onChange1,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.width / 70,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          child: Text(AppLocalizations.of(context)!.cancel),
                          onPressed: btnDisable
                              ? null
                              : () {
                                  setState(() {
                                    _signatureController.clear();
                                    completeDescription.clear();
                                    _textValidate = false;
                                  });

                                  Navigator.of(context).pop();
                                },
                        ),
                        TextButton(
                          child: Text(AppLocalizations.of(context)!.clear),
                          onPressed: btnDisable
                              ? null
                              : () {
                                  setState(() {
                                    _signatureController.clear();
                                  });
                                },
                        ),
                        TextButton(
                          child: Text(btnDisable
                              ? AppLocalizations.of(context)!.checking
                              : AppLocalizations.of(context)!.submit),
                          onPressed: btnDisable
                              ? null
                              : () async {
                                  if (!customerName.text.isEmpty ||
                                      !completeDescription.text.isEmpty) {
                                    setState(() {
                                      btnDisable = true;
                                    });
                                    final signatureSVG =
                                        await _signatureController.toRawSVG(
                                            width: 50, height: 50);

                                    var statusTxt = "No Solution";
                                    if (selectedValue1 == 1) {
                                      statusTxt = "Not Finished";
                                    }
                                    if (selectedValue1 == 2) {
                                      statusTxt = "Job Done";
                                    }
                                    
                                    var data = {
                                      'customerName': customerName.text,
                                      'completeNote': completeDescription.text,
                                      'signature': signatureSVG,
                                      'status': statusTxt
                                    };
                                  
                                       print("data=============================================>$data");
                                    var submit = await widget.markUpdateTask(
                                      'work',
                                      'complete',
                                      jsonEncode(data),
                                    );

                                    if (submit || !submit) {
                                      setState(() {
                                        btnDisable = false;
                                      });
                                      Navigator.of(context).pop();
                                    }
                                  }

                                  if (completeDescription.text.isEmpty) {
                                    setState(() {
                                      _textValidate = true;
                                    });
                                  }
                                  if (customerName.text.isEmpty) {
                                    setState(() {
                                      _customerNameTextValidate = true;
                                    });
                                  }
                                },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : AlertDialog(
              title: Text(widget.titleText),
              content: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: TimePickerSpinner(
                          is24HourMode: false,
                          normalTextStyle:
                              TextStyle(fontSize: 14, color: Color(0xffb3b8bd)),
                          highlightedTextStyle:
                              TextStyle(fontSize: 19, color: Colors.black),
                          spacing: 50,
                          itemHeight: 50,
                          isForce2Digits: true,
                          onTimeChange: (time) {
                            String formattedDate =
                               DateFormat('kk:mm').format(time);
                            setState(() {
                              rescheduleTime = formattedDate;
                            });
                          },
                        ),
                      ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Container(
                          width: 229,
                          height: 300,
                          child: SfCalendar(
                            controller: _calendarController,
                            minDate: minDate,
                            view: CalendarView.month,
                            showNavigationArrow: true,
                            todayHighlightColor: Colors.grey,
                            headerStyle: const CalendarHeaderStyle(
                                textAlign: TextAlign.center,
                                textStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold)),
                            monthViewSettings: const MonthViewSettings(
                              appointmentDisplayMode:
                                  MonthAppointmentDisplayMode.appointment,
                              agendaStyle:
                                  AgendaStyle(backgroundColor: Colors.grey),
                              monthCellStyle: MonthCellStyle(
                                todayBackgroundColor: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: Text(AppLocalizations.of(context)!.cancel),
                  onPressed: btnDisable
                      ? null
                      : () {
                          setState(() {
                            _signatureController.clear();
                            completeDescription.clear();
                            _textValidate = false;
                          });

                          Navigator.of(context).pop();
                        },
                ),
                widget.type == 'complete'
                    ? TextButton(
                        child: Text(AppLocalizations.of(context)!.clear),
                        onPressed: btnDisable
                            ? null
                            : () {
                                setState(() {
                                  _signatureController.clear();
                                });
                              },
                      )
                    : SizedBox(),
                TextButton(
                  onPressed: btnDisable
                      ? null
                      : () async {
                          if (widget.type == 'complete') {
                            if (completeDescription.text.isEmpty) {
                              setState(() {
                                _textValidate = true;
                              });
                            } else {
                              setState(() {
                                btnDisable = true;
                              });
                              final signatureSVG = await _signatureController
                                  .toRawSVG(width: 50, height: 50);
                              var data = {
                                'completeNote': completeDescription.text,
                                'signature': signatureSVG,
                              };

                              var submit = await widget.markUpdateTask(
                                'work',
                                'complete',
                                jsonEncode(data),
                              );

                              if (submit || !submit) {
                                setState(() {
                                  btnDisable = false;
                                });
                                Navigator.of(context).pop();
                              }
                            }
                          }
                          if (widget.type == 'reschedule') {
                            setState(() {
                              btnDisable = true;
                            });
                            var data = {
                              'rescheduleTime': rescheduleTime,
                              'rescheduleDate':
                                  _calendarController.selectedDate.toString()
                            };
                            var submit = await widget.markUpdateTask(
                              'work',
                              'reschedule',
                              data,
                            );

                            if (submit || !submit) {
                              setState(() {
                                btnDisable = false;
                              });
                              Navigator.of(context).pop();
                            }
                          }
                        },
                  child: Text(
                    btnDisable
                        ? AppLocalizations.of(context)!.checking
                        : AppLocalizations.of(context)!.submit,
                  ),
                ),
              ],
            ),
    );
  }
}
