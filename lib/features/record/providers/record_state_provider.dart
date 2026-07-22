import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'record_state.dart';
import '../../../services/stt/stt_service.dart';
import '../../../services/llama/ai_pipeline_manager.dart';
import '../../../services/database/database_service.dart';
import '../../../utils/result.dart';
import '../../notes/providers/notes_provider.dart';

class RecordNotifier extends Notifier<RecordState> {
  String _currentTranscript = '';
  Timer? _timer;
  Timer? _sttCheckTimer;

  @override
  RecordState build() {
    return const Idle();
  }

  void startRecording() async {
    state = const Recording();
    _currentTranscript = '';
    final stt = ref.read(sttServiceProvider);
    
    ref.read(recordingTimeProvider.notifier).reset();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      ref.read(recordingTimeProvider.notifier).increment();
    });
    
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
      if (text.isNotEmpty) {
        _currentTranscript = text;
        state = Recording(transcript: _currentTranscript);
        try {
          FlutterOverlayWindow.shareData(_currentTranscript);
        } catch (_) {}
      }
    });
    
    if (result is Failure) {
      state = ErrorState(result.message);
      Future.delayed(const Duration(seconds: 2), () {
        if (state is ErrorState) {
          state = const Idle();
        }
      });
      return;
    }

    // Auto-restart STT if it stops due to pause timeout
    _sttCheckTimer?.cancel();
    _sttCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (state is Recording && !stt.isListening) {
        // STT stopped due to pause timeout, restart it
        final accumulatedText = _currentTranscript;
        await stt.startListening((text) {
          if (text.isNotEmpty) {
            // Append new text to accumulated transcript
            _currentTranscript = accumulatedText.isEmpty
                ? text
                : '$accumulatedText $text';
            state = Recording(transcript: _currentTranscript);
            try {
              FlutterOverlayWindow.shareData(_currentTranscript);
            } catch (_) {}
          }
        });
      }
    });
  }

  void stopRecording() async {
    _timer?.cancel();
    _sttCheckTimer?.cancel();
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

  void saveAndProcess([String? customTitle]) async {
    if (_currentTranscript.isEmpty) return;
    
    state = const AiProcessing();
    final pipeline = ref.read(aiPipelineProvider);
    
    final result = await pipeline.executePass1(_currentTranscript);
    
    if (result is Success<String>) {
      state = const Saving();
      
      // Parse the JSON to extract title
      String noteTitle = 'New Note';
      try {
        final parsed = jsonDecode(result.data) as Map<String, dynamic>;
        noteTitle = parsed['title'] as String? ?? 'New Note';
        if (noteTitle.isEmpty) noteTitle = 'New Note';
      } catch (_) {}
      
      if (customTitle != null && customTitle.isNotEmpty) {
        noteTitle = customTitle;
      }
      
      final dbService = ref.read(databaseProvider);
      
      int noteId = await dbService.insertNote({
        'title': noteTitle,
        'raw_transcript': _currentTranscript,
        'summary_json': result.data,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
      
      if (noteId != -1) {
        pipeline.executePass2(_currentTranscript, result.data, noteId);
        ref.invalidate(notesProvider); // Refresh list
      }
      
      state = const Completed();
      
      Future.delayed(const Duration(milliseconds: 1500), () {
        _currentTranscript = '';
        state = const Idle();
      });
    } else {
      // Save as plain text even if AI processing fails
      state = const Saving();
      final dbService = ref.read(databaseProvider);
      
      String fallbackTitle = _currentTranscript.split(RegExp(r'[.!?\n]')).first.trim();
      if (fallbackTitle.length > 60) fallbackTitle = '${fallbackTitle.substring(0, 57)}...';
      if (fallbackTitle.isEmpty) fallbackTitle = 'Untitled Note';
      
      if (customTitle != null && customTitle.isNotEmpty) {
        fallbackTitle = customTitle;
      }
      
      int noteId = await dbService.insertNote({
        'title': fallbackTitle,
        'raw_transcript': _currentTranscript,
        'summary_json': jsonEncode({'title': fallbackTitle, 'summary': _currentTranscript}),
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
      
      if (noteId != -1) {
        ref.invalidate(notesProvider);
      }
      
      state = const Completed();
      Future.delayed(const Duration(milliseconds: 1500), () {
        _currentTranscript = '';
        state = const Idle();
      });
    }
  }
  
  void setManualTranscript(String text) {
    _currentTranscript = text;
    state = Idle(transcript: _currentTranscript);
  }

  void reset() {
    _timer?.cancel();
    _sttCheckTimer?.cancel();
    ref.read(recordingTimeProvider.notifier).reset();
    _currentTranscript = '';
    state = const Idle();
  }
}

final recordStateProvider = NotifierProvider<RecordNotifier, RecordState>(() {
  return RecordNotifier();
});

class RecordingTimeNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
  void reset() => state = 0;
}

final recordingTimeProvider = NotifierProvider<RecordingTimeNotifier, int>(() {
  return RecordingTimeNotifier();
});
