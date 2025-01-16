import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class TabletSites extends StatefulWidget {
  const TabletSites({Key? key, required this.markUpdateTask}) : super(key: key);
  final markUpdateTask;

  @override
  State<TabletSites> createState() => _TabletSitesState();
}

class _TabletSitesState extends State<TabletSites>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  bool btnDisable = false;
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

  Widget helpingText() {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 20),
      width: 600,
      child: Text(
        "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, ",
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget buttonMarkIn() {
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
              Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.input_rounded,
                        color: Colors.black,
                        size: 35.0,
                      ),
                      SizedBox(width: 15),
                      Text(
                        AppLocalizations.of(context)!.markIn,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ],
                  )
                ],
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
                      await widget.markUpdateTask('site', 'mark-in', false);
                  if (submit || !submit) {
                    setState(() {
                      btnDisable = false;
                    });
                  }
                },
          color: ColorsRes.secondaryButton),
    );
  }

  Widget buttonMarkOut() {
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
              Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.output_rounded,
                        color: Colors.black,
                        size: 35.0,
                      ),
                      SizedBox(width: 15),
                      Text(
                        AppLocalizations.of(context)!.markOut,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  )
                ],
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
                      await widget.markUpdateTask('site', 'mark-out', false);
                  if (submit || !submit) {
                    setState(() {
                      btnDisable = false;
                    });
                  }
                },
          color: ColorsRes.secondaryButton),
    );
  }

  Widget buttonOnTheWay() {
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
              Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.motorcycle_rounded,
                        color: Colors.black,
                        size: 35.0,
                      ),
                      SizedBox(width: 15),
                      Text(
                        AppLocalizations.of(context)!.onTheWay,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  )
                ],
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
                      await widget.markUpdateTask('site', 'on-the-way', false);
                  if (submit || !submit) {
                    setState(() {
                      btnDisable = false;
                    });
                  }
                },
          color: ColorsRes.secondaryButton),
    );
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
              buttonMarkIn(),
              buttonMarkOut(),
              buttonOnTheWay(),
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
}