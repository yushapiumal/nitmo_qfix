import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:localstorage/localstorage.dart';
import 'package:qfix_nitmo_new/api/apiService.dart';
import 'package:qfix_nitmo_new/api/geoShare.dart';


class CheckinCheckoutBottom extends StatefulWidget {
  const CheckinCheckoutBottom(
      { required this.from, this.tempPickedDate});
  final from;
  final tempPickedDate;
  @override
  State<CheckinCheckoutBottom> createState() => _CheckinCheckoutBottomState();
}

class _CheckinCheckoutBottomState extends State<CheckinCheckoutBottom> {
  APIService apiService = APIService();
  final LocalStorage storage = LocalStorage('qfix');

  List getContracts = [];
  List getContractTask = [];
  bool contractTaskLoading = false;
  bool contractLoading = false;
  List selectedContracts = [];
  List trackingRefArray = [];
  List selectedTask = [];
  bool buttonSubmit = false;
  @override
  void initState() {
    super.initState();
    getProjectList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getProjectList() async {
    setState(() {
      contractLoading = true;
    });
    var fromType = 'false';
    if (widget.from != 'checkin') {
      fromType = storage.getItem('sId');
    }
    var response = await apiService.getProjects(fromType);
    for (var element in response) {
      setState(() {
        getContracts.add(element);
      });
    }
    setState(() {
      contractLoading = false;
    });
  }

  getProjectTask(contractSerial) async {
    if (selectedContracts.contains(contractSerial)) {
      selectedContracts.removeWhere((item) => item == contractSerial);
      setState(() {
        contractTaskLoading = false;
      });
      getContractTask
          .removeWhere((item) => item['projectSerial'] == contractSerial);
    } else {
      setState(() {
        selectedContracts.add(contractSerial);
      });
      var response = await apiService.getProjectTask(contractSerial);

      for (var element in response) {
        setState(() {
          getContractTask.add(element);
        });
      }
      setState(() {
        contractTaskLoading = false;
      });
    }
  }

  markAsDone(csrId, trackingRef) {
    if (selectedTask.contains(csrId)) {
      setState(() {
        selectedTask.removeWhere((number) => number == csrId);
        for (var i = 0; i < trackingRef.length; i++) {
          trackingRefArray.removeWhere((number) => number == trackingRef[i]);
        }
      });
    } else {
      print('markAsDone else');
      setState(() {
        selectedTask.add(csrId);
        for (var i = 0; i < trackingRef.length; i++) {
          trackingRefArray.add(trackingRef[i]);
        }
      });
    }
  }

  checkinCheckout(from) async {
    try {
      var time = widget.tempPickedDate.toString();
      var timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      if (selectedContracts.isNotEmpty && selectedTask.isNotEmpty) {
        Map locData = {
          'status': false,
          'uid': storage.getItem('userId'),
          'sid': storage.getItem('sId'),
          'checkin': from,
          'time': time,
          'date': DateFormat("dd/MM/yyyy").format(DateTime.now()).toString(),
          'timestamp': timestamp,
          'project': selectedContracts,
          'navigation': [],
          'tasks': selectedTask,
          'member': storage.getItem('name'),
        };

        getCurrentLocation(
            from == 'checkin' ? true : false, locData, trackingRefArray);
        var data = {
          'uid': storage.getItem('userId'),
          'sid': storage.getItem('sId'),
          'status': from,
          'time': time,
          'timestamp': timestamp,
          'projects': jsonEncode(selectedContracts),
          'tasks': jsonEncode(selectedTask),
          'tracking_ref': getLastTrackingRef().toString()
        };
        await apiService.checkInCheckOut(data);
        Navigator.pop(context);
        setState(() {
          buttonSubmit = false;
        });
      } else {
        apiService.showToast('please select the project and task');
        setState(() {
          buttonSubmit = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.70,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50.0),
          ),
        ),
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 0, top: 10, start: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                    ),
                  ),
                  const Text(
                    'Select Project(s)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 8,
                  )
                  // IconButton(
                  //   onPressed: () {},
                  //   icon: Icon(
                  //     Icons.star,
                  //     color: Colors.black,
                  //   ),
                  // ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                  left: 15, bottom: 8, top: 20, right: 15),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "PROJECTS",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 3, bottom: 3, left: 16),
              alignment: Alignment.bottomLeft,
              child: Container(
                width: 70,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.purple[200],
                  // color: Color(0xff5AD2F1).withOpacity(0.50),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.width / 3.1,
              child: Container(
                alignment: Alignment.topLeft,
                padding:
                    const EdgeInsetsDirectional.only(start: 17, end: 20, top: 20),
                child: contractLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        itemCount: getContracts.length,
                        physics: const ScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                contractTaskLoading = true;
                              });
                              getProjectTask(
                                  getContracts[index]['contact_serial']);
                            }, // Handle your callback
                            child: SizedBox(
                              height: 20,
                              child: Card(
                                color: Colors.purple[50],
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                elevation: 5.0,
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            getContracts[index]
                                                ['contact_serial'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          selectedContracts.contains(
                                                  getContracts[index]
                                                      ['contact_serial'])
                                              ? const Icon(
                                                  Icons.check_box,
                                                  color: Colors.green,
                                                )
                                              : const Icon(
                                                  Icons.check_box_outline_blank,
                                                  color: Colors.grey,
                                                ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          child: SingleChildScrollView(
                                            child: Text(
                                              getContracts[index]['product'],
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
            getContractTask.isNotEmpty
                ? Container(
                    margin: const EdgeInsets.only(
                        left: 15, bottom: 8, top: 20, right: 15),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "TASK",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
            getContractTask.isNotEmpty
                ? Container(
                    margin: const EdgeInsets.only(top: 3, bottom: 3, left: 16),
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      width: 70,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.pink[200],
                        // color: Color(0xff5AD2F1).withOpacity(0.50),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
            SizedBox(
              height: MediaQuery.of(context).size.width / 2.8,
              child: Container(
                alignment: Alignment.topLeft,
                padding:
                    const EdgeInsetsDirectional.only(start: 17, end: 20, top: 20),
                child: contractTaskLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: false,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        itemCount: getContractTask.length,
                        physics: const ScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              markAsDone(getContractTask[index]['csrId'],
                                  getContractTask[index]['trackingRef']);
                            }, // Handle your callback
                            child: Card(
                              color: Colors.pink[50],
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              elevation: 5.0,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.7,
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '#${getContractTask[index]['csrId']}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        selectedTask.contains(
                                                getContractTask[index]['csrId'])
                                            ? const Icon(
                                                Icons.check_box,
                                                color: Colors.green,
                                              )
                                            : const Icon(
                                                Icons.check_box_outline_blank,
                                                color: Colors.grey,
                                              ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    // Container(
                                    //   child: SingleChildScrollView(
                                    //     child: Text(
                                    //       getContractTask[index]
                                    //           ['customerName'],
                                    //       overflow: TextOverflow.ellipsis,
                                    //       textAlign: TextAlign.left,
                                    //       style: TextStyle(
                                    //         fontSize: 16,
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                    Text(
                                      getContractTask[index]['serviceArea']
                                          .toString(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      child: SingleChildScrollView(
                                        child: Text(
                                          getContractTask[index]['description'],
                                          textAlign: TextAlign.justify,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            selectedTask.isNotEmpty
                ? Padding(
                    padding:
                        const EdgeInsetsDirectional.only(end: 0, top: 30, start: 10),
                    child: GestureDetector(
                      onTap: () {
                        // setState(() {
                        //   buttonSubmit = true;
                        // });
                        apiService.showToast('Under Construction');
                        // checkinCheckout(widget.from);
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          height: 40,
                          width: MediaQuery.of(context).size.width / 2.6,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: widget.from == 'checkin'
                                    ? [
                                        Colors.blue,
                                        Colors.blue,
                                      ]
                                    : [
                                        Colors.orange,
                                        Colors.orange,
                                      ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                              topLeft: Radius.circular(15),
                              bottomLeft: Radius.circular(15),
                            ),
                          ),
                          alignment: AlignmentDirectional.center,
                          margin: const EdgeInsets.only(
                            left: 5.0,
                          ),
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buttonSubmit
                                  ? const Text(
                                      'Wait...',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : Text(
                                      widget.from == 'checkin'
                                          ? 'CHECK-IN'
                                          : 'CHECK-OUT',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                              const SizedBox(width: 5),
                              Icon(
                                widget.from == 'checkin'
                                    ? Icons.input
                                    : Icons.output,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
