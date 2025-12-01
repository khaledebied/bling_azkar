import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  final Dio _dio = Dio();
  final Map<String, CancelToken> _activeCancelTokens = {};

  Future<String> downloadAudio({
    required String url,
    required String zikrId,
    required String sheikhId,
    required Function(double progress) onProgress,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${dir.path}/audio/$sheikhId');

      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }

      final fileName = '${zikrId}_$sheikhId.mp3';
      final filePath = '${audioDir.path}/$fileName';

      final cancelToken = CancelToken();
      _activeCancelTokens[zikrId] = cancelToken;

      await _dio.download(
        url,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            onProgress(progress);
          }
        },
      );

      _activeCancelTokens.remove(zikrId);
      return filePath;
    } catch (e) {
      _activeCancelTokens.remove(zikrId);
      print('Download error: $e');
      rethrow;
    }
  }

  Future<void> cancelDownload(String zikrId) async {
    final cancelToken = _activeCancelTokens[zikrId];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel();
      _activeCancelTokens.remove(zikrId);
    }
  }

  Future<void> deleteAudio(String localPath) async {
    try {
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Delete error: $e');
      rethrow;
    }
  }

  Future<int> getAudioFileSize(String localPath) async {
    try {
      final file = File(localPath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> getTotalDownloadedSize() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${dir.path}/audio');

      if (!await audioDir.exists()) {
        return 0;
      }

      int totalSize = 0;
      await for (final entity in audioDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }

      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  Future<void> clearAllDownloads() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${dir.path}/audio');

      if (await audioDir.exists()) {
        await audioDir.delete(recursive: true);
      }
    } catch (e) {
      print('Clear all downloads error: $e');
      rethrow;
    }
  }
}
