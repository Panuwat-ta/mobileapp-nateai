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

    final isRecording = recordState is Recording;
    final isProcessing = recordState is Transcribing || recordState is AiProcessing || recordState is Saving;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        toolbarHeight: 48,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/icon.png',
                width: 28,
                height: 28,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Lecture Note AI',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 16),
              
              // Status & Timer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isRecording) ...[
                    const Icon(Icons.radio_button_checked, color: Color(0xFF2A4D69), size: 16),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    isProcessing ? 'PROCESSING' : (isRecording ? 'RECORDING' : 'READY'),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: const Color(0xFF2A4D69),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '00:00:00', // TODO: Timer Provider
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: -1,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Live Transcript Display
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 24.0),
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFDDE2E5)),
                  ),
                  child: _buildTranscriptArea(context, recordState),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Controls
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0, left: 24.0, right: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Left: Reset / Clear Button
                    _ControlButton(
                      icon: Icons.close,
                      onPressed: isProcessing ? null : () => _showResetDialog(context, ref),
                      tooltip: 'Clear / Restart',
                    ),
                    
                    // Center: Record / Stop Button
                    GestureDetector(
                      onTap: () {
                        if (isProcessing) return;
                        if (isRecording) {
                          notifier.stopRecording();
                        } else if (recordState is Idle || recordState is ErrorState) {
                          notifier.startRecording();
                        }
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: isRecording ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: (isRecording ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primaryContainer).withValues(alpha: 0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          isRecording ? Icons.stop : Icons.mic,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    
                    // Right: Save Button
                    _ControlButton(
                      icon: Icons.save,
                      onPressed: isProcessing ? null : () => _showSaveDialog(context, ref),
                      tooltip: 'Save Note',
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
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
        child: Text(
          'Tap the microphone to start transcribing...',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return SingleChildScrollView(
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          height: 1.6,
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restart'),
        content: const Text('Are you sure you want to clear the current transcript and restart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(recordStateProvider.notifier).reset();
              Navigator.of(ctx).pop();
            },
            child: const Text('Restart'),
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

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Note'),
        content: const Text('Do you want to save this text and let AI summarize it?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(recordStateProvider.notifier).saveAndProcess();
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
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

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
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
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(color: const Color(0xFFDDE2E5)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 4,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: onPressed == null ? Theme.of(context).colorScheme.outlineVariant : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

