import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/ai/model_download_service.dart';
import '../../home/screens/main_screen.dart';
import '../../../widgets/primary_button.dart';

class ModelDownloadScreen extends ConsumerStatefulWidget {
  const ModelDownloadScreen({super.key});

  @override
  ConsumerState<ModelDownloadScreen> createState() => _ModelDownloadScreenState();
}

class _ModelDownloadScreenState extends ConsumerState<ModelDownloadScreen> {
  bool _isDownloading = false;
  double _progress = 0.0;
  String _statusText = 'Checking required models...';
  
  bool _needsQwen = false;
  bool _needsWhisper = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkModels();
  }

  Future<void> _checkModels() async {
    final downloadService = ref.read(modelDownloadServiceProvider);
    final qwenPath = await downloadService.getDownloadedModelPath(ModelType.qwen);
    final whisperPath = await downloadService.getDownloadedModelPath(ModelType.whisper);
    
    if (mounted) {
      setState(() {
        _needsQwen = qwenPath == null;
        _needsWhisper = whisperPath == null;
        _isChecking = false;
        
        if (_needsQwen && _needsWhisper) {
          _statusText = 'Local AI & STT models are required (1.5 GB total)';
        } else if (_needsQwen) {
          _statusText = 'Local AI model is required (1.5 GB)';
        } else if (_needsWhisper) {
          _statusText = 'Whisper STT model is required (142 MB)';
        } else {
          _statusText = 'All models are ready!';
          _goToMain();
        }
      });
    }
  }

  void _goToMain() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Download Models'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_download_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 32),
            Text(
              'Required Models',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _statusText,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 48),
            
            if (_isDownloading) ...[
              LinearProgressIndicator(
                value: _progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 16),
              Text(
                '${(_progress * 100).toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'ดาวน์โหลด / Download',
                  onPressed: _startDownloads,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  void _startDownloads() async {
    if (_needsQwen) {
      await _downloadModel(ModelType.qwen, 'Downloading AI Model...');
    }
    if (_needsWhisper) {
      await _downloadModel(ModelType.whisper, 'Downloading STT Model (142MB)...');
    }
    
    if (mounted) {
      _goToMain();
    }
  }

  Future<void> _downloadModel(ModelType type, String statusMsg) async {
    setState(() {
      _isDownloading = true;
      _statusText = statusMsg;
      _progress = 0.0;
    });

    final downloadService = ref.read(modelDownloadServiceProvider);
    
    await downloadService.downloadModel(
      type: type,
      onReceiveProgress: (received, total) {
        if (total != -1 && mounted) {
          setState(() {
            _progress = received / total;
          });
        }
      },
      onSuccess: (path) {
        if (type == ModelType.qwen) _needsQwen = false;
        if (type == ModelType.whisper) _needsWhisper = false;
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isDownloading = false;
            _progress = 0.0;
            _statusText = error;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        }
      },
    );
  }
}
