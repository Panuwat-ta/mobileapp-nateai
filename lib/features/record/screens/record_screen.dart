import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/record_state.dart';
import '../providers/record_state_provider.dart';

class RecordScreen extends ConsumerWidget {
  const RecordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordState = ref.watch(recordStateProvider);
    final notifier = ref.read(recordStateProvider.notifier);
    final recordingTime = ref.watch(recordingTimeProvider);

    ref.listen<RecordState>(recordStateProvider, (previous, next) {
      if (next is ErrorState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } else if (next is Completed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Note saved successfully! ✓'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    });

    final isRecording = recordState is Recording;
    final isProcessing = recordState is Transcribing || recordState is AiProcessing || recordState is Saving;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        toolbarHeight: 56,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Transcription',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isRecording)
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Listening to internal & external audio',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.keyboard_alt_outlined),
            onPressed: isProcessing ? null : () => _showManualInputDialog(context, ref),
            tooltip: 'Manual Input',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Full Screen Transcript Area
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: _buildTranscriptArea(context, recordState),
                ),
              ),
              
              // Bottom Controls Area
              Container(
                padding: const EdgeInsets.only(top: 24, bottom: 48, left: 24, right: 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Timer and Waveform Dummy
                    if (isRecording || isProcessing) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isRecording)
                            const Icon(Icons.graphic_eq, color: Colors.blueAccent, size: 24),
                          if (isRecording) const SizedBox(width: 12),
                          Text(
                            _formatTime(recordingTime),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Control Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ControlButton(
                          icon: Icons.close,
                          onPressed: isProcessing ? null : () => _showResetDialog(context, ref),
                          tooltip: 'Clear',
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        
                        GestureDetector(
                          onTap: () {
                            if (isProcessing) return;
                            if (isRecording) {
                              notifier.stopRecording();
                            } else if (recordState is Idle || recordState is ErrorState) {
                              notifier.startRecording();
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: isRecording ? 72 : 80,
                            height: isRecording ? 72 : 80,
                            decoration: BoxDecoration(
                              color: isRecording 
                                ? Theme.of(context).colorScheme.errorContainer 
                                : Theme.of(context).colorScheme.primary,
                              shape: BoxShape.rectangle,
                              borderRadius: isRecording ? BorderRadius.circular(24) : BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  color: (isRecording ? Colors.red : Theme.of(context).colorScheme.primary).withValues(alpha: 0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                              color: isRecording ? Theme.of(context).colorScheme.onErrorContainer : Theme.of(context).colorScheme.onPrimary,
                              size: 36,
                            ),
                          ),
                        ),
                        
                        _ControlButton(
                          icon: Icons.check,
                          onPressed: isProcessing ? null : () => _showSaveDialog(context, ref),
                          tooltip: 'Save',
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      'AI is analyzing your notes...',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    int s = seconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Widget _buildTranscriptArea(BuildContext context, RecordState state) {
    String text = '';
    if (state is Recording) {
      text = state.transcript;
    } else if (state is Idle) {
      text = state.transcript;
    }

    if (text.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.record_voice_over, size: 64, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
            const SizedBox(height: 24),
            Text(
              'Ready to Transcribe',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the microphone below to start recording meetings or lectures.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      reverse: true, // Auto-scrolls to the bottom
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Text(
          text,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            height: 1.5,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard Recording?'),
        content: const Text('Are you sure you want to clear the current transcript? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () {
              ref.read(recordStateProvider.notifier).reset();
              Navigator.of(ctx).pop();
            },
            child: const Text('Discard', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSaveDialog(BuildContext context, WidgetRef ref) {
    final state = ref.read(recordStateProvider);
    String transcript = '';
    if (state is Idle) transcript = state.transcript;
    if (state is Recording) transcript = state.transcript;

    if (transcript.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transcript to save yet.')),
      );
      return;
    }

    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI will now summarize this transcript.'),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Note Name (Optional)',
                hintText: 'Enter a name or let AI generate one',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final customTitle = titleController.text.trim();
              ref.read(recordStateProvider.notifier).saveAndProcess(customTitle.isNotEmpty ? customTitle : null);
              Navigator.of(ctx).pop();
            },
            child: const Text('Save & Summarize'),
          ),
        ],
      ),
    );
  }

  void _showManualInputDialog(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Manual Input'),
        content: TextField(
          controller: textController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Paste or type transcript here...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final text = textController.text.trim();
              if (text.isNotEmpty) {
                ref.read(recordStateProvider.notifier).setManualTranscript(text);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Set Transcript'),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final Color color;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.1),
          ),
          child: Icon(
            icon,
            color: onPressed == null ? Theme.of(context).colorScheme.outlineVariant : color,
            size: 28,
          ),
        ),
      ),
    );
  }
}
