import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'record_state.dart';
import '../../../services/stt/stt_service.dart';
import '../../../services/llama/ai_pipeline_manager.dart';
import '../../../services/database/database_service.dart';
import '../../../utils/result.dart';

class RecordNotifier extends Notifier<RecordState> {
  String _currentTranscript = '';

  @override
  RecordState build() {
    return const Idle();
  }

  void startRecording() async {
    state = const Recording();
    final stt = ref.read(sttServiceProvider);
    
    try {
      if (await FlutterOverlayWindow.isPermissionGranted()) {
        await FlutterOverlayWindow.showOverlay(
          enableDrag: true,
          overlayTitle: "Live Caption",
          overlayContent: "Recording...",
          flag: OverlayFlag.defaultFlag,
          alignment: OverlayAlignment.bottomCenter,
          visibility: NotificationVisibility.visibilityPublic,
          positionGravity: PositionGravity.none,
        );
      }
    } catch (_) {}

    final result = await stt.startListening((text) {
      _currentTranscript = text;
      state = Recording(transcript: text);
      try {
        FlutterOverlayWindow.shareData(text);
      } catch (_) {}
    });
    
    if (result is Failure) {
      state = ErrorState(result.message);
      Future.delayed(const Duration(seconds: 2), () {
        if (state is ErrorState) {
          state = const Idle();
        }
      });
    }
  }

  void stopRecording() async {
    final stt = ref.read(sttServiceProvider);
    await stt.stopListening();
    
    try {
      FlutterOverlayWindow.closeOverlay();
    } catch (_) {}
    
    if (_currentTranscript.isEmpty) {
      state = const ErrorState('No speech detected. Please try again.');
      Future.delayed(const Duration(seconds: 2), () {
        state = const Idle();
      });
      return;
    }
    
    // Switch to idle but keep the transcript for review
    state = Idle(transcript: _currentTranscript);
  }

  void saveAndProcess() async {
    if (_currentTranscript.isEmpty) return;
    
    state = const AiProcessing();
    final pipeline = ref.read(aiPipelineProvider);
    
    final result = await pipeline.executePass1(_currentTranscript);
    
    if (result is Success<String>) {
      state = const Saving();
      
      final dbService = ref.read(databaseProvider);
      final db = await dbService.database;
      int noteId = await db.insert('notes', {
        'title': 'New Note',
        'raw_transcript': _currentTranscript,
        'summary_json': result.data,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
      
      await db.insert('notes_fts', {
        'rowid': noteId,
        'title': 'New Note',
        'raw_transcript': _currentTranscript,
        'summary_json': result.data,
      });

      pipeline.executePass2(_currentTranscript, result.data, noteId);
      
      state = const Completed();
      
      Future.delayed(const Duration(milliseconds: 500), () {
        state = Viewing(noteId);
      });
    } else {
      state = const ErrorState('AI processing failed. Saved as plain text.');
      Future.delayed(const Duration(seconds: 2), () {
        state = Idle(transcript: _currentTranscript);
      });
    }
  }
  
  void reset() {
    _currentTranscript = '';
    state = const Idle();
  }
}

final recordStateProvider = NotifierProvider<RecordNotifier, RecordState>(() {
  return RecordNotifier();
});
