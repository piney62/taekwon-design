import 'package:flutter/widgets.dart';

/// Border-radius scale, matches the CSS prototype.
class TulRadius {
  TulRadius._();

  static const double xs = 8;
  static const double sm = 10;
  static const double md = 12;
  static const double lg = 14;
  static const double xl = 16;
  static const double xl2 = 18;
  static const double xl3 = 22;
  static const double xl4 = 24;
  static const double pill = 999;

  static const rXs = Radius.circular(xs);
  static const rSm = Radius.circular(sm);
  static const rMd = Radius.circular(md);
  static const rLg = Radius.circular(lg);
  static const rXl = Radius.circular(xl);
  static const rXl2 = Radius.circular(xl2);
  static const rXl3 = Radius.circular(xl3);
  static const rXl4 = Radius.circular(xl4);

  static const brXs = BorderRadius.all(rXs);
  static const brSm = BorderRadius.all(rSm);
  static const brMd = BorderRadius.all(rMd);
  static const brLg = BorderRadius.all(rLg);
  static const brXl = BorderRadius.all(rXl);
  static const brXl2 = BorderRadius.all(rXl2);
  static const brXl3 = BorderRadius.all(rXl3);
  static const brXl4 = BorderRadius.all(rXl4);
}

class TulSpacing {
  TulSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xl2 = 24;
  static const double xl3 = 32;
}
