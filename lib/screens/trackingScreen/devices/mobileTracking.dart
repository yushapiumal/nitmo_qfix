import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:qfix_nitmo_new/Constant/Slideanimation.dart';
import 'package:qfix_nitmo_new/api/apiService.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
import 'package:qfix_nitmo_new/l10n/app_localizations.dart';






class MobileTracking extends StatefulWidget {
  const MobileTracking({Key? key, required this.csrId}) : super(key: key);
  final csrId;
  @override
  State<MobileTracking> createState() => _MobileTrackingState();
}

class _MobileTrackingState extends State<MobileTracking>
    with TickerProviderStateMixin {
  APIService apiService = APIService();
  bool loading = false;
  List trackList = [];
  List dateList = [];
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    getTrackingDetails();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
  }

  @override
  void dispose() {
    _animationController!.dispose();

    super.dispose();
  }

  getTrackingDetails() async {
    setState(() {
      loading = true;
    });
    var getTracking = await apiService.getCsrTrack(widget.csrId);

    if (getTracking['taskCount'] > 0) {
      Map<String, dynamic> data =
          Map<String, dynamic>.from(getTracking['fixesList']);

      data.forEach((key, value) {
        setState(() {
          dateList.add(key);
          trackList.add(value);
        });
      });
      setState(() {
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  Widget dateLine(date) {
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * .1, top: 20),
      child: Text(
        date,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: ColorsRes.black,
        ),
      ),
    );
  }

  Widget lineBrake(sideLineOnly) {
    if (sideLineOnly) {
      return Stack(children: [
        Container(
            alignment: Alignment.topLeft,
            height: 25,
            padding: const EdgeInsets.only(left: 15),
            child: const DottedLine(
              dashLength: 3,
              lineLength: 30,
              lineThickness: 3,
              direction: Axis.vertical,
              dashColor: Colors.black,
            )),
      ]);
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorsRes.backgroundColor,
        body: SlideAnimation(
          position: 1,
          itemCount: 8,
          slideDirection: SlideDirection.fromLeft,
          animationController: _animationController,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                    color: ColorsRes.backgroundColor,
                    child: loading
                        ? Container(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.height / 3),
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                      Colors.blue),
                                ),
                              ),
                            ),
                          )
                        : showTaskList()),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 9,
                ),
              ],
            ),
          ),
        ));
  }

  showTaskList() {
    return dateList.isEmpty
        ? Container(
            child: Padding(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
              child: Center(
                child: Text(AppLocalizations.of(context)!.orderBtnName),
              ),
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            reverse: true,
            itemCount: dateList.length,
            physics: const ScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return trackListView(index);
            },
          );
  }

  trackListView(index) {
    return Column(
      children: [
        dateLine(dateList[index]),
        Container(
          margin: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * .1,
            right: 30,
          ),
          child: const Divider(
            color: Color(0xff26707070),
            thickness: 2,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: ColorsRes.white,
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(41, 0, 0, 0),
                offset: const Offset(2, 5),
                blurRadius: 10.0,
                spreadRadius: 0,
              )
            ],
          ),
          // decoration: BoxDecoration(
          //   color: ColorsRes.white,
          //   borderRadius: BorderRadius.circular(15),
          //   boxShadow: [
          //     BoxShadow(
          //       color: Color(0x14212121),
          //       blurRadius: 20.0,
          //     ),
          //   ],
          // ),
          margin: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * .06,
              right: MediaQuery.of(context).size.width * .06),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: trackList[index].length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int ind) {
              return Column(
                children: [
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const SizedBox(
                        width: 5,
                      ),
                      dateList[index] != 'Today'
                          ? Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 25,
                                  color: Colors.blue[100],
                                ),
                                Icon(
                                  Icons.circle,
                                  size: 15,
                                  color: Colors.blue[300],
                                ),
                              ],
                            )
                          : Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 25,
                                  color: ColorsRes.redColor.withOpacity(0.5),
                                ),
                                const Icon(Icons.circle,
                                    size: 15, color: ColorsRes.redColor),
                              ],
                            ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .05,
                      ),
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 4,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  trackList[index][ind]['action'],
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * .28,
                                ),
                                Text(
                                  trackList[index][ind]['technician_assignee'],
                                  style: const TextStyle(color: Color(0xff959595)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              timeSplit(trackList[index][ind]['createdOn']),
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.fade,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                    ],
                  ),
                  trackList[index].length - 1 != ind
                      ? Stack(
                          children: [
                            Container(
                                alignment: Alignment.topLeft,
                                height: 25,
                                padding: const EdgeInsets.only(left: 15),
                                child: const DottedLine(
                                  dashLength: 3,
                                  direction: Axis.vertical,
                                  dashColor: Colors.black,
                                )),
                            Container(
                              margin:
                                  const EdgeInsets.only(left: 40, top: 0, right: 20),
                              child: const Divider(
                                color: Color(0xff26707070),
                                thickness: 2,
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  timeSplit(time) {
    return time.split(' ')[1];
  }
}
