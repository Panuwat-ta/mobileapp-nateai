import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/result.dart';

final sttServiceProvider = Provider<STTService>((ref) {
  return STTService();
});

class STTService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;

  bool get isListening => _speechToText.isListening;

  Future<Result<bool>> initialize() async {
    try {
      if (!_isInitialized) {
        // initialize STT
        _isInitialized = await _speechToText.initialize(
          onError: (val) => debugPrint('STT Error: ${val.errorMsg}'),
          onStatus: (val) => debugPrint('STT Status: $val'),
        );
      }
      if (!_isInitialized) {
        return const Failure('Speech recognition not available or permission denied');
      }

      var locales = await _speechToText.locales();
      debugPrint('Available locales: ${locales.map((l) => l.localeId).toList()}');
      
      return Success(_isInitialized);
    } catch (e, st) {
      return Failure('Failed to initialize STT Engine', e, st);
    }
  }

  Future<Result<void>> startListening(Function(String) onResult) async {
    try {
      if (!_isInitialized) {
        final initResult = await initialize();
        if (initResult is Failure) return Failure((initResult as Failure).message);
      }
      await _speechToText.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
        },
        listenOptions: SpeechListenOptions(
          partialResults: true,
          localeId: 'th_TH',
          listenFor: const Duration(minutes: 60),
          pauseFor: const Duration(seconds: 10),
          listenMode: ListenMode.dictation,
        ),
      );
      return const Success(null);
    } catch (e, st) {
      return Failure('Failed to start listening', e, st);
    }
  }
  
  Future<Result<void>> stopListening() async {
    try {
      await _speechToText.stop();
      return const Success(null);
    } catch (e, st) {
      return Failure('Failed to stop STT', e, st);
    }
  }
}
