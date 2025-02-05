import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:localstorage/localstorage.dart';

import 'package:octo_image/octo_image.dart';
import 'package:qfix_nitmo_new/Constant/Slideanimation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:qfix_nitmo_new/api/apiService.dart';
import 'package:qfix_nitmo_new/helper/CheckingCheckoutBottom.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
import 'package:qfix_nitmo_new/helper/DesignConfig.dart';
import 'package:qfix_nitmo_new/helper/Drawer.dart';
import 'package:qfix_nitmo_new/helper/NotificationAction.dart';
import 'package:qfix_nitmo_new/helper/StringsRes.dart';
import 'package:qfix_nitmo_new/model/TaskModel.dart';
import 'package:qfix_nitmo_new/screens/manageScreen/manageScreen.dart';

class MobileHome extends StatefulWidget {
  const MobileHome({Key? key, required this.markUpdateTask }) : super(key: key);
  final bool markUpdateTask;
  

  
  @override
  State<MobileHome> createState() => _MobileHomeState();
}

class _MobileHomeState extends State<MobileHome> with TickerProviderStateMixin {
  String appName = "Q F I X";
  int currentIndex = 0;
  PageController? _controller;
  bool descTextShowFlag = false;
  TabController? _tabController;
  int _activeIndex = 0;
  AnimationController? _animationController;
  final LocalStorage storage = LocalStorage('qfix');
  APIService apiService = APIService();
  Future<List<TaskModel>>? taskList;
  int _taskListCount = 0;
  bool isLoading = false;
  var tempArray = Map();
  List customArrayByDates = [];

  late Animation<Color?> animation;
  late AnimationController controller;
  DateTime? tempPickedDate;
  ScrollController _scrollBottomBarController =
      ScrollController(); // set controller on scrolling
  bool isScrollingDown = false;
  bool _show = true;
  double bottomBarHeight = 75; // set bottom bar height
  double _bottomBarOffset = 0;
  String address = StringsRes.homeText;
  String title = "TASK";
  late Timer _timer;
  final DateTime now = DateTime.now();
  String? _dateTime;
  bool checkincheckoutBtnDisable = false;

  @override
  void initState() {
    super.initState();
    getTaskList();
    _timer = new Timer.periodic(Duration(seconds: 1), (Timer t) => getTime());

    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    // _controller = PageController(initialPage: 0);
    _tabController = TabController(vsync: this, length: 4);
    _tabController!.addListener(() {
      setState(() {
        _activeIndex = _tabController!.index;
      });
    });
    controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    final CurvedAnimation curve =
        CurvedAnimation(parent: controller, curve: Curves.linear);
    animation =
        ColorTween(begin: Colors.white, end: Colors.amber[900]).animate(curve);

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });
    controller.forward();

    setTenant();
  }

  setTenant() async {
    setState(() {
      appName = storage.getItem('tenant').toUpperCase();
    });
  }

  @override
  void dispose() {
    _animationController!.dispose();
    _scrollBottomBarController.removeListener(() {});
    _tabController!.removeListener(() {});
    controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  getTime() {
    String formattedDateTime = "";
    String suffix = 'th';
    final int digit = now.day % 10;
    if ((digit > 0 && digit < 4) && (now.day < 11 || now.day > 13)) {
      suffix = <String>['st', 'nd', 'rd'][digit - 1];
    }
    formattedDateTime = DateFormat("d'$suffix' MMM yyyy - kk:mm:ss")
        .format(DateTime.now())
        .toString();

    setState(() {
      _dateTime = formattedDateTime;
      tempPickedDate = DateTime.now();
    });
  }

  changeTitle(tabValue) {
    var name = "ALL";
    if (tabValue == 0) {
      name = "ALL";
      taskList!.then((value) {
        value.shuffle();
      });
    }
    if (tabValue == 1) {
      name = "OPEN";
      taskList!.then((value) {
        value.shuffle();
        value.sort((a, b) => a.status.compareTo(b.status));
      });
      // taskList!.then((value) {
      //   value.where((element) => element.status.contains('OPEN'));
      // });
    }
    if (tabValue == 2) {
      name = "PRIORITY";
      taskList!.then((value) {
        value.sort((a, b) => a.complexity.compareTo(b.complexity));
      });
    }
    if (tabValue == 3) {
      name = "MINE";
    }

    setState(() {
      title = name;
    });
  }

  getTaskList() async {
    setState(() {
      isLoading = true;
      final Future<List<TaskModel>> tasks = apiService.getTaskList();
      tasks.then((value) {
        _taskListCount = value.length;

        for (var element in value) {
          var date = DateTime.fromMillisecondsSinceEpoch(element.uts * 1000);
          var format = DateFormat('yyyy-MM-dd').format(date);
          tempArray[format] = [element];
        }
        setState(() {
          customArrayByDates.add(tempArray);
        });
      });

      taskList = tasks;

      if ((_taskListCount > 0)) {
        setState(() {
          // taskList = tasks;
          isLoading = false;
        });
      } else {
        isLoading = false;
      }
    });

    customArrayByDates.map((value) {
      for (var element in value) {
        print(element);
      }
    });
    print(customArrayByDates);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        centerTitle: true,
        title: Text(
          appName,
          style: const TextStyle(
            letterSpacing: 4,
          ),
        ),
        shadowColor: Colors.transparent,
        actions: const [
          NotificationAction(),
        ],
      ),
      drawer: const CustomDrawer(),
      backgroundColor: ColorsRes.backgroundColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: NestedScrollView(
          controller: _scrollBottomBarController,
          physics: const AlwaysScrollableScrollPhysics(),
          clipBehavior: Clip.none,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                backgroundColor: ColorsRes.backgroundColor,
                shadowColor: Colors.transparent,
                automaticallyImplyLeading: false,
                toolbarHeight:0 ,
                titleSpacing: 0,
                pinned: true,
                bottom: TabBar(
                  physics: const AlwaysScrollableScrollPhysics(),
                  isScrollable: true,
                  padding: const EdgeInsets.only(top: 5.0, bottom: 10.0),
                  indicatorPadding: EdgeInsets.zero,
                  controller: _tabController,
                  labelColor: ColorsRes.white,
                  unselectedLabelColor: ColorsRes.greyColor,
                  indicator:
                      DesignConfig.buttonShadowColor(ColorsRes.tabsColor, 20.0),
                  labelStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                  indicatorColor: Colors.transparent,
                  tabs: [
                    Container(
                      padding: const EdgeInsets.only(
                          bottom: 6.0, top: 6.0, left: 10.0, right: 10.0),
                      child: Text(
                     AppLocalizations.of(context)!.all,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                          bottom: 6.0, top: 6.0, left: 10.0, right: 10.0),
                      child:  Text(
                      AppLocalizations.of(context)!.open,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                          bottom: 6.0, top: 6.0, left: 10.0, right: 10.0),
                      child:  Text(
                        AppLocalizations.of(context)!.priority,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                          bottom: 6.0, top: 6.0, left: 10.0, right: 10.0),
                      child:  Text(
                        AppLocalizations.of(context)!.mine,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
                elevation: 0,
                floating: true,
              )
            ];
          },
          body: Container(
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.width / 50),
            color: ColorsRes.appBG,
            child: Container(
              child: TabBarView(
                controller: _tabController,
                children: [
                  taskData('all'),
                  taskData('open'),
                  taskData('priority'),
                  taskData('mine'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  tabsFilter(filterType, listData) {
    if (filterType == 'all') {
      return showWorkAddress(listData);
    }
    if (filterType == 'open') {
      return listData.status.contains('OPEN')
          ? showWorkAddress(listData)
          : SizedBox();
    }
    if (filterType == 'mine') {
      return listData.assigned_to['s_id']
              .toString()
              .contains(storage.getItem('sId'))
          ? showWorkAddress(listData)
          : SizedBox();
    }

    return showWorkAddress(listData);
  }

  Widget taskData(filter) {
    return _taskListCount == 0
        ? Container(
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Center(
                child: Text('No CSR found'),
              ),
            ),
          )
        : FutureBuilder<List<TaskModel>>(
            future: taskList,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SlideAnimation(
                  position: 1,
                  itemCount: 8,
                  slideDirection: SlideDirection.fromLeft,
                  animationController: _animationController,
                  child: RefreshIndicator(
                    onRefresh: _pullRefresh,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _taskListCount,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                            padding: EdgeInsets.only(
                              top: 9,
                              bottom: 20.0,
                            ),
                            child: tabsFilter(
                                filter,
                                snapshot
                                    .data![snapshot.data!.length - index - 1]));
                      },
                    ),
                  ),
                );
              }
              return Container(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 90),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                ),
              );
            },
          );
  }

  Future<void> _pullRefresh() async {
    getTaskList();
  }

  Widget checkingCheckoutSection() {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          SlideAnimation(
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
                    height: MediaQuery.of(context).size.height / 7,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 244, 241, 241),
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
                      height: MediaQuery.of(context).size.height,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Column(
                        children: [
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.only(
                                      left: 18,
                                    ),
                                    child: Text(
                                      _dateTime ?? "loading...",
                                      maxLines: 2,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 55,
                                  margin: const EdgeInsets.only(right: 10),
                                  width: 45,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ColorsRes.detailItemBackgroundColor,
                                    border: Border.all(
                                      width: 1,
                                      color:
                                          ColorsRes.detailItemBackgroundColor,
                                    ),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.access_time,
                                      color: ColorsRes.black,
                                    ),
                                    onPressed: () {
                                      selectDate(CupertinoDatePickerMode.time);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 8.0,
                              top: 10,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    projectCard('checkin');
                                  },
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Container(
                                      height: 40,
                                      width: MediaQuery.of(context).size.width /
                                          2.6,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                            colors: [
                                              Colors.blue,
                                              Colors.blue,
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          bottomLeft: Radius.circular(15),
                                        ),
                                      ),
                                      alignment: AlignmentDirectional.center,
                                      margin: EdgeInsets.only(
                                        left: 20.0,
                                      ),
                                      padding: EdgeInsets.all(0.5),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'CHECK-IN',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Icon(
                                            Icons.input,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    projectCard('checkout');
                                  },
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Container(
                                      height: 40,
                                      width: MediaQuery.of(context).size.width /
                                          2.6,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                            colors: [
                                              Colors.orange,
                                              Colors.orange,
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight),
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(15),
                                          bottomRight: Radius.circular(15),
                                        ),
                                      ),
                                      alignment: AlignmentDirectional.center,
                                      margin: EdgeInsets.only(
                                        left: 5.0,
                                      ),
                                      padding: EdgeInsets.all(0.5),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'CHECK-OUT',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Icon(
                                            Icons.output,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget showStatus(status) {
    if (status == 'CLOSE') {
      // COMPLETE
      return Icon(
        Icons.radio_button_checked,
        color: Colors.green,
      );
    }
    if (status == 'OPEN') {
      return Icon(
        Icons.radio_button_checked,
        color: Colors.purple,
      );
    }

    if (status == 'INPROGRESS') {
      return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          return Icon(
            Icons.radio_button_checked,
            color: animation.value,
          );
        },
      );
    }
    if (status == 'DELAY') {
      return Icon(
        Icons.radio_button_checked,
        color: Colors.amber[700],
      );
    }

    return Icon(
      Icons.radio_button_off,
      color: ColorsRes.greyColor,
    );
  }

  Widget showWorkAddress(data) {
    return SlideAnimation(
      position: 1,
      itemCount: _taskListCount,
      slideDirection: SlideDirection.fromLeft,
      animationController: _animationController,
      child: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ManageScreen(
                taskData: data, 
                markUpdateTask:widget.markUpdateTask,
              ),
            ),
          );
        },
        child: Container(
          decoration: DesignConfig.buttonShadowColor(
              data.status != 'CLOSE' ? Colors.purple[50]! : Colors.green[50]!,
              10),
          margin: EdgeInsets.only(
              top: 1,
              bottom: 2,
              left: MediaQuery.of(context).size.width / 20,
              right: MediaQuery.of(context).size.width / 20),
          child: Container(
            decoration: data.status != 'CLOSE'
                ? DesignConfig.boxDecorationBorderButtonColor(
                    Colors.purple[100]!, 10)
                : DesignConfig.boxDecorationBorderButtonColor(
                    Colors.green[100]!, 10),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              children: [
                Row(
                  children: [
                    showStatus(data.status),
                    SizedBox(width: 10.0),
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            '#' + data.csr_id.toString(),
                            style: TextStyle(
                                fontSize: 17,
                                color: ColorsRes.black,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Text(
                              data.customer['name'].toUpperCase(),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 14, color: ColorsRes.purpalColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        apiService.showToast('call now');
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10),
                        height: 28.0,
                        width: 28.0,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.greenAccent[700]!.withOpacity(0.70)),
                        child: Padding(
                          padding: EdgeInsets.all(2),
                          child: Icon(
                            Icons.phone,
                            size: 15,
                            color: Colors.brown[900],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    SizedBox(width: 30.0),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  data.description,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                height: 28.0,
                                width: 28.0,
                                decoration: DesignConfig.complexityIcon(
                                    data.complexity),
                                child: Padding(
                                  padding: EdgeInsets.all(2),
                                  child: Center(
                                    child: Text(
                                      data.complexity,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Flexible(
                              //   child: Text(
                              //     "",
                              //     style: TextStyle(
                              //       fontSize: 14,
                              //       color: Colors.black54,
                              //     ),
                              //   ),
                              // ),
                              Expanded(
                                child: Text(
                                  data.customer['address'] == ""
                                      ? ' -'
                                      : data.customer['address'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  selectDate(CupertinoDatePickerMode mode) async {
    DateTime? pickedDate = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (context) {
        return Container(
          height: 250,
          child: Column(
            children: <Widget>[
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    CupertinoButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    CupertinoButton(
                      child: Text('Done'),
                      onPressed: () {
                        print(tempPickedDate);
                        Navigator.of(context).pop(tempPickedDate);
                      },
                    ),
                  ],
                ),
              ),
              const Divider(
                height: 0,
                thickness: 1,
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: mode,
                  initialDateTime: tempPickedDate,
                  maximumDate: tempPickedDate,
                  onDateTimeChanged: (DateTime dateTime) {
                    tempPickedDate = dateTime;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  projectCard(from) {
    //  checkinCheckout('checkout');

    return showModalBottomSheet<void>(
      elevation: 0,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(50.0),
          topRight: Radius.circular(50.0),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        return CheckinCheckoutBottom(
            from: from, tempPickedDate: tempPickedDate);
      },
    );
  }
}
