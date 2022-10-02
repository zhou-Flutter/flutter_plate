import 'package:event_bus/event_bus.dart';
import 'package:flutter_plate/download/download_factory.dart';

EventBus eventBus = new EventBus();

//下载
class DownloadEvent {
  List<Download> downloadList;

  DownloadEvent(this.downloadList);
}
