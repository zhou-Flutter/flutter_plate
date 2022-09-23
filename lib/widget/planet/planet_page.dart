import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_plate/widget/planet/planet.dart';

class PlanetPage extends StatefulWidget {
  const PlanetPage({Key? key}) : super(key: key);

  @override
  State<PlanetPage> createState() => _PlanetPageState();
}

class _PlanetPageState extends State<PlanetPage> {
  List item = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for (int i = 0; i < 50; i++) {
      item.add(i);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("仿soul 星球特效")),
      body: Center(
        child: Planet(
          children: item.map((e) {
            Color color = Color.fromRGBO(Random().nextInt(256),
                Random().nextInt(256), Random().nextInt(256), 1);
            return Container(
              width: 30,
              height: 50,
              child: Column(
                children: [
                  Text("$e"),
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(50),
                    ),
                  )
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
