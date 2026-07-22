import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/result.dart';

final sttServiceProvider = Provider<STTService>((ref) {
  return STTService();
});

class STTService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;

  Future<Result<bool>> initialize() async {
    try {
      if (!_isInitialized) {
        // initialize STT
        _isInitialized = await _speechToText.initialize();
      }
      return Success(_isInitialized);
    } catch (e, st) {
      return Failure('Failed to initialize STT Engine', e, st);
    }
  }

  Future<Result<void>> startListening(Function(String) onResult) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      await _speechToText.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
        },
        listenOptions: SpeechListenOptions(partialResults: true),
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
