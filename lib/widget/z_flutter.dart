import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:zflutter/zflutter.dart';

class ZFlutterUse extends StatefulWidget {
  const ZFlutterUse({Key? key}) : super(key: key);

  @override
  State<ZFlutterUse> createState() => _ZFlutterUseState();
}

class _ZFlutterUseState extends State<ZFlutterUse> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("zFlutter 的使用")),
      body: ZDragDetector(
        builder: (context, controller) {
          return ZIllustration(
            zoom: 1,
            children: [
              ZPositioned(
                rotate: controller.rotate,
                child: ZGroup(
                  children: [
                    screen(),
                    base(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

//屏幕
ZPositioned screen() => ZPositioned(
    // rotate: ZVector.only(x: tau / 4, z: -tau / 4),
    translate: ZVector.only(y: -40),
    child: ZGroup(
      children: [
        ZPositioned(
          translate: ZVector.only(x: 0, z: 1),
          child: ZToBoxAdapter(
            height: 95,
            width: 155,
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(2)),
              child: Text(
                "code...",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        ZShape(
          path: [
            ZMove.only(x: -80, y: -50),
            ZLine.only(x: -80, y: 50),
            ZLine.only(x: 80, y: 50),
            ZLine.only(x: 80, y: -50),
          ],
          fill: true,
          stroke: 10,
          color: Color.fromARGB(255, 54, 53, 53),
        ),
      ],
    ));

//底座
ZPositioned base() => ZPositioned(
    rotate: ZVector.only(x: tau / 4),
    translate: ZVector.only(y: 40),
    child: ZGroup(
      children: [
        ZEllipse(
          width: 70,
          height: 60,
          stroke: 10,
          fill: true,
          color: Color.fromARGB(255, 54, 53, 53),
        ),
        ZPositioned(
          rotate: ZVector.only(x: tau / 5),
          translate: ZVector.only(y: -20, z: 40),
          child: ZShape(
            path: [
              ZMove.only(x: -10, y: -40),
              ZLine.only(x: -10, y: 40),
              ZLine.only(x: 10, y: 40),
              ZLine.only(x: 10, y: -40),
            ],
            fill: true,
            stroke: 10,
            color: Color.fromARGB(255, 148, 144, 148),
          ),
        )
      ],
    ));
