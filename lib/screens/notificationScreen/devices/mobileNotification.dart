import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:localstorage/localstorage.dart';
import 'package:qfix_nitmo_new/api/apiService.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
import 'package:qfix_nitmo_new/screens/homeScreen/homeScreen.dart';


class MobileNotification extends StatefulWidget {
  const MobileNotification({Key? key}) : super(key: key);

  @override
  State<MobileNotification> createState() => _MobileNotificationState();
}

class _MobileNotificationState extends State<MobileNotification>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  APIService apiService = APIService();
  List notificationList = [];
  LocalStorage storage = LocalStorage('qfix');
  int count = 0;
  bool loading = false;
  @override
  void initState() {
    super.initState();
    startTime();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));
  }

  startTime() async {
    setState(() {
      loading = true;
    });
    var duration = const Duration(milliseconds: 3000);

    return Timer(duration, getMyNotifications);
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  void getMyNotifications() async {
    var myNotifications =
        await apiService.getMyNotifications(storage.getItem('sId'));

    if (myNotifications != false) {
      notificationList = myNotifications['notifications'];
      setState(() {
        count = notificationList.length;
        loading = false;
      });
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
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.popAndPushNamed(context, HomeScreen.routeName);
            },
          ),
          shadowColor: Colors.transparent,
          title: Text(
            'Notifications'.toUpperCase(),
            style: const TextStyle(
              letterSpacing: 4,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Container(
            color: ColorsRes.backgroundColor,
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height / 99),
                loading
                    ? Container(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.height / 2.5,
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      )
                    : notificationListData(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget notificationListData() {
    return count > 0
        ? ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: notificationList.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              var split = notificationList[index]['date'].split(" ");
              var date = split[0];
              var time = split[2] + ' ' + split[3];
              return Column(
                children: [
                  ListTile(
                    leading: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircleAvatar(
                        backgroundColor: ColorsRes.secondaryButton,
                        child: Icon(
                          Icons.notifications_none,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    title: Text(
                      notificationList[index]['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(notificationList[index]['description']),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(date),
                        Text(time),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 2,
                    thickness: 1,
                    indent: 20,
                    endIndent: 20,
                    color: ColorsRes.greyColor,
                  ),
                ],
              );
            },
          )
        : Center(
            child: Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height / 3,
              ),
              child: const Text('No notifications found'),
            ),
          );
  }
}
