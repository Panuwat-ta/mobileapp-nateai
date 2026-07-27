import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/theme/app_theme.dart';
import 'app/constants/app_constants.dart';
import 'app/providers/theme_provider.dart';
import 'features/record/screens/permission_screen.dart';
import 'features/record/screens/overlay_screen.dart';
import 'features/home/screens/main_screen.dart';
import 'features/settings/screens/model_download_screen.dart';

@pragma("vm:entry-point")
void overlayMain() {
  overlayMainImpl();
}

void overlayMainImpl() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OverlayScreen(),
    ),
  );
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    const ProviderScope(
      child: LectureNoteApp(),
    ),
  );
}

class LectureNoteApp extends ConsumerWidget {
  const LectureNoteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const AppStartup(), 
    );
  }
}

class AppStartup extends StatefulWidget {
  const AppStartup({super.key});

  @override
  State<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<AppStartup> {
  bool _isLoading = true;
  bool _isPermissionGranted = false;
  bool _isModelDownloaded = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    try {
      final status = await Permission.microphone.status;
      final overlayStatus = await FlutterOverlayWindow.isPermissionGranted();
      
      // Check for downloaded models
      final prefs = await SharedPreferences.getInstance();
      
      final qwenPath = prefs.getString('local_model_path');
      bool hasQwen = qwenPath != null && File(qwenPath).existsSync();
      
      final whisperPath = prefs.getString('whisper_model_path');
      bool hasWhisper = whisperPath != null && File(whisperPath).existsSync();
      
      if (mounted) {
        setState(() {
          _isPermissionGranted = status.isGranted && overlayStatus;
          _isModelDownloaded = hasQwen && hasWhisper;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPermissionGranted = false;
          _isModelDownloaded = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator(color: Color(0xFF03192E))),
      );
    }
    
    if (!_isPermissionGranted) {
      return const PermissionScreen();
    } 
    
    if (!_isModelDownloaded) {
      return const ModelDownloadScreen();
    }

    return const MainScreen();
  }
}
