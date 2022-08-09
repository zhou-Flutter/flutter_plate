import 'package:flutter/material.dart';
import 'package:flutter_plate/widget/card_3d_page.dart';
import 'package:flutter_plate/widget/simulation_book/read.dart';
import 'package:flutter_plate/widget/snowflake_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PlateList(),
    );
  }
}

class PlateList extends StatefulWidget {
  PlateList({Key? key}) : super(key: key);

  @override
  State<PlateList> createState() => _PlateListState();
}

class _PlateListState extends State<PlateList> {
  List plate = [
    {"title": "3D卡片", "page": Card3DPage()},
    {"title": "下雪效果", "page": SnowFlakePage()},
    {"title": "仿真翻页", "page": Read()},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Plate")),
      body: ListView.builder(
        itemCount: plate.length,
        itemBuilder: (BuildContext context, int index) {
          return item(plate[index]);
        },
      ),
    );
  }

  Widget item(item) {
    return Card(
      child: ListTile(
        title: Text("${item["title"]}"),
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => item["page"]));
        },
      ),
    );
  }
}
