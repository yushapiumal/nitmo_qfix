import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


// SmartKit Color //
const Color purpal = Color(0xff3d3270);
final Color purpalOpacity22 = purpal.withOpacity(0.22);

const Color smarKitcolor1 = Color(0xFFe59999);
const Color smarKitcolor2 = Color(0xFFFFFFFF);
const Color color1 = Color(0xFFFB2A59);
const Color color2 = Color(0xFF7E152D);
const Color color3 = Color(0xFF132735);
AppBarTheme appBarTheme() {
  return AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    elevation: 2.0,
    color: smarKitcolor2,
    toolbarTextStyle: const TextStyle(
        color: Color(0xFF020202),
        fontSize: 22.0,
      ),
    iconTheme: const IconThemeData(
      color: Color(0xFF020202),
    ),
  );
}

List<Color> tilecolor = [
  const Color(0xFFF5F9F9),
  const Color(0xFFFEF4F4),
  const Color(0xFFFDF9FB),
  const Color(0xFFF6F5FB),
];
List<Color> tileiconbgcolor = [
  const Color(0xFFCDE4E4),
  const Color(0xFFFCE0DB),
  const Color(0xFFFBD7ED),
  const Color(0xFFE8E5F3),
];
List<Color> tiletextcolor = [
  const Color(0xFF469695),
  const Color(0xFFFD3627),
  const Color(0xFFC93F8D),
  const Color(0xFF3C326F),
];

// Grobag1 //

const Color grobag1 = Color(0xffF1FFF6);
const Color grobag2 = Color(0xff00B65F);
const Color grobag3 = Color(0xff005B30);
const Color grobag4 = Color(0xffF1FFF6);
const Color grobag5 = Color(0x3349DE7F);
const Color grobag6 = Color(0xFF9FF5CD);
const Color grobag7 = Colors.black;
const Color grobag8 = Color(0xFF777777);
Gradient grobaggradient = LinearGradient(
  begin: const Alignment(1.0, 1.0),
  end: const Alignment(-1.0, -1.0),
  colors: [grobag3, grobag2],
  stops: const [0.1, 0.9],
);

// CryptoTech //

const Color cryptocolor1 = Color(0xfff4fdfe);
//final Color cryptocolor2 = Color(0xff00e2d3);
//final Color cryptocolor3 = Color(0xff00b3d5);
const Color cryptocolor4 = Color(0xfff4fdfe);
const Color cryptocolor5 = Color(0x3360efff);
const Color cryptocolor6 = Color(0xFFDBF4F6);
const Color cryptocolor7 = Colors.black;
const Color cryptocolor8 = Color(0xFF777777);

// DatingApp //

const Color datingcolor1 = Color(0xffF5F5F5);
const Color datingcolor2 = Color(0xffE7266F);
const Color datingcolor3 = Color(0xffF39742);
const Color datingcolor4 = Color(0xfff4fdfe);
const Color datingcolor5 = Color(0x3360efff);
const Color datingcolor6 = Color(0xFFDBF4F6);
const Color datingcolor7 = Colors.black;
const Color datingcolor8 = Color(0xFF777777);

const Color cryptocolor2 = Color(0xFF422343);
const Color cryptocolor3 = Color(0xFF422343);

// MovieApp //

const Color moviecolor1 = Color(0xfff4fdfe);
const Color moviecolor2 = Color(0xff191C25);
const Color moviecolor3 = Color(0xff191C25);
const Color moviecolor4 = Color(0xfff4fdfe);
const Color moviecolor5 = Color(0x3360efff);
const Color moviecolor6 = Color(0xFFDBF4F6);
const Color moviecolor7 = Colors.black;
const Color moviecolor8 = Color(0xFF777777);

// TravelApp //

const Color travelcolor1 = Color(0xffEEF4FF);
const Color travelcolor2 = Color(0xFF102A3B);
const Color travelcolor3 = Color(0xFF2D67CC);
const Color travelcolor4 = Color(0xffD4E4FF);
const Color travelcolor5 = Color(0xffBBDDFF);
const Color travelcolor6 = Color(0xFFDBF4F6);
const Color travelcolor7 = Colors.black;
const Color travelcolor8 = Color(0xFF777777);

// Salon App
const Color salonbgcolor = Color(0xffF5F2F2);
const Color salondropdownbgcolor = Color(0xffe5e5e5);
const Color salonappcolor = Color(0xff66193E);
const Color salonlightfont = Color(0xffBAB5B5);
const Color salonmainlight = Color(0xffC397AC);
const Color salondarkshadow = Color(0xffAEAEC0);
const Color salonlightshadow = Color(0xFFffffff);

// meditation App
const Color meditationbgcolor = Color(0xffF5F2F2);
const Color meditationdropdownbgcolor = Color(0xffe5e5e5);
const Color meditationappcolor = Color(0xff485871);
const Color meditationlightfont = Color(0xffBAB5B5);
const Color meditationmainlight = Color(0xff3b9aac);
const Color meditationdarkshadow = Color(0xffAEAEC0);
const Color meditationlightshadow = Color(0xFFffffff);

// furniture App
const Color furniturebgcolor = Color(0xffF5F2F2);
const Color furnituredropdownbgcolor = Color(0xfff6f1eb);
const Color furnitureappcolor = Color(0xff3e786f);
const Color furniturelightfont = Color(0xffBAB5B5);
const Color furnituremainlight = Color(0xfff6f1eb);
const Color furnituredarkshadow = Color(0xffAEAEC0);
const Color furniturelightshadow = Color(0xFFffffff);


// GoRide App
const Color goridebgcolor = Color(0xffF5F2F2);
const Color goridedropdownbgcolor = Color(0xffe5e5e5);
const Color gorideappcolor = Color(0xffF4C90F);
const Color goridelightfont = Color(0xffBAB5B5);
const Color goridemainlight = Color(0xffF4C90F);
const Color goridedarkshadow = Color(0xffAEAEC0);
const Color goridelightshadow = Color(0xFFffffff);

// Dream Home  App
const Color dHomebgcolor = Color(0xffF5F2F2);
const Color dHomedropdownbgcolor = Color(0xffe5e5e5);
const Color dHomeappcolor =Color(0xffFEF5ED);
const Color dHomelightfont = Color(0xffBAB5B5);
const Color dHomemainlight = Color(0xffFEF5ED);
const Color dHomedarkshadow = Color(0xffAEAEC0);
const Color dHomelightshadow = Color(0xFFffffff);

Gradient gradient = LinearGradient(
  colors: [
    cryptocolor3,
    cryptocolor2,
  ],
  stops: const [0.1, 0.9],
  begin: Alignment.bottomCenter,
  end: Alignment.topCenter,
);

BoxShadow boxShadow = const BoxShadow(
  color: Colors.black12,
  offset: Offset(3, 3),
  blurRadius: 5,
);

BoxShadow transboxShadow = BoxShadow(
  color: Colors.white.withOpacity(0.0),
  offset: const Offset(3, 3),
  blurRadius: 5,
);
BoxDecoration gradient_box = BoxDecoration(
  gradient: gradient,
  boxShadow: [
    boxShadow,
  ],
);

OutlineInputBorder outlineborderedittext = OutlineInputBorder(
  borderSide: const BorderSide(width: 0.5, color: Colors.white),
  borderRadius: BorderRadius.circular(10.0),
);

Gradient appbargradient = LinearGradient(
    stops: const [0, 1],
    begin: const Alignment(-0.00, -1.00),
    end: const Alignment(0.00, 1.00),
    colors: [cryptocolor2, cryptocolor3]);

BoxDecoration circulargradient_box = BoxDecoration(
  gradient: gradient,
  borderRadius: BorderRadius.circular(10),
  boxShadow: [
    boxShadow,
  ],
);

BoxDecoration outlineboxtext = BoxDecoration(
  color: Colors.transparent,
  borderRadius: BorderRadius.circular(10),
  border: Border.all(color: cryptocolor2, width: 0.5),
);

// BookKing //

const Color bookKing1 = Color(0xfff1f2ff);
const Color bookKing2 = Color(0xff789af9);
const Color bookKing3 = Color(0xff3b9ca9);
const Color bookKing4 = Color(0xfff1f2ff);
const Color bookKing5 = Color(0x33bcc1ff);
const Color bookKing6 = Color(0xFFD5D8FD);

Gradient bookKinggradient = LinearGradient(
  begin: const Alignment(1.0, 1.0),
  end: const Alignment(-1.0, -1.0),
  colors: [bookKing3, bookKing2],
  stops: const [0.0, 1.0],
);

// // SmartKey //

const Color smartkey1 = Color(0xfff5fbf9);
const Color smartkey2 = Color(0xff69dea0);
const Color smartkey3 = Color(0xff3c9ea8);
const Color smartkey4 = Color(0xfff5fbf9);
const Color smartkey5 = Color(0x3379ffd2);
const Color smartkey6 = Color(0xFFD4FCEE);

Gradient smartkeygradient = LinearGradient(
  begin: const Alignment(1.0, 1.0),
  end: const Alignment(-1.0, -1.0),
  colors: [smartkey3, smartkey2],
  stops: const [0.0, 1.0],
);

final Shader linearGradient = const LinearGradient(
  colors: <Color>[Color(0xff3c9ea8), Color(0xff69dea0)],
).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

// Music //
const Color music1 = Color(0xffFFEAF3);
const Color music2 = Color(0xffC40F8E);
const Color music3 = Color(0xffFB5293);
const Color music4 = Color(0xFFE99DBE);
const Color music5 = Color(0x33FFD9E8);
const Color music6 = Color(0xFFF8B1E3);

// Quotes //
const Color quotes1 = Color(0xffF8E9FF);
const Color quotes2 = Color(0xff6A0FC4);
const Color quotes3 = Color(0xffD998FA);
const Color quotes4 = Color(0xffF8E9FF);
const Color quotes5 = Color(0x33A4A7FF);
const Color quotes6 = Color(0xFFDBBFF8);

// WebApp //
const Color webApp1 = Color(0xffD8F1FF);
const Color webApp2 = Color(0xff1D6CBA);
const Color webApp3 = Color(0xff54C1FF);
const Color webApp4 = Color(0xffD8F1FF);
const Color webApp5 = Color(0x337BCFFE);
const Color webApp6 = Color(0xFFAFD0F1);

// eStudy //

const Color eStudy1 = Color(0xfff7f1ff);
const Color eStudy2 = Color(0xff838aea);
const Color eStudy3 = Color(0xff796fc1);
const Color eStudy4 = Color(0xfff7f1ff);
const Color eStudy5 = Color(0x33cca7ff);
const Color eStudy6 = Color(0xFFDFCCF8);

// FoodMaster //

const Color foodmaster1 = Color(0xfffef4f4);
const Color foodmaster2 = Color(0xffffcca6);
const Color foodmaster3 = Color(0xffff9b9c);
const Color foodmaster4 = Color(0xfffef4f4);
const Color foodmaster5 = Color(0x33ffa4a4);
const Color foodmaster6 = Color(0xFFFDDCDC);

// News //
const Color news1 = Color(0xfff1f2ff);
const Color news2 = Color(0xff7D8CEB);
const Color news3 = Color(0xff345EB4);
const Color news4 = Color(0xfff1f2ff);
const Color news5 = Color(0x33bcc1ff);
const Color news6 = Color(0xFFFDDCDC);

// VPN //
const Color vpn11 = Color(0xffFEFAF1);
const Color vpn22 = Color(0xffF7C331);
const Color vpn33 = Color(0xffF7882F);
const Color vpn44 = Color(0xfff7f1ff);
const Color vpn55 = Color(0x33FFA7A7);
const Color vpn66 = Color(0xFFFAE9BB);
const Color vpn77 = Color(0xFF777777);

Gradient vpntopgradient = LinearGradient(
  colors: [
    vpn22,
    vpn33,
  ],
  stops: const [0.7, 0.3],
  begin: const Alignment(-0.91, -0.42),
  end: const Alignment(0.91, 0.42),
);

BoxDecoration vpncirculargradient_box = BoxDecoration(
  gradient: vpngradient,
  borderRadius: BorderRadius.circular(10),
  boxShadow: [
    boxShadow,
  ],
);

Gradient vpngradient = LinearGradient(
  colors: [
    vpn22,
    vpn33,
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
