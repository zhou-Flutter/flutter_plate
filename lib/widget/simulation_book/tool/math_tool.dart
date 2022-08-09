import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dart:ui' as ui;

class MathTool {
  /*
     details   拖拽坐标
     f         顶点坐标
     touchPt   触摸位置
   */
  ///计算页面需要的坐标
  static Position coordinate(
      Point<double> details, Point<double> f, TouchPt touchPt,
      {bool constraint = false}) {
    //手指拖拽坐标
    Point<double> a = details;
    //此刻为手指 未拖拽时
    if (a.x == 0 && a.y == 0) {
      return Position(f: f, a: a);
    }
    //顶点坐标与手指拖拽左边的中点
    Point<double> g = Point((a.x + f.x) / 2, (a.y + f.y) / 2);

    //二阶贝塞尔曲线 的控制点  （书页底部）
    var em = (f.y - g.y) * (f.y - g.y) / (f.x - g.x);
    Point<double> e = Point(g.x - em, f.y);

    //二阶贝塞尔曲线 的控制点 （书页右侧）
    var hz = (f.x - g.x) * (f.x - g.x) / (f.y - g.y);
    Point<double> h = Point(f.x, g.y - hz);

    //书页与屏幕交点 底部
    Point<double> c = Point(e.x - (f.x - e.x) / 2, f.y);

    //书页与屏幕交点 右侧
    Point<double> j = Point(f.x, h.y - (f.y - h.y) / 2);

    double k1 = towPointKb(a, e);
    double k2 = towPointKb(c, j);
    double b1 = MathTool.towPointKb(a, e, isK: false);
    double b2 = MathTool.towPointKb(c, j, isK: false);

    double k3 = MathTool.towPointKb(a, h);
    double k4 = MathTool.towPointKb(c, j);
    double b3 = MathTool.towPointKb(a, h, isK: false);
    double b4 = MathTool.towPointKb(c, j, isK: false);

    //贝塞尔曲线的开始点 与结束点
    Point<double> b =
        Point((b2 - b1) / (k1 - k2), (b2 - b1) / (k1 - k2) * k1 + b1);
    Point<double> k =
        Point((b4 - b3) / (k3 - k4), (b4 - b3) / (k3 - k4) * k3 + b3);

    //贝塞尔曲线的 顶点
    Point<double> d =
        Point(((c.x + b.x) / 2 + e.x) / 2, ((c.y + b.y) / 2 + e.y) / 2);
    Point<double> i =
        Point(((j.x + k.x) / 2 + h.x) / 2, ((j.y + k.y) / 2 + h.y) / 2);

    ///如果底部划出去，则限制划出去
    if (constraint) {
      if (c.x < 0) {
        //重新计算a 点 （拖拽点）
        double fc = f.x - c.x;
        double fa = f.x - a.x;
        double bb1 = f.x * fa / fc;
        double fd1 = f.y - a.y;
        double fd = bb1 * fd1 / fa;
        a = Point(f.x - bb1, f.y - fd);

        //顶点坐标与手指拖拽左边的中点
        g = Point((a.x + f.x) / 2, (a.y + f.y) / 2);
        //二阶贝塞尔曲线 的控制点  （书页底部）
        var em = (f.y - g.y) * (f.y - g.y) / (f.x - g.x);
        e = Point(g.x - em, f.y);

        //二阶贝塞尔曲线 的控制点 （书页右侧）
        var hz = (f.x - g.x) * (f.x - g.x) / (f.y - g.y);
        h = Point(f.x, g.y - hz);

        //书页与屏幕交点 底部
        c = Point(e.x - (f.x - e.x) / 2, f.y);

        //书页与屏幕交点 右侧
        j = Point(f.x, h.y - (f.y - h.y) / 2);

        k1 = MathTool.towPointKb(a, e);
        k2 = MathTool.towPointKb(c, j);
        b1 = MathTool.towPointKb(a, e, isK: false);
        b2 = MathTool.towPointKb(c, j, isK: false);

        k3 = MathTool.towPointKb(a, h);
        k4 = MathTool.towPointKb(c, j);
        b3 = MathTool.towPointKb(a, h, isK: false);
        b4 = MathTool.towPointKb(c, j, isK: false);

        //贝塞尔曲线的开始点 与结束点
        b = Point((b2 - b1) / (k1 - k2), (b2 - b1) / (k1 - k2) * k1 + b1);
        k = Point((b4 - b3) / (k3 - k4), (b4 - b3) / (k3 - k4) * k3 + b3);

        //贝塞尔曲线的 顶点
        d = Point(((c.x + b.x) / 2 + e.x) / 2, ((c.y + b.y) / 2 + e.y) / 2);
        i = Point(((j.x + k.x) / 2 + h.x) / 2, ((j.y + k.y) / 2 + h.y) / 2);
      }
    }

    ///背面翻转 位移 坐标
    // Point<double> backPt = Point(-(f.x - a.x), -(f.y - a.y));
    Point<double> backPt = Point(-(f.x - a.x), -(f.y - a.y));

    // 两点距离公式 √((x1-x2)^2+(y1-y2)^2)    开根号sqrt  平方pow
    var ah = sqrt(pow(a.x - h.x, 2) + pow(a.y - h.y, 2));
    //旋转角度 反三角函数
    var jA = asin((h.y - a.y) / ah);

    ///绘制 投影到当前页的阴影
    double yyb1 = d.y - k1 * (d.x);
    double yyb2 = i.y - k3 * i.x;
    Point<double> p =
        Point((yyb2 - yyb1) / (k1 - k3), (yyb2 - yyb1) / (k1 - k3) * k1 + yyb1);

    ///下边阴影起始位置
    Point<double> pysx =
        Point((b1 - yyb2) / (k3 - k1), (b1 - yyb2) / (k3 - k1) * k3 + yyb2);

    ///上班边阴影起始位置
    Point<double> pyss =
        Point((b3 - yyb1) / (k1 - k3), (b3 - yyb1) / (k1 - k3) * k1 + yyb1);

    return Position(
      a: a,
      f: f,
      g: g,
      e: e,
      h: h,
      c: c,
      j: j,
      b: b,
      k: k,
      d: d,
      i: i,
      p: p,
      pyss: pyss,
      pysx: pysx,
      touchPt: touchPt,
      backPt: backPt,
      jA: jA,
    );
  }

  //获取绘制路径
  static Path getPaint(Position pt, Size size) {
    Path _path = Path();

    if (pt.touchPt == TouchPt.touchTop) {
      _path
        ..moveTo(0, 0)
        ..lineTo(pt.c.x, pt.c.y)
        ..quadraticBezierTo(pt.e.x, pt.e.y, pt.b.x, pt.b.y)
        ..lineTo(pt.a.x, pt.a.y)
        ..lineTo(pt.k.x, pt.k.y)
        ..quadraticBezierTo(pt.h.x, pt.h.y, pt.j.x, pt.j.y)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      return _path;
    }
    _path
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(pt.j.x, pt.j.y)
      ..quadraticBezierTo(pt.h.x, pt.h.y, pt.k.x, pt.k.y)
      ..lineTo(pt.a.x, pt.a.y)
      ..lineTo(pt.b.x, pt.b.y)
      ..quadraticBezierTo(pt.e.x, pt.e.y, pt.c.x, pt.c.y)
      ..lineTo(0, size.height)
      ..close();
    return _path;
  }

  /// 两点求直线方程 斜率 和 b
  static double towPointKb(Point<double> p1, Point<double> p2,
      {bool isK = true}) {
    double k = 0;
    double b = 0;

    if (p1.x == p2.x) {
      k = (p1.y - p2.y) / (p1.x - p2.x - 1);
    } else {
      k = (p1.y - p2.y) / (p1.x - p2.x);
    }
    b = p1.y - k * p1.x;
    if (isK) {
      return k;
    } else {
      return b;
    }
  }
}

class Position {
  ///手指拖拽坐标
  Point<double> a;

  ///顶点坐标
  Point<double> f;

  ///顶点坐标与手指拖拽左边的中点
  Point<double> g;

  ///二阶贝塞尔曲线 的控制点  （书页底部）
  Point<double> e;

  ///二阶贝塞尔曲线 的控制点 （书页右侧）
  Point<double> h;

  ///书页与屏幕交点 底部
  Point<double> c;

  ///书页与屏幕交点 右侧
  Point<double> j;

  ///贝塞尔曲线的开始点 与结束点
  Point<double> b;
  Point<double> k;

  ///贝塞尔曲线的 顶点
  Point<double> d;
  Point<double> i;

  ///阴影参考坐标
  Point<double> p;

  ///下边阴影起始位置
  Point<double> pysx;

  ///上班边阴影起始位置
  Point<double> pyss;

  ///触摸位置
  TouchPt touchPt;

  ///
  Point<double> backPt;

  var jA;

  Position({
    this.a = const Point(0, 0),
    this.f = const Point(0, 0),
    this.g = const Point(0, 0),
    this.e = const Point(0, 0),
    this.h = const Point(0, 0),
    this.c = const Point(0, 0),
    this.j = const Point(0, 0),
    this.b = const Point(0, 0),
    this.k = const Point(0, 0),
    this.d = const Point(0, 0),
    this.i = const Point(0, 0),
    this.p = const Point(0, 0),
    this.pyss = const Point(0, 0),
    this.pysx = const Point(0, 0),
    this.touchPt = TouchPt.noTouch,
    this.backPt = const Point(0, 0),
    this.jA = 0.0,
  });
}

enum TouchPt {
  noTouch,
  touchTop,
  touchCenter,
  touchBottom,
}

///绘制仿真页
class SimulationPagePath extends CustomPainter {
  /// 坐标位置
  Position pt;

  SimulationPagePath(
    this.pt,
  );

  //当前页 笔画
  final Paint _paint = Paint()
    ..color = Colors.transparent
    ..style = PaintingStyle.fill
    ..strokeWidth = 3;

  //当前页的背面笔画
  final Paint _paint1 = Paint()
    ..color = Color.fromARGB(255, 236, 215, 184)
    ..style = PaintingStyle.fill
    ..strokeWidth = 3;

  // 阴影笔画
  final Paint _paint2 = Paint()
    ..style = PaintingStyle.fill
    ..strokeWidth = 3;

  @override
  Path paint(Canvas canvas, Size size) {
    /// 绘制当前页面的正面 的路径
    Path _path = Path();
    //此刻为手指 未拖拽时
    if (pt.a.x == 0 && pt.a.y == 0) {
      _path
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(_path, _paint);
      return _path;
    }

    _path = MathTool.getPaint(pt, size);

    canvas.drawPath(_path, _paint);

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

    canvas.drawPath(mPathB, _paint1);

    /// 绘制  背面与 下一页 的交界处的阴影
    Path pr = Path()
      ..moveTo(pt.c.x, pt.c.y)
      ..lineTo(pt.j.x, pt.j.y)
      ..lineTo(pt.h.x, pt.h.y)
      ..lineTo(pt.e.x, pt.e.y)
      ..close();
    Path p1 = Path.combine(PathOperation.intersect, pr, pathAB);
    Path p2 = Path.combine(PathOperation.difference, p1, mPathB);
    canvas.drawPath(
        p2,
        _paint2
          ..shader = ui.Gradient.linear(
            Offset(pt.a.x, pt.a.y),
            Offset(pt.g.x, pt.g.y),
            [Colors.black, Colors.transparent],
          ));

    ///当前页下边阴影
    Path pyx = Path()
      ..moveTo(pt.a.x, pt.a.y)
      ..lineTo(pt.p.x, pt.p.y)
      ..lineTo(pt.d.x, pt.d.y)
      ..lineTo(pt.e.x, pt.e.y)
      ..close();
    Path p3 = Path.combine(PathOperation.intersect, pyx, _path);
    canvas.drawPath(
        p3,
        _paint2
          ..shader = ui.Gradient.linear(
            Offset(pt.pysx.x, pt.pysx.y),
            Offset(pt.p.x, pt.p.y),
            [Color.fromARGB(31, 0, 0, 0), Color.fromARGB(0, 0, 0, 0)],
          ));

    ///当前页上边阴影
    Path pys = Path()
      ..moveTo(pt.a.x, pt.a.y)
      ..lineTo(pt.p.x, pt.p.y)
      ..lineTo(pt.i.x, pt.i.y)
      ..lineTo(pt.h.x, pt.h.y)
      ..close();
    Path p4 = Path.combine(PathOperation.intersect, pys, _path);
    canvas.drawPath(
        p4,
        _paint2
          ..shader = ui.Gradient.linear(
            Offset(pt.pyss.x, pt.pyss.y),
            Offset(pt.p.x, pt.p.y),
            [Color.fromARGB(31, 0, 0, 0), Color.fromARGB(0, 0, 0, 0)],
          ));
    return _path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return this != oldDelegate;
  }
}

///剪切书页 ，达到翻页覆盖文字的效果
class MyClipper extends CustomClipper<Path> {
  /// 坐标位置
  Position pt;
  MyClipper(
    this.pt,
  );
  @override
  Path getClip(Size size) {
    Path _path = Path();
    // 此刻为手指 未拖拽时
    if (pt.a.x == 0 && pt.a.y == 0) {
      _path
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      return _path;
    }

    _path = MathTool.getPaint(pt, size);

    return _path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

///手指开始触摸时的方向
enum StartTouchDirection {
  noTouch,
  ltr, //从左向右
  rtl, //从右向左
}
