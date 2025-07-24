
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:assets_audio_player/assets_audio_player.dart' as audioPlayer;

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:localstorage/localstorage.dart';

import 'package:overlay_support/overlay_support.dart';
import 'package:flutter/services.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
import 'package:qfix_nitmo_new/helper/DesignConfig.dart';
import 'package:qfix_nitmo_new/model/PushNotificationModel.dart';
import 'package:qfix_nitmo_new/screens/notificationScreen/notificationScreen.dart';

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("************ => Handling a background message: ${message.messageId}");
}

class NotificationAction extends StatefulWidget {
  const NotificationAction({
    Key? key,
  }) : super(key: key);

  @override
  State<NotificationAction> createState() => _NotificationActionState();
}

class _NotificationActionState extends State<NotificationAction> {
  final LocalStorage storage = LocalStorage('qfix');
  late int _totalNotifications;
  late final FirebaseMessaging _messaging;
  PushNotification? _notificationInfo;
  bool buzz = false;
  @override
  void initState() {
    _totalNotifications = 0;
    super.initState();
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      PushNotification notification = await PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
      );
      setState(() async {
        _notificationInfo = await notification;
        _totalNotifications++;
      });
    });
    checkForInitialMessage();
    registerNotification();
  }

  @override
  void dispose() {
    _totalNotifications = 0;

    super.dispose();
  }

  // For handling notification when the app is in terminated state
  checkForInitialMessage() async {
    await Firebase.initializeApp();
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      PushNotification notification = PushNotification(
        title: initialMessage.notification?.title,
        body: initialMessage.notification?.body,
      );
      setState(() {
        _notificationInfo = notification;
        _totalNotifications++;
      });
    }
  }

  void registerNotification() async {
    // 1. Initialize the Firebase app
    await Firebase.initializeApp();

    // 2. Instantiate Firebase Messaging
    _messaging = await FirebaseMessaging.instance;

    // 3. On iOS, this helps to take the user permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // Parse the message received

        PushNotification notification = PushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
          dataTitle: message.data['title'],
          dataBody: message.data['body'],
        );

        _notificationInfo = notification;
        _totalNotifications++;

        if (_notificationInfo != null) {
          // For displaying the notification as an overlay
          showSimpleNotification(
            Text(_notificationInfo!.title!),
            leading: NotificationBadge(totalNotifications: _totalNotifications),
            subtitle: Text(_notificationInfo!.body!),
            background: ColorsRes.chocalateColor,
            duration: const Duration(seconds: 2),
          );

          if (message.data['buzz'] == '1') {
            setState(() {
              buzz = true;
            });
            //playAudio();
          }
        }
      });
    } else {
      print('User declined or has not accepted permission');
    }
  }

 // final assetsAudioPlayer = audioPlayer.AssetsAudioPlayer();
  //playAudio() async {
  //  print('play');
   // try {
    //  await assetsAudioPlayer.open(
      //  audioPlayer.Audio("assets/audio/alarm_buzzer.wav"),
    //  );
      // assetsAudioPlayer.toggleLoop();
   // } catch (e) {
   //   print('play error --> ${e}');
   // }
 // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _totalNotifications = 0;
        });
        Navigator.popAndPushNamed(context, NotificationScreen.routeName);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Icon(Icons.notifications_none,
                color: ColorsRes.appBarText, size: 30),
          ),
          _totalNotifications > 0
              ? Align(
                  alignment: Alignment.topRight,
                  child: IntrinsicHeight(
                    child: Container(
                      decoration: DesignConfig.boxDecorationContainer(
                          ColorsRes.secondaryButton, 20),
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(top: 15, left: 5),
                      padding: const EdgeInsets.only(
                        left: 3,
                        right: 3,
                      ),
                      child: Text(
                        _totalNotifications.toString(),
                        style: Theme.of(context).textTheme.bodySmall!.merge(
                            const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              : const SizedBox()
        ],
      ),
    );
  }
}

class NotificationBadge extends StatelessWidget {
  final int totalNotifications;

  const NotificationBadge({required this.totalNotifications});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '$totalNotifications',
            style: const TextStyle(color: Colors.black, fontSize: 20),
          ),
        ),
      ),
    );
  }
}
