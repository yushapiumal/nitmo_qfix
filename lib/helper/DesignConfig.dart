// import 'package:connectivity/connectivity.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
import 'package:qfix_nitmo_new/helper/flutter_rating_bar.dart';


// import 'package:smartkit/AppFeature/UIScreens/FurnitureUI/helper/ColorsRes.dart';
// import 'package:smartkit/AppFeature/UIScreens/FurnitureUI/helper/flutter_rating_bar.dart';

class DesignConfig {
  static RoundedRectangleBorder setRoundedBorder(
      Color bordercolor, double bradius, bool issetside) {
    return RoundedRectangleBorder(
        side: BorderSide(color: bordercolor, width: 0),
        borderRadius: BorderRadius.circular(bradius));
  }

  static BoxDecoration boxDecorationButton(Color color1, Color color2) {
    return BoxDecoration(
      gradient: LinearGradient(colors: [
        color1,
        color2,
      ], begin: Alignment.centerLeft, end: Alignment.centerRight),
      borderRadius: BorderRadius.circular(10),
    );
  }

  static BoxDecoration boxDecorationContainer(Color color, double radius) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static BoxDecoration boxDecorationHalfContainer(Color color) {
    return BoxDecoration(
      color: color,
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(
            10.0,
          ),
          topRight: Radius.circular(10.0)),
    );
  }

  static BoxDecoration boxBorderContainer(
      Color color, Color borderColor, double radius) {
    return BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor,
          width: 1,
        ));
  }

  static BoxDecoration boxDecorationBorderButtonColor(
      Color color, double sizes) {
    return BoxDecoration(
        borderRadius: BorderRadius.circular(sizes),
        border: Border.all(color: color, width: 1));
  }

  static BoxDecoration circleButton() {
    return BoxDecoration(
        shape: BoxShape.circle, color: ColorsRes.greyColor.withOpacity(0.50));
  }

  static BoxDecoration complexityIcon(type) {
    if (type == 'L1') {
      // Low
      return BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue.withOpacity(0.70),
      );
    }
    if (type == 'L2') {
      // Medium
      return BoxDecoration(
          shape: BoxShape.circle, color: ColorsRes.yellow.withOpacity(0.70));
    }
    if (type == 'L3') {
      // High
      return BoxDecoration(
          shape: BoxShape.circle, color: Colors.red.withOpacity(0.70));
    }
    return BoxDecoration(
        shape: BoxShape.circle, color: ColorsRes.greyColor.withOpacity(0.50));
  }

  static BoxDecoration boxDecorationButtonColor(
      Color color1, Color color2, double sizes) {
    return BoxDecoration(
      gradient: LinearGradient(colors: [
        color1,
        color2,
      ], begin: Alignment.centerLeft, end: Alignment.centerRight),
      borderRadius: BorderRadius.circular(sizes),
    );
  }

  static BoxDecoration buttonShadowColor(Color btncolor, double radius) {
    return BoxDecoration(
      color: btncolor,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: const [
        BoxShadow(
          color: Color(0x29000000),
          spreadRadius: 0,
          blurRadius: 2,
          offset: Offset(0, 3),
        )
      ],
    );
  }

  static BoxDecoration halfCurve(
      Color btncolor, double radius1, double radius2) {
    return BoxDecoration(
      color: btncolor,
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius1),
          topRight: Radius.circular(radius2)),
      boxShadow: const [
        BoxShadow(
          color: Color.fromARGB(41, 0, 0, 0),
          spreadRadius: 0,
          blurRadius: 20,
          offset: Offset(2, 2),
        )
      ],
    );
  }

  static BoxDecoration buttonShadowDetalColor(Color btncolor, double radius) {
    return BoxDecoration(
      color: btncolor,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: const [
        BoxShadow(
          color: Color(0x29000000),
          spreadRadius: 0,
          blurRadius: 10,
          offset: Offset(2, 2),
        )
      ],
    );
  }

  static BoxDecoration buttonShadow(Color btncolor, double radius) {
    return BoxDecoration(
      color: btncolor,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: const [
        BoxShadow(
          color: Color(0x29000000),
          spreadRadius: 0,
          blurRadius: 8,
          offset: Offset(0, 2),
        )
      ],
    );
  }

  static BoxDecoration buttonShadowColorListColor(Color btncolor) {
    return BoxDecoration(
      color: btncolor,
      shape: BoxShape.circle,
      boxShadow: const [
        BoxShadow(
          color: Color(0x29000000),
          spreadRadius: 0,
          blurRadius: 10,
          offset: Offset(2, 2),
        )
      ],
    );
  }

  static Widget displayCourseImage(String image, double height, double width) {
    return Image.asset(
      image,
      width: width,
      height: height,
      fit: BoxFit.fill,
    );
  }

  static Widget displayRating(String rating, bool isfullratingbar) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 5),
      child: Row(
        children: <Widget>[
          isfullratingbar
              ? RatingBarIndicator(
                  rating: double.parse(rating),
                  itemBuilder: (context, index) => Icon(
                    Icons.star,
                    color: ColorsRes.ratingColor,
                  ),
                  itemCount: 5,
                  itemSize: 14,
                  direction: Axis.horizontal,
                )
              : Icon(
                  Icons.star,
                  size: 14,
                  color: ColorsRes.ratingColor,
                ),
          Text(
            "\t\t$rating",
            style: TextStyle(
                color: ColorsRes.greyColor, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  static Future<bool> checkInternet() async {
    bool check = false;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      //print("===check==true");
      // return true;
      check = true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      //print("===check=***=true");
      //return true;
      check = true;
    }
    //print("===check==false");
    //return false;
    return check;
  }
}

class BarChart {
  final String year;
  final int sale;
  final Color barColor;

  BarChart(this.year, this.sale, this.barColor);
}

class CircleTabIndicator extends Decoration {
  final BoxPainter _painter;

  CircleTabIndicator({@required Color? color, @required double? radius})
      : _painter = _CirclePainter(color!, radius!);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _painter;
}

class _CirclePainter extends BoxPainter {
  final Paint _paint;
  final double radius;

  _CirclePainter(Color color, this.radius)
      : _paint = Paint()
          ..color = color
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Offset circleOffset =
        offset + Offset(cfg.size!.width / 2, cfg.size!.height - radius - 5);
    canvas.drawCircle(circleOffset, radius, _paint);
  }
}
