import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';
import 'package:qfix_nitmo_new/Constant/Slideanimation.dart';
import 'package:qfix_nitmo_new/api/apiService.dart';
import 'package:qfix_nitmo_new/api/geoShare.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
import 'package:qfix_nitmo_new/helper/DesignConfig.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class MobileDetails extends StatefulWidget {
  const MobileDetails(
      {Key? key, required this.taskData, required this.markUpdateTask});

  final taskData;
  final markUpdateTask;

  @override
  State<MobileDetails> createState() => _MobileDetailsState();
}

class _MobileDetailsState extends State<MobileDetails>
    with TickerProviderStateMixin {
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorsRes.appBG,
      child: Stack(
        children: [
          detailBox(),
          SizedBox(
            height: 3,
          ),
          bottomCard(),
        ],
      ),
    );
  }

  _makingPhoneCall(number) async {
    // const url = number;
    if (await canLaunch(number)) {
      await launch(number);
    } else {
      throw 'Could not launch $number';
    }
  }

  devider(text) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 3, left: 16),
          alignment: Alignment.bottomLeft,
          // margin: const EdgeInsets.only(bottom: 8, ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 2, bottom: 3, left: 16),
          alignment: Alignment.bottomLeft,
          child: Container(
            width: 70,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.black54,
              // color: Color(0xff5AD2F1).withOpacity(0.50),
              borderRadius: BorderRadius.all(
                Radius.circular(5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  showComplexity(type) {
    var text = "...";
    if (type == 'L1') {
      // Low
      text = 'Low Complexity';
    }
    if (type == 'L2') {
      // Medium
      text = 'Medium Complexity';
    }
    if (type == 'L3') {
      // High
      text = 'High Complexity';
    }
    return Text(
      '$text task',
      style: TextStyle(
        fontSize: 18,
        color: Colors.white,
        fontWeight: FontWeight.w400,
      ),
      textAlign: TextAlign.center,
    );
  }

  customColor(type) {
    if (type == 'L1') {
      return Colors.blue;
    }
    if (type == 'L2') {
      return ColorsRes.yellow.withOpacity(0.8);
    }
    if (type == 'L3') {
      return Colors.red.withOpacity(0.8);
    }
  }

  Widget complexityCard() {
    return SlideAnimation(
      position: 1,
      itemCount: 8,
      slideDirection: SlideDirection.fromLeft,
      animationController: _animationController,
      child: Container(
          padding: EdgeInsets.only(
            // top: 5,
            left: MediaQuery.of(context).size.width / 26,
            right: MediaQuery.of(context).size.width / 26,
            bottom: 3,
          ),
          child: Container(
            height: MediaQuery.of(context).size.height / 20,
            width: MediaQuery.of(context).size.width/4,
            decoration: BoxDecoration(
              color: customColor(widget.taskData.complexity),
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
            child: Container(
              padding: EdgeInsets.only(top: 10),
              child: showComplexity(widget.taskData.complexity),
            ),
          )),
    );
  }

  Widget technicianSolutionCard(textContent) {
    var text = "There are no solution found";

    return SlideAnimation(
      position: 1,
      itemCount: 8,
      slideDirection: SlideDirection.fromLeft,
      animationController: _animationController,
      child: Container(
        padding: EdgeInsets.only(
          top: 20,
          left: MediaQuery.of(context).size.width / 26,
          right: MediaQuery.of(context).size.width / 26,
          bottom: 15,
        ),
        child: Stack(
          children: [
            Container(
              constraints: BoxConstraints(
                  minHeight: 0,
                  maxHeight: MediaQuery.of(context).size.height / 5),
              width: MediaQuery.of(context).size.width,
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
              child: textContent.length > 0
                  ? ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: textContent.length,
                      itemBuilder: (context, index) {
                        final item = textContent[index];
                        return ListTile(
                          title: Text(item['solution']),
                          subtitle: Text(item['technician']),
                          trailing: Text(item['date']),
                        );
                      },
                    )
                  : Container(
                      // height: MediaQuery.of(context).size.height,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 2),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              //for horizontal scrolling
                              scrollDirection: Axis.vertical,
                              child: Text(
                                // textContent,
                                text,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: ColorsRes.purpalColor,
                                  // fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget detailCard(textContent) {
    var text = "There are no solution has mentioned";

    if (!textContent.isEmpty) {
      text = textContent;
    }
    return SlideAnimation(
      position: 1,
      itemCount: 8,
      slideDirection: SlideDirection.fromLeft,
      animationController: _animationController,
      child: Container(
        padding: EdgeInsets.only(
          top: 20,
          left: MediaQuery.of(context).size.width / 26,
          right: MediaQuery.of(context).size.width / 26,
          bottom: 15,
        ),
        child: Stack(
          children: [
            Container(
              constraints: BoxConstraints(
                  minHeight: 0,
                  maxHeight: MediaQuery.of(context).size.height / 5),
              width: MediaQuery.of(context).size.width,
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
              child: Container(
                // height: MediaQuery.of(context).size.height,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        //for horizontal scrolling
                        scrollDirection: Axis.vertical,
                        child: Text(
                          // textContent,
                          text,
                          style: TextStyle(
                            fontSize: 18,
                            color: ColorsRes.purpalColor,
                            // fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  sectionTitle(titleText) {
    return SlideAnimation(
      position: 5,
      itemCount: 8,
      slideDirection: SlideDirection.fromBottom,
      animationController: _animationController,
      child: Container(
        padding: EdgeInsets.only(
          top: 10,
        ),
        child: Text(
          titleText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget detailBox() {
    return Container(
      color: ColorsRes.appBG,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            sectionTitle(AppLocalizations.of(context)!.issueTask),
            detailCard(widget.taskData.description),
            sectionTitle(AppLocalizations.of(context)!.solution),
            tabSection(),
          //  complexityCard(),
           // technicianSolutionBtn(),
            SizedBox(
              height: MediaQuery.of(context).size.height / 6,
            ),
          ],
        ),
      ),
    );
  }

  Widget tabSection() {
    return SlideAnimation(
      position: 1,
      itemCount: 8,
      slideDirection: SlideDirection.fromLeft,
      animationController: _animationController,
      child: DefaultTabController(
        length: 2,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Adjust the mainAxisSize property

          children: [
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
              width: 600,
              child: TabBar(
                indicator:
                    DesignConfig.buttonShadowColor(ColorsRes.tabsColor, 20.0),
                labelStyle:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                indicatorColor: Colors.transparent,
                tabs: [
                  Container(
                    padding: const EdgeInsets.only(
                        bottom: 6.0, top: 6.0, left: 8.0, right: 8.0),
                    child: Text(
                      AppLocalizations.of(context)!.csr,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                        bottom: 6.0, top: 6.0, left: 8.0, right: 8.0),
                    child: Text(
                      AppLocalizations.of(context)!.technicians,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Container(
                height: MediaQuery.of(context).size.height / 4,
                child: TabBarView(
                  children: [
                    detailCard(widget.taskData.solution),
                    technicianSolutionCard(widget.taskData.technicianSolution),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget technicianSolutionBtn() {
  //   var fontSize = MediaQuery.of(context).size.width / 25;

  //   if (storage.getItem('lang') == 'si') {
  //     fontSize = MediaQuery.of(context).size.width / 30;
  //   }

  //   return SlideAnimation(
  //     position: 1,
  //     itemCount: 8,
  //     slideDirection: SlideDirection.fromLeft,
  //     animationController: _animationController,
  //     child: Container(
  //       margin: EdgeInsets.only(left: 20, right: 20, top: 20),
  //       width: 600,
  //       child: CupertinoButton(
  //           onPressed: () {
  //             showModalBottomSheet(
  //               isScrollControlled: true,
  //               shape: const RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.only(
  //                   topLeft: Radius.circular(20.0),
  //                   topRight: Radius.circular(20.0),
  //                 ),
  //               ),
  //               context: context,
  //               builder: (BuildContext context) {
  //                 return BottomSheet(markUpdateTask: widget.markUpdateTask);
  //               },
  //             );
  //           },
  //           color: ColorsRes.secondaryButton,
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Column(
  //                 children: [
  //                   Row(
  //                     children: [
  //                       const Icon(
  //                         Icons.note_alt_outlined,
  //                         color: Colors.black,
  //                         size: 24.0,
  //                       ),
  //                       SizedBox(width: 15),
  //                       Text(
  //                         AppLocalizations.of(context)!.technicians +
  //                             " " +
  //                             AppLocalizations.of(context)!.solution,
  //                         style: TextStyle(
  //                           color: Colors.black,
  //                           fontWeight: FontWeight.bold,
  //                           fontSize: fontSize,
  //                         ),
  //                       ),
  //                     ],
  //                   )
  //                 ],
  //               ),
  //             ],
  //           )),
  //     ),
  //   );
  // }

  Widget bottomCard() {
    return SlideAnimation(
      position: 5,
      itemCount: 8,
      slideDirection: SlideDirection.fromBottom,
      animationController: _animationController,
      child: DraggableScrollableSheet(
        initialChildSize:0.3,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (BuildContext context, ScrollController scrollController) {
          return ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            controller: scrollController,
            itemCount: 1,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 95,
                  bottom: MediaQuery.of(context).size.height / 40,
                ),
                decoration:
                    DesignConfig.halfCurve(Colors.grey[100]!, 30.0, 30.0),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: 70,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[500],
                          borderRadius: const BorderRadius.all(
                            Radius.circular(5),
                          ),
                        ),
                      ),
                    ),Row(  
                      children: [
                      Expanded(child:  
                       devider(AppLocalizations.of(context)!.customer),),
                     complexityCard()

                        ]
                        ),
                  
                    customerSection(),
                    const SizedBox(
                      height: 10,
                    ),
                    devider(AppLocalizations.of(context)!.assignedTo),
                    const SizedBox(
                      height: 10,
                    ),
                    assingedToSection(),
                    SizedBox(
                      height: 10,
                    ),
                    devider(AppLocalizations.of(context)!.owner),
                    ownerSection(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 10,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget customerSection() {
    return Column(
      children: [
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width / 15,
              right: MediaQuery.of(context).size.width / 15),
          title: Row(
            children: [
              Icon(CupertinoIcons.person_alt_circle),
              SizedBox(width: 18.0),
              Flexible(
                child: Text(
                  widget.taskData.customer['contact'],
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: ColorsRes.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width / 15,
              right: MediaQuery.of(context).size.width / 15),
          title: Row(
            children: [
              Icon(CupertinoIcons.location_circle),
              SizedBox(width: 18.0),
              Flexible(
                child: Text(
                  widget.taskData.customer['address'],
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: ColorsRes.textColor,
                    fontSize: 19,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width / 15,
              right: MediaQuery.of(context).size.width / 15),
          title: Row(
            children: [
              Icon(CupertinoIcons.phone_circle),
              SizedBox(width: 18.0),
              Text(
                widget.taskData.customer['mobile_number'],
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: ColorsRes.textColor,
                  fontSize: 19,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          onTap: () {
            widget.taskData.customer['mobile_number'] != ""
                ? _makingPhoneCall(
                    "tel:" +
                        widget.taskData.customer['mobile_number'].toString(),
                  )
                : APIService().showToast('No contact number');
          },
        ),
     
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width / 15,
              right: MediaQuery.of(context).size.width / 15),
          title: Row(
            children: [
              Icon(CupertinoIcons.phone_circle),
              SizedBox(width: 18.0),
              Text(
                widget.taskData.customer['land_line'],
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: ColorsRes.textColor,
                  fontSize: 19,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          onTap: () {
            widget.taskData.customer['land_line'] != ""
                ? _makingPhoneCall(
                    "tel:" + widget.taskData.customer['land_line'].toString(),
                  )
                : APIService().showToast('No contact number');
          },
        ),
       
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width / 15,
              right: MediaQuery.of(context).size.width / 15),
          title: Row(
            children: [
              Icon(CupertinoIcons.calendar_circle),
              SizedBox(width: 18.0),
              Text(
                widget.taskData.created_on.toString(),
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: ColorsRes.textColor,
                  fontSize: 19,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
          Divider(
          color: ColorsRes.greyColor,
          indent: MediaQuery.of(context).size.width / 18,
          endIndent: MediaQuery.of(context).size.width / 18,
        ),
      ],
    );
  }

  Widget assingedToSection() {
    return Column(
      children: [
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width / 15,
              right: MediaQuery.of(context).size.width / 15),
          title: Row(
            children: [
              Icon(CupertinoIcons.person_alt_circle),
              SizedBox(width: 18.0),
              Flexible(
                child: Text(
                  widget.taskData.assigned_to['name'],
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: ColorsRes.textColor,
                    fontSize: 19,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width / 15,
              right: MediaQuery.of(context).size.width / 15),
          title: Row(
            children: [
              Icon(CupertinoIcons.doc_circle),
              SizedBox(width: 18.0),
              Flexible(
                child: Text(
                  widget.taskData.assigned_to['designation'],
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: ColorsRes.textColor,
                    fontSize: 19,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
     
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width / 15,
              right: MediaQuery.of(context).size.width / 15),
          title: Row(
            children: [
              Icon(CupertinoIcons.phone_circle),
              SizedBox(width: 18.0),
              Text(
                widget.taskData.assigned_to['contact'],
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: ColorsRes.textColor,
                  fontSize: 19,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          onTap: () {
            widget.taskData.assigned_to['contact'] != ""
                ? _makingPhoneCall(
                    "tel:" + widget.taskData.assigned_to['contact'].toString(),
                  )
                : APIService().showToast('No contact number');
          },
        ),   Divider(
          color: ColorsRes.greyColor,
          indent: MediaQuery.of(context).size.width / 18,
          endIndent: MediaQuery.of(context).size.width / 18,
        ),
      ],
    );
  }

  Widget ownerSection() {
    return Column(
      children: [
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width / 15,
              right: MediaQuery.of(context).size.width / 15),
          title: Row(
            children: [
              Icon(CupertinoIcons.person_alt_circle),
              SizedBox(width: 18.0),
              Flexible(
                child: Text(
                  widget.taskData.owner['name'],
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: ColorsRes.textColor,
                    fontSize: 19,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
     
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width / 15,
              right: MediaQuery.of(context).size.width / 15),
          title: Row(
            children: [
              Icon(CupertinoIcons.doc_circle),
              SizedBox(width: 18.0),
              Flexible(
                child: Text(
                  widget.taskData.owner['designation'],
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: ColorsRes.textColor,
                    fontSize: 19,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
     
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width / 15,
              right: MediaQuery.of(context).size.width / 15),
          title: Row(
            children: [
              Icon(CupertinoIcons.phone_circle),
              SizedBox(width: 18.0),
              Text(
                widget.taskData.owner['contact'],
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: ColorsRes.textColor,
                  fontSize: 19,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          onTap: () {
            widget.taskData.owner['contact'] != ""
                ? _makingPhoneCall(
                    "tel:" + widget.taskData.owner['contact'].toString(),
                  )
                : APIService().showToast('No contact number');
          },
        ),
      ],
    );
  }
}

// class BottomSheet extends StatefulWidget {
//   const BottomSheet({Key? key, required this.markUpdateTask}) : super(key: key);
//   final markUpdateTask;

//   @override
//   State<BottomSheet> createState() => _BottomSheetState();
// }

// class _BottomSheetState extends State<BottomSheet> {
//   bool btnDisable = false;
//   TextEditingController technicianSolution = TextEditingController();
//   bool _textValidate = false;
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(
//           top: MediaQuery.of(context).size.width / 15,
//           left: MediaQuery.of(context).size.width / 15,
//           right: MediaQuery.of(context).size.width / 15,
//           bottom: MediaQuery.of(context).viewInsets.bottom),
//       child: Container(
//         height: MediaQuery.of(context).size.height / 3.5,
//         child: Column(
//           children: [
//             Padding(
//               padding: EdgeInsets.only(top: 5),
//               child: TextField(
//                 scrollPadding: EdgeInsets.only(
//                     bottom: MediaQuery.of(context).viewInsets.bottom * 4),
//                 maxLines: 6,
//                 onChanged: (_) {
//                   setState(() {
//                     _textValidate = false;
//                   });
//                 },
//                 controller: technicianSolution,
//                 keyboardType: TextInputType.name,
//                 decoration: InputDecoration(
//                   contentPadding: EdgeInsets.only(left: 15.0, top: 20),
//                   hintStyle: TextStyle(
//                     color: ColorsRes.purpalColor,
//                     fontSize: 16,
//                     fontWeight: FontWeight.normal,
//                   ),
//                   labelStyle: const TextStyle(
//                       color: ColorsRes.greyColor,
//                       fontSize: 16,
//                       fontWeight: FontWeight.normal),
//                   filled: false,
//                   focusColor: ColorsRes.warmGreyColor,
//                   focusedBorder: OutlineInputBorder(
//                     gapPadding: 2.0,
//                     borderRadius: BorderRadius.circular(24),
//                     borderSide: const BorderSide(
//                       color: ColorsRes.warmGreyColor,
//                     ),
//                   ),
//                   border: OutlineInputBorder(
//                     gapPadding: 0.3,
//                     borderRadius: BorderRadius.circular(24),
//                     borderSide: const BorderSide(
//                       color: ColorsRes.warmGreyColor,
//                       width: 1,
//                     ),
//                   ),
//                   labelText: AppLocalizations.of(context)!.solution,
//                   hintText: AppLocalizations.of(context)!.solutionError,
//                 ),
//               ),
//             ),
//             _textValidate
//                 ? Text(
//                     AppLocalizations.of(context)!.solutionError,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(color: Colors.red, fontSize: 12),
//                   )
//                 : SizedBox(),
//             SizedBox(
//               height: MediaQuery.of(context).size.width / 70,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 TextButton(
//                   onPressed: btnDisable
//                       ? null
//                       : () {
//                           setState(() {
//                             technicianSolution.clear();
//                           });
//                           Navigator.of(context).pop();
//                         },
//                   child: Text(AppLocalizations.of(context)!.cancel),
//                 ),
//                 TextButton(
//                   onPressed: btnDisable
//                       ? null
//                       : () async {
//                           if (technicianSolution.text.isEmpty) {
//                             setState(() {
//                               _textValidate = true;
//                             });
//                           } else {
//                             setState(() {
//                               btnDisable = true;
//                             });

//                             var submit = await widget.markUpdateTask(
//                               'site',
//                               'solution',
//                               technicianSolution.text,
//                             );

//                             if (submit || !submit) {
//                               setState(() {
//                                 btnDisable = false;
//                               });
//                               Navigator.of(context).pop();
//                             }
//                           }
//                         },
//                   child: Text(
//                     btnDisable
//                         ? AppLocalizations.of(context)!.checking
//                         : AppLocalizations.of(context)!.submit,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
