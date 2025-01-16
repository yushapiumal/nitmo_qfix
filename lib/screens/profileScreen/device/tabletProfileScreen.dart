import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:localstorage/localstorage.dart';

import 'package:octo_image/octo_image.dart';
import 'package:provider/provider.dart';
import 'package:qfix_nitmo_new/Constant/Slideanimation.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
import 'package:qfix_nitmo_new/helper/DesignConfig.dart';
import 'package:qfix_nitmo_new/helper/StringsRes.dart';
import 'package:qfix_nitmo_new/provider/locale_provider.dart';
import 'package:qfix_nitmo_new/screens/landingScreen/landingScreen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class TabletProfileScreen extends StatefulWidget {
  const TabletProfileScreen({Key? key}) : super(key: key);

  @override
  State<TabletProfileScreen> createState() => _TabletProfileScreenState();
}

class _TabletProfileScreenState extends State<TabletProfileScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  final LocalStorage storage = LocalStorage('qfix');

  String myId = "";
  String myName = "";

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    super.initState();
    storage.ready.then((_) => {
          setState(() {
            myId = storage.getItem('sId');
            myName = storage.getItem('name');
          })
        });
  }

  @override
  void dispose() {
    super.dispose();
    _animationController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsRes.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: 30,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        shadowColor: Colors.transparent,
        title: Text(
          StringsRes.profileText.toUpperCase(),
          style: TextStyle(
            letterSpacing: 4,
          ),
        ),
        // bottom: PreferredSize(
        //   child: Divider(
        //     color: ColorsRes.greyColor,
        //     height: 2.3,
        //   ),
        //   preferredSize: Size(50, 5),
        // ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: ColorsRes.backgroundColor,
          child: Column(
            children: [
              SlideAnimation(
                position: 1,
                itemCount: 8,
                slideDirection: SlideDirection.fromTop,
                animationController: _animationController,
                child: Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 99.0),
                  child: Container(
                    alignment: Alignment.topCenter,
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * .01),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor:
                          Color.fromARGB(255, 250, 141, 8).withOpacity(0.5),
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/img/avatar1.png',
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SlideAnimation(
                position: 2,
                itemCount: 8,
                slideDirection: SlideDirection.fromBottom,
                animationController: _animationController,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 40.4),
                    child: Text(
                      myName,
                      style: TextStyle(
                          fontSize: 18,
                          color: ColorsRes.purpalColor,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              SlideAnimation(
                position: 3,
                itemCount: 8,
                slideDirection: SlideDirection.fromBottom,
                animationController: _animationController,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 99.0),
                    child: Text(
                      myId,
                      style: TextStyle(
                        fontSize: 16,
                        color: ColorsRes.purpalColor,
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 99),
              SlideAnimation(
                position: 5,
                itemCount: 8,
                slideDirection: SlideDirection.fromBottom,
                animationController: _animationController,
                child: Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 40),
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 40,
                      bottom: MediaQuery.of(context).size.height / 40),
                  decoration:
                      DesignConfig.halfCurve(ColorsRes.white, 30.0, 30.0),
                  height: MediaQuery.of(context).size.height / 1.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width / 15,
                            right: MediaQuery.of(context).size.width / 15),
                        title: Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 35,
                            ),
                            SizedBox(width: 18.0),
                            Text(
                              storage.getItem('calling_name'),
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: ColorsRes.textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        // trailing: SvgPicture.asset("assets/svg/back.svg"),
                        onTap: () {},
                      ),
                      Divider(
                        color: ColorsRes.greyColor,
                        indent: MediaQuery.of(context).size.width / 18,
                        endIndent: MediaQuery.of(context).size.width / 18,
                      ),
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width / 15,
                            right: MediaQuery.of(context).size.width / 15),
                        title: Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 35,
                            ),
                            SizedBox(width: 18.0),
                            Text(
                              storage.getItem('contact'),
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: ColorsRes.textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {},
                      ),
                      Divider(
                        color: ColorsRes.greyColor,
                        indent: MediaQuery.of(context).size.width / 18,
                        endIndent: MediaQuery.of(context).size.width / 18,
                      ),
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width / 15,
                            right: MediaQuery.of(context).size.width / 15),
                        title: Row(
                          children: [
                            Icon(
                              Icons.badge,
                              size: 35,
                            ),
                            SizedBox(width: 18.0),
                            Text(
                              storage.getItem('designation'),
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: ColorsRes.textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {},
                      ),
                      Divider(
                        color: ColorsRes.greyColor,
                        indent: MediaQuery.of(context).size.width / 18,
                        endIndent: MediaQuery.of(context).size.width / 18,
                      ),
                      langPicker(),
                      Divider(
                        color: ColorsRes.greyColor,
                        indent: MediaQuery.of(context).size.width / 18,
                        endIndent: MediaQuery.of(context).size.width / 18,
                      ),
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width / 15,
                            right: MediaQuery.of(context).size.width / 15),
                        title: Row(
                          children: [
                            Icon(
                              Icons.power_settings_new,
                              size: 35,
                            ),
                            SizedBox(width: 18.0),
                            Text(
                              AppLocalizations.of(context)!.logout,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: ColorsRes.textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => new AlertDialog(
                              title: new Text(
                                AppLocalizations.of(context)!.areyousure,
                              ),
                              content: new Text(AppLocalizations.of(context)!
                                  .doyouwantlogout),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.pop(
                                      context), // Navigator.of(context).pop(false),
                                  child: new Text(
                                      AppLocalizations.of(context)!.no),
                                ),
                                TextButton(
                                  // onPressed: () => Navigator.of(context).pop(true),
                                  onPressed: () {
                                    storage.clear();
                                    Navigator.popAndPushNamed(
                                        context, LandingScreen.routeName);
                                  },
                                  child: new Text(
                                      AppLocalizations.of(context)!.yes),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget langPicker() {
    final provider = Provider.of<LocaleProvider>(context);
    final locale = provider.locale ?? Locale('en');

    var selectedLang = storage.getItem('lang');

    return Container(
      margin: EdgeInsets.only(
        top: 20.0,
        left: 30.0,
        right: 30.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            child: ElevatedButton(
              child: Text(
                'EN',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                provider.setLocale(Locale('en'));
                storage.setItem('lang', 'en');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: (selectedLang == 'en') ? Colors.amber[100] : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // <-- Radius
                ),
              ),
            ),
          ),
          GestureDetector(
            child: ElevatedButton(
              child: Text(
                'සිං',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                provider.setLocale(Locale('si'));
                storage.setItem('lang', 'si');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: (selectedLang == 'si') ? Colors.amber[100] : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // <-- Radius
                ),
              ),
            ),
          ),
          GestureDetector(
            child: ElevatedButton(
              child: Text(
                'தமிழ்',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                provider.setLocale(Locale('ta'));
                storage.setItem('lang', 'ta');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: (selectedLang == 'ta') ? Colors.amber[100] : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // <-- Radius
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
