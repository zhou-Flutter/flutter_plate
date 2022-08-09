import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class SnowFlakePage extends StatefulWidget {
  SnowFlakePage({Key? key}) : super(key: key);

  @override
  _SnowFlakePageState createState() => _SnowFlakePageState();
}

class _SnowFlakePageState extends State<SnowFlakePage>
    with WidgetsBindingObserver {
  int cont = 1;
  late Timer timer;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    getxuehua();
  }

  getxuehua() {
    timer = Timer(Duration(milliseconds: 50), () {
      if (cont < 600) {
        cont++;
        getxuehua();
        setState(() {});
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        //后台到前台
        cont = 1;
        setState(() {});
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        // 前台到后台
        break;
      case AppLifecycleState.detached:
        // TODO: Handle this case.
        break;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("雪花效果"),
      ),
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
            ...List.generate(
              cont,
              (index) => Stars(),
            ),
          ],
        ),
      ),
    );
  }
}

class Stars extends StatefulWidget {
  Stars({Key? key}) : super(key: key);

  @override
  _StarsState createState() => _StarsState();
}

class _StarsState extends State<Stars> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;

  double? x;
  //雪花大小
  int? w;
  double? h;
  double? f;

  bool isshow = false;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
    );
    reset();

    _animationController!.forward(from: 0.0);
    _animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        reset();
        _animationController!.forward(from: 0.0);
      }
    });
  }

  reset() {
    w = Random().nextInt(15);
    h = Random().nextDouble() + 1;
    x = Random().nextDouble() * 400;
    _animationController!.duration = Duration(seconds: Random().nextInt(5) + 5);
    // color = Colors.primaries[Random().nextInt(Colors.primaries.length)][200];
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _animationController!.stop();
    _animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController!,
      builder: (context, child) {
        return Positioned(
          left: x,
          top: MediaQuery.of(context).size.height * _animationController!.value,
          child: Container(
            decoration: BoxDecoration(),
            child: RotationTransition(
              turns: _animationController!,
              child: Icon(
                Icons.ac_unit,
                color: Colors.white,
                size: w!.toDouble(),
              ),
            ),
          ),
        );
      },
    );
  }
}
