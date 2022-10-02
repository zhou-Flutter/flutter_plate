import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_plate/download/download_factory.dart';
import 'package:flutter_plate/download/progress_button.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import 'event_bus.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({Key? key}) : super(key: key);

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  DownloadManager downloadManager = DownloadManager(); //下载管理

  List<Download> downloadList = []; //下载列表

  List list = [
    {
      "name": "QQ",
      "url":
          "https://b06acb9f625f0544b9a467ac5ac7f9d9c44375832a6b7b6d.dlied1.cdntips.net/downv6.qq.com/qqweb/QQ_1/android_apk/Android_8.9.13.9280_537137212_64.apk?mkey=6338039a00002f9d&f=0f1e&cip=2408:8266:1:24:456d:19bf:b8a8:332b&proto=https&access_type="
    },
    {
      "name": "微信",
      "url":
          "https://3da9ef7cf39b657465361c737e97908c.dlied1.cdntips.net/dldir1.qq.com/weixin/android/weixin8028android2240_arm64.apk?mkey=6339620265cc065e&f=9947&cip=101.204.32.171&proto=https"
    },
    {
      "name": "抖音",
      "url":
          "https://lf9-apk.ugapk.cn/package/apk/aweme/1015_220601/aweme_aweGW_v1015_220601_e795_1664314799.apk?v=1664314810"
    }
  ];
  @override
  void initState() {
    super.initState();

    eventBus.on<DownloadEvent>().listen((event) {
      if (mounted) {
        downloadList = event.downloadList;
        setState(() {});
      }
    });
  }

  //添加下载任务
  add() async {
    //获取路径 权限获取后续添加，先凑合的用
    Directory appDocDir = await getApplicationDocumentsDirectory();
    for (var item in list) {
      String appDocPath = '${appDocDir.path}/${item["name"]}.apk';
      downloadManager.addDownload(item["url"], appDocPath, item["name"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("断点续传 多任务下载")),
      body: Container(
        child: ListView.builder(
          itemCount: downloadList.length,
          itemBuilder: (BuildContext context, int index) {
            return downloadItem(downloadList[index]);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() {
          add();
        }),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget downloadItem(Download item) {
    var state = "";
    var progressState = "";
    switch (item.state) {
      case 0:
        state = "下载完成";
        progressState = "打开";
        break;
      case 1:
        state = "下载中";
        progressState = "${item.progress}%";
        break;
      case 2:
        state = "等待中";
        progressState = "${item.progress}%";
        break;
      case 3:
        state = "已暂停";
        progressState = "继续";
        break;
      case 4:
        state = "下载异常";
        progressState = "重试";
        break;
      default:
    }

    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: Colors.blue, borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.home_repair_service),
          ),
          progressDes(item, state),
          Spacer(),
          ProgressButton(
            height: 35,
            width: 80,
            progress: item.progress!,
            text: progressState,
            borderRadius: 13,
            textStyle: TextStyle(
              color: Colors.blue,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            onTap: () {
              switch (item.state) {
                case 0:
                  //下载完成
                  OpenFile.open(item.savePath);
                  break;
                case 1:
                  //下载中 点击可暂停
                  downloadManager.cancelDownload(item.slot!);
                  break;
                case 2:
                  //等待中 点击可暂停
                  downloadManager.cancelWaiting(item.uri!);
                  break;
                case 3:
                  //暂停中 点击可继续 恢复下载
                  downloadManager.resumeDownload(item.uri!);
                  break;
                case 4:
                  //TODO 下载异常 删除重试
                  break;
                default:
              }
            },
          ),
        ],
      ),
    );
  }

  //进度详情
  Widget progressDes(Download item, state) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text(
              "${item.fileName}",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
          ),
          Row(
            children: [
              item.state == 1
                  ? Text(
                      "${formatFileSize(item.received ?? 0)}/${formatFileSize(item.total ?? 0)}",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    )
                  : Container(),
              Text(
                state,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  String formatFileSize(int fileSize) {
    var size = (fileSize / 1048576).toStringAsFixed(1);
    return "$size MB";
  }
}
