import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archive/archive_io.dart';

enum ModelType { qwen, whisper }

final modelDownloadServiceProvider = Provider<ModelDownloadService>((ref) {
  return ModelDownloadService();
});

class ModelDownloadService {
  final Dio _dio = Dio();
  static const String _qwenUrl = 'https://huggingface.co/Qwen/Qwen3-1.7B-GGUF/resolve/main/Qwen3-1.7B-Q8_0.gguf?download=true';
  static const String _qwenFileName = 'Qwen3-1.7B-Q8_0.gguf';
  
  static const String _whisperUrl = 'https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.bin?download=true';
  static const String _whisperFileName = 'ggml-base.bin';
  
  CancelToken? _cancelToken;

  Future<String?> getDownloadedModelPath(ModelType type) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (type == ModelType.qwen) {
      final path = prefs.getString('local_model_path');
      if (path != null && File(path).existsSync()) return path;
    } else if (type == ModelType.whisper) {
      final path = prefs.getString('whisper_model_path');
      if (path != null && File(path).existsSync()) return path;
    }
    return null;
  }

  Future<void> downloadModel({
    required ModelType type,
    required Function(int received, int total) onReceiveProgress,
    required Function(String path) onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      _cancelToken = CancelToken();
      final dir = type == ModelType.qwen 
          ? await getApplicationDocumentsDirectory()
          : await getApplicationSupportDirectory();
      
      final url = type == ModelType.qwen ? _qwenUrl : _whisperUrl;
      final fileName = type == ModelType.qwen ? _qwenFileName : _whisperFileName;
      final savePath = '${dir.path}/$fileName';

      // Check if already downloaded
      if (type == ModelType.qwen && File(savePath).existsSync()) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('local_model_path', savePath);
        onSuccess(savePath);
        return;
      } else if (type == ModelType.whisper) {
        if (File(savePath).existsSync()) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('whisper_model_path', savePath);
          onSuccess(savePath);
          return;
        }
      }

      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: _cancelToken,
        options: Options(
          headers: {
            'Accept-Encoding': 'gzip, deflate, br',
            'Connection': 'keep-alive',
          },
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      
      if (type == ModelType.qwen) {
        await prefs.setString('local_model_path', savePath);
        onSuccess(savePath);
      } else if (type == ModelType.whisper) {
        await prefs.setString('whisper_model_path', savePath);
        onSuccess(savePath);
      }
      
    } catch (e) {
      if (_cancelToken?.isCancelled == true || e is DioException && CancelToken.isCancel(e)) {
        onError('Download canceled');
      } else {
        onError('Download failed: $e');
      }
    }
  }

  void cancelDownload() {
    _cancelToken?.cancel('User canceled download');
  }
}
