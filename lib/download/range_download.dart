import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class RangeDownload {
  CancelToken cancelToken = CancelToken();

  Future<void> download({
    required String url,
    required String savePath,
    ProgressCallback? onReceiveProgress,
    void Function(Uri)? done,
    void Function(Exception, Uri)? failed,
    void Function(Uri)? cancel,
  }) async {
    int downloadStart = 0;

    File f = File(savePath);
    if (await f.exists()) {
      downloadStart = f.lengthSync();
    } else {
      downloadStart = 0;
    }

    var dio = Dio();

    try {
      var response = await dio.get<ResponseBody>(
        url,
        cancelToken: cancelToken,
        options: Options(
          /// 以流的方式接收响应数据
          responseType: ResponseType.stream,
          followRedirects: false,
          headers: {
            "range": "bytes=$downloadStart-",
          },
        ),
      );

      File file = File(savePath);
      RandomAccessFile raf = file.openSync(mode: FileMode.append);
      int received = downloadStart;
      int total = await _getContentLength(response);
      Stream<Uint8List> stream = response.data!.stream;
      StreamSubscription<Uint8List>? subscription;
      subscription = stream.listen(
        (data) {
          /// 写入文件必须同步
          raf.writeFromSync(data);
          received += data.length;
          onReceiveProgress?.call(received, total);
        },
        onDone: () async {
          //下载完毕，关闭文件流，并将下载任务移除
          await raf.close();
          done?.call(Uri(path: url));
        },
        onError: (e) async {
          //下载失败，关闭文件流
          await raf.close();
          failed?.call(e, Uri(path: url));
        },
        cancelOnError: true,
      );
      cancelToken.whenCancel.then((_) async {
        //下载中断，用户暂停

        await subscription?.cancel();
        await raf.close();
        cancel?.call(Uri(path: url));
      });
    } on DioError catch (error) {
      print(error);

      if (CancelToken.isCancel(error)) {
        print("下载取消");
      } else {
        failed?.call(error, Uri(path: url));
      }
    }
  }

  /// 获取下载的文件大小
  static Future<int> _getContentLength(Response<ResponseBody> response) async {
    try {
      var headerContent =
          response.headers.value(HttpHeaders.contentRangeHeader);
      if (headerContent != null) {
        return int.parse(headerContent.split('/').last);
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  //取消请求
  clean() {
    cancelToken.cancel();
  }
}
