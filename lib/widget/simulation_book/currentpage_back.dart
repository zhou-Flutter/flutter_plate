import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_plate/widget/simulation_book/tool/math_tool.dart';

class CurrentPageBack extends StatefulWidget {
  Position pt;
  TouchPt touchPt;
  Widget pageBack;

  CurrentPageBack({
    Key? key,
    required this.pt,
    required this.touchPt,
    required this.pageBack,
  }) : super(key: key);

  @override
  State<CurrentPageBack> createState() => _CurrentPageBackState();
}

class _CurrentPageBackState extends State<CurrentPageBack> {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: PageBackClipper(widget.pt),
      child: transforms(),
    );
  }

  Widget transforms() {
    if (widget.touchPt == TouchPt.touchTop) {
      return Transform(
        alignment: FractionalOffset.topRight,
        transform: Matrix4.identity()
          ..translate(widget.pt.backPt.x, widget.pt.backPt.y)
          ..rotateY(pi)
          ..rotateZ(pi / 2 - widget.pt.jA),
        child: backPage(),
      );
    } else {
      return Transform(
        alignment: FractionalOffset.bottomRight,
        transform: Matrix4.identity()
          ..translate(widget.pt.backPt.x, widget.pt.backPt.y)
          ..rotateY(-pi)
          ..rotateZ(-pi / 2 - widget.pt.jA),
        child: backPage(),
      );
    }
  }

  Widget backPage() {
    return Opacity(
      opacity: 0.5,
      child: widget.pageBack,
    );
  }
}

///剪切 当前页的背面
class PageBackClipper extends CustomClipper<Path> {
  /// 坐标位置
  Position pt;
  PageBackClipper(
    this.pt,
  );
  @override
  Path getClip(Size size) {
    // 绘制AB面 (下一页与当前页的背面)
    Path pathAB = Path()
      ..moveTo(pt.j.x, pt.j.y)
      ..quadraticBezierTo(pt.h.x, pt.h.y, pt.k.x, pt.k.y)
      ..lineTo(pt.a.x, pt.a.y)
      ..lineTo(pt.b.x, pt.b.y)
      ..quadraticBezierTo(pt.e.x, pt.e.y, pt.c.x, pt.c.y)
      ..lineTo(pt.f.x, pt.f.y)
      ..close();

    // 绘制当前页的背面
    Path pathB = Path()
      ..moveTo(pt.d.x, pt.d.y)
      ..lineTo(pt.a.x, pt.a.y)
      ..lineTo(pt.i.x, pt.i.y)
      ..close();
    Path mPathB = Path.combine(PathOperation.intersect, pathAB, pathB);

    return mPathB;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
