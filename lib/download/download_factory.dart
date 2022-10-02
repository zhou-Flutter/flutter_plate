import 'dart:io';

import 'package:flutter_plate/download/event_bus.dart';
import 'package:flutter_plate/download/range_download.dart';

//工厂模式 下载管理
class DownloadManager {
  static final DownloadManager _downloadManager = DownloadManager._internal();

  factory DownloadManager() {
    return _downloadManager;
  }

  ///构造函数私有化，防止被误创建
  DownloadManager._internal();

  int maxTask = 2; //同时下载任务数

  List<Download> downloadList = []; //下载列表

  List<RangeDownload> downloadSlot = []; //下载槽

  ///添加下载
  void addDownload(url, savePath, fileName) async {
    if (downloadSlot.length < maxTask) {
      //初始化下载器 添加到下载槽列表， 先这样 还可添加如果正在下载中的判断，阻止多次添加下载
      RangeDownload rangeDownload = RangeDownload();
      downloadSlot.add(rangeDownload);

      //添加到下载列表
      downloadList.add(Download(
        uri: Uri(path: url),
        fileName: fileName,
        url: url,
        savePath: savePath,
        progress: 0,
        slot: rangeDownload,
        state: 1,
      ));

      //进入下载
      download(url, savePath, rangeDownload);
    } else {
      //下载槽满了，加入等待队列
      downloadList.add(Download(
        uri: Uri(path: url),
        fileName: fileName,
        url: url,
        savePath: savePath,
        progress: 0,
        state: 2,
      ));

      eventBus.fire(DownloadEvent(downloadList));
    }
  }

  download(url, savePath, RangeDownload rangeDownload) async {
    await rangeDownload.download(
      url: url,
      savePath: savePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          ///当前下载的百分比例
          double progress =
              double.parse((received / total * 100).toStringAsFixed(1));

          check(Uri(path: url), (Download item) {
            //修改下载完成
            item.state = 1;
            item.progress = progress;
            item.received = received;
            item.total = total;
            //通知页面
            eventBus.fire(DownloadEvent(downloadList));
          });
        }
      },
      done: (uri) {
        //下载完成
        check(uri, (Download item) {
          item.state = 0;
          downloadSlot.remove(item.slot);
          eventBus.fire(DownloadEvent(downloadList));
        });
        checkWaitingQueue();
      },
      failed: (e, uri) {
        //失败
        check(uri, (Download item) {
          item.state = 4;
          downloadSlot.remove(item.slot);
          eventBus.fire(DownloadEvent(downloadList));
        });
        checkWaitingQueue();
      },
      cancel: (uri) {
        //取消下载
        check(uri, (Download item) {
          item.state = 3;
          downloadSlot.remove(item.slot);
          eventBus.fire(DownloadEvent(downloadList));
        });
        checkWaitingQueue();
      },
    );
  }

  //检查是否有等待队列 有就开始下载 先弄成从头开始检查 先凑合用
  void checkWaitingQueue() {
    for (Download item in downloadList) {
      if (item.state == 2) {
        resumeDownload(item.uri!);
        break;
      }
    }
  }

  //检查数据
  void check(uri, Function checkBack) {
    for (Download item in downloadList) {
      if (item.uri == uri) {
        checkBack(item);
        break;
      }
    }
  }

  ///恢复下载
  void resumeDownload(Uri uri) {
    if (downloadSlot.length < maxTask) {
      //还有下载槽
      RangeDownload rangeDownload = RangeDownload();
      downloadSlot.add(rangeDownload);

      check(uri, (Download item) {
        item.slot = rangeDownload;
        download(item.url, item.savePath, rangeDownload);
      });
    } else {
      //下载槽满了，加入等待队列
      check(uri, (Download item) {
        item.state = 2;
        eventBus.fire(DownloadEvent(downloadList));
      });
    }
  }

  ///取消下载
  void cancelDownload(RangeDownload rangeDownload) {
    rangeDownload.clean();
  }

  ///取消等待
  void cancelWaiting(Uri uri) {
    check(uri, (Download item) {
      item.state = 3;
      eventBus.fire(DownloadEvent(downloadList));
    });
  }

  ///删除下载
  void deleteDownload(Uri uri) async {
    for (int i = 0; i < downloadList.length; i++) {
      if (downloadList[i].uri == uri) {
        if (downloadList[i].state == 1) {
          cancelDownload(downloadList[i].slot!);
        }
        downloadList.removeAt(i);

        eventBus.fire(DownloadEvent(downloadList));

        File file = File(downloadList[i].savePath!);

        if (file.existsSync()) {
          await file.delete();
        }
      }
    }
  }
}

class Download {
  //资源唯一标识
  Uri? uri;

  ///文件名字
  String? fileName;

  ///下载链接
  String? url;

  ///保存的路径
  String? savePath;

  ///下载状态: 0 下载完成 1 下载中，2 等待中，3 暂停，4,下载失败
  int? state;

  ///总量
  int? total;

  ///进度
  double? progress;

  ///已接受的量
  int? received;

  ///正在的下载槽位
  RangeDownload? slot;

  Download({
    this.uri,
    this.fileName,
    this.url,
    this.savePath,
    this.state,
    this.total,
    this.progress,
    this.received,
    this.slot,
  });
}
