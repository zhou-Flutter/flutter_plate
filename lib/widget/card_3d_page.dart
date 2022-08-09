import 'package:flutter/material.dart';

class Card3DPage extends StatefulWidget {
  Card3DPage({Key? key}) : super(key: key);

  @override
  State<Card3DPage> createState() => _Card3DPageState();
}

class _Card3DPageState extends State<Card3DPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late Animation<double> animation;

  //拖拽中的角度
  var touchX = 0.0;
  var touchY = 0.0;

  //开始拖拽的坐标
  var staX = 0.0;
  var staY = 0.0;

  //拖拽结束的角度
  var touchEndX = 0.0;
  var touchEndY = 0.0;

  bool isAnimate = false; //是否播放动画

  var limitAngle = 0.9; //限制拖拽角度

  int damping = 300; //拖拽阻尼

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    )..addListener(() {
        double animateValue = animation.value;
        setState(() {
          touchX = touchEndX - (touchEndX * animateValue);
          touchY = touchEndY - (touchEndY * animateValue);
        });
      });
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
        isAnimate = false;
        touchEndX = 0.0;
        touchEndY = 0.0;
        touchX = 0.0;
        touchY = 0.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("3D卡片"),
      ),
      body: Center(
        child: Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(touchY)
            ..rotateY(touchX),
          alignment: FractionalOffset.center,
          child: GestureDetector(
            onPanStart: (e) {
              staX = e.localPosition.dx;
              staY = e.localPosition.dy;
            },
            onPanUpdate: (details) {
              if (isAnimate) return;
              var angleX = (staX - details.localPosition.dx) / damping;
              var angleY = (details.localPosition.dy - staY) / damping;
              if (limitAngle == null) {
                touchX = angleX;
                touchY = angleY;
              } else {
                if (angleX < limitAngle && angleX > -limitAngle) {
                  touchX = angleX;
                }
                if (angleY < limitAngle && angleY > -limitAngle) {
                  touchY = angleY;
                }
              }
              setState(() {});
            },
            onPanEnd: (e) {
              if (touchX == 0 && touchY == 0) return;
              touchEndX = touchX;
              touchEndY = touchY;
              isAnimate = true;
              _controller.forward();
            },
            child: Container(
              width: 400,
              height: 250,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 25,
                    spreadRadius: -25,
                    offset: Offset(0, 30),
                  )
                ],
              ),
              child: const Text(
                "3D 卡片",
                style: TextStyle(color: Colors.black, fontSize: 30),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
