import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_plate/simulation_book/currentpage_back.dart';

import 'dart:ui' as ui;

import 'package:flutter_plate/simulation_book/tool/math_tool.dart';
import 'package:flutter_plate/simulation_book/tool/single_touch_recognizer.dart';

class Read extends StatefulWidget {
  Read({
    Key? key,
  }) : super(key: key);

  @override
  State<Read> createState() => _ReadState();
}

class _ReadState extends State<Read> with SingleTickerProviderStateMixin {
  Point<double> details = Point(0, 0); //拖拽中的坐标

  Point<double> endtouchPt = Point(0, 0); // 拖拽结束的坐标

  Point<double> startTouchPt = Point(0, 0); //开始触摸前的坐标 相当于手指刚按下

  Point<double> touchFirst = Point(0, 0); //拖拽是第一个左边，用来判断开始是右滑 还是左滑

  late Position pt = Position(); // 拖拽是的个个坐标与有关的参数

  TouchPt touchPt = TouchPt.noTouch; //触摸位置 类型

  StartTouchDirection startTouchDirection =
      StartTouchDirection.noTouch; //开始触摸时的方向

  late Point<double> f; //顶点坐标

  late final AnimationController _controller;

  late Animation<double> animation;

  //是否有动画正在播放
  bool isAnimating = false;

  ///是否时翻页动画  (翻页true  回弹false )
  bool trueAnimate = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    _controller =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);

    animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        double animateValue = animation.value;
        if (startTouchDirection == StartTouchDirection.ltr) {
          details = mbAnimateData(animateValue);
        } else {
          switch (touchPt) {
            case TouchPt.touchTop:
              details = tAnimateData(animateValue);
              break;
            case TouchPt.touchCenter:
              details = mbAnimateData(animateValue);
              break;
            case TouchPt.touchBottom:
              details = mbAnimateData(animateValue);
              break;
            default:
          }
        }

        pt = MathTool.coordinate(details, f, touchPt);
        setState(() {});
      });
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();

        details = Point(0, 0);
        touchFirst = Point(0, 0);
        pt = MathTool.coordinate(details, f, touchPt);
        touchPt = TouchPt.noTouch;
        startTouchDirection = StartTouchDirection.noTouch;
        isAnimating = false;
      }
    });
  }

  // 中间或低部卷起后 的 动画数据
  Point<double> mbAnimateData(animateValue) {
    if (trueAnimate) {
      double x = endtouchPt.x +
          (-MediaQuery.of(context).size.width - 0.01 - endtouchPt.x) *
              animateValue;
      double y = endtouchPt.y +
          (MediaQuery.of(context).size.height - 0.01 - endtouchPt.y) *
              animateValue;
      return Point(x, y);
    } else {
      double x = endtouchPt.x +
          (MediaQuery.of(context).size.width - 0.01 - endtouchPt.x) *
              animateValue;
      double y = endtouchPt.y +
          (MediaQuery.of(context).size.height - 0.01 - endtouchPt.y) *
              animateValue;
      return Point(x, y);
    }
  }

  // 中间或低部卷起后 的 动画数据
  Point<double> tAnimateData(animateValue) {
    if (trueAnimate) {
      double x = endtouchPt.x +
          (-MediaQuery.of(context).size.width - 0.01 - endtouchPt.x) *
              animateValue;
      double y = endtouchPt.y + (-endtouchPt.y) * animateValue;
      return Point(x, y);
    } else {
      double x = endtouchPt.x +
          (MediaQuery.of(context).size.width - 0.01 - endtouchPt.x) *
              animateValue;
      double y = endtouchPt.y + (-endtouchPt.y) * animateValue;
      return Point(x, y);
    }
  }

  //拖拽开始
  onPanDown(DragDownDetails e) {
    startTouchPt = Point(e.localPosition.dx, e.localPosition.dy);

    Point<double> f = Point(
        MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
    if (startTouchPt.y < f.y / 3) {
      touchPt = TouchPt.touchTop;
    } else if (startTouchPt.y < f.y / 3 * 2) {
      touchPt = TouchPt.touchCenter;
    } else if (startTouchPt.y < f.y) {
      touchPt = TouchPt.touchBottom;
    }
  }

  //手指拖拽
  onPanUpdate(DragUpdateDetails e) {
    if (isAnimating) {
      return;
    }

    if (touchFirst.x == 0 && touchFirst.y == 0) {
      touchFirst = Point(e.localPosition.dx, e.localPosition.dy);
    }

    if (touchFirst.x - startTouchPt.x > 0) {
      //手势开始滑动时是右滑
      if (startTouchDirection == StartTouchDirection.noTouch) {
        touchPt = TouchPt.noTouch;
        startTouchDirection = StartTouchDirection.ltr;
      }

      if (details.x != 0) {
        if (e.localPosition.dx - details.x > 0) {
          if (e.localPosition.dx - details.x > 1) {
            //书页是回弹
            trueAnimate = false;
          }
        } else if (e.localPosition.dx - details.x < 0) {
          if (e.localPosition.dx - details.x < -1) {
            //书页是翻页
            trueAnimate = true;
          }
        }
      }
      f = Point(MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height);
      details =
          Point(e.localPosition.dx, MediaQuery.of(context).size.height - 0.01);
    } else {
      //手势开始滑动时是左滑

      if (startTouchDirection == StartTouchDirection.noTouch) {
        startTouchDirection = StartTouchDirection.rtl;
      }
      if (details.x != 0) {
        if (e.localPosition.dx - details.x > 0) {
          if (e.localPosition.dx - details.x > 1) {
            //书页是回弹
            trueAnimate = false;
          }
        } else if (e.localPosition.dx - details.x < 0) {
          if (e.localPosition.dx - details.x < -1) {
            //书页是翻页
            trueAnimate = true;
          }
        }
      }
      details = Point(e.localPosition.dx, e.localPosition.dy);
      switch (touchPt) {
        case TouchPt.touchTop:
          f = Point(MediaQuery.of(context).size.width, 0);
          break;
        case TouchPt.touchCenter:
          f = Point(MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height);
          details = Point(
              e.localPosition.dx, MediaQuery.of(context).size.height - 0.01);
          break;
        case TouchPt.touchBottom:
          f = Point(MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height);
          break;
        default:
      }
    }

    pt = MathTool.coordinate(details, f, touchPt, constraint: true);

    setState(() {});
  }

  //拖拽结束
  onPanEnd(DragEndDetails e) {
    if (isAnimating) {
      return;
    }
    endtouchPt = pt.a;
    isAnimating = true;
    _controller.forward();
    touchFirst = Point(0, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            child: readPage(),
          ),
          Positioned(
            child: GestureDetector(
              onTapDown: (e) {
                print("onTapDown");
              },
              onTapUp: (e) {
                print("onTapUp");
              },
              onPanDown: onPanDown,
              onPanUpdate: onPanUpdate,
              onPanEnd: onPanEnd,
              child: SingleTouchRecognizerWidget(
                child: CustomPaint(
                  foregroundPainter: SimulationPagePath(pt),
                  willChange: true,
                  child: ClipPath(
                    clipper: MyClipper(pt),
                    child: readPage(),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            child: CurrentPageBack(
              pt: pt,
              touchPt: touchPt,
              pageBack: readPage(),
            ),
          ),
        ],
      ),
    );
  }

  Widget readPage() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Color.fromARGB(255, 236, 215, 184),
      child: Center(
        child: Text(
          "模拟小说仿真翻页效果",
          style: TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}
