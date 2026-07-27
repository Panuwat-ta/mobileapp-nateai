import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:whisper_ggml/whisper_ggml.dart';
import 'package:record/record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/result.dart';
import '../ai/model_download_service.dart';

final sttServiceProvider = Provider<STTService>((ref) {
  final downloadService = ref.watch(modelDownloadServiceProvider);
  return STTService(downloadService);
});

class STTService {
  final ModelDownloadService _downloadService;
  STTService(this._downloadService);

  final WhisperController _whisperController = WhisperController();
  final AudioRecorder _recorder = AudioRecorder();
  
  WhisperLiveSession? _liveSession;
  StreamSubscription? _partialSubscription;

  bool _isListening = false;
  bool get isListening => _isListening;

  Future<Result<bool>> initialize() async {
    try {
      final modelPath = await _downloadService.getDownloadedModelPath(ModelType.whisper);
      if (modelPath == null) {
        return const Failure('Whisper STT Model not found. Please download it first.');
      }
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        return const Failure('Microphone permission is required.');
      }
      return const Success(true);
    } catch (e, st) {
      debugPrint('STT Init Error: $e');
      return Failure('Failed to initialize STT Engine', e, st);
    }
  }

  Future<Result<void>> startListening(Function(String) onResult) async {
    try {
      if (_isListening) return const Success(null);

      final modelPath = await _downloadService.getDownloadedModelPath(ModelType.whisper);
      if (modelPath == null) {
        return const Failure('Whisper STT Model not found. Please download it first.');
      }

      final pcmStream = await _recorder.startStream(const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      ));

      // whisper_ggml requires the model to be in getApplicationSupportDirectory
      // We must ensure the model is copied there if it's currently in Documents
      final targetPath = await WhisperController().getPath(WhisperModel.base);
      if (!File(targetPath).existsSync() && File(modelPath).existsSync()) {
        await File(modelPath).copy(targetPath);
      }

      _liveSession = await _whisperController.transcribeLive(
        model: WhisperModel.base,
        pcm16Stream: pcmStream,
        lang: 'th',
        suppressNonSpeechTokens: true,
      );

      _partialSubscription = _liveSession?.partials.listen((text) {
        if (text.isNotEmpty) {
          onResult(text);
        }
      }, onError: (e) {
        debugPrint("STT Error: $e");
      });

      _isListening = true;
      return const Success(null);
    } catch (e, st) {
      return Failure('Failed to start listening', e, st);
    }
  }
  
  Future<Result<void>> stopListening() async {
    try {
      if (!_isListening) return const Success(null);
      _isListening = false;
      
      await _recorder.stop();
      _partialSubscription?.cancel();
      _partialSubscription = null;
      
      if (_liveSession != null) {
        await _liveSession!.stop();
        _liveSession = null;
      }
      
      return const Success(null);
    } catch (e, st) {
      return Failure('Failed to stop STT', e, st);
    }
  }
  
  void dispose() {
    _recorder.dispose();
    _partialSubscription?.cancel();
    _liveSession?.stop();
  }
}
