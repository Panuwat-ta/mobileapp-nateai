import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'app/theme/app_theme.dart';
import 'app/constants/app_constants.dart';
import 'features/record/screens/permission_screen.dart';
import 'features/record/screens/overlay_screen.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'features/home/screens/main_screen.dart';
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

class LectureNoteApp extends StatelessWidget {
  const LectureNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
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

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/has_seen_permission.txt');
    final hasSeen = await file.exists();

    final status = await Permission.microphone.status;
    final overlayStatus = await FlutterOverlayWindow.isPermissionGranted();
    
    setState(() {
      _isPermissionGranted = (status.isGranted && overlayStatus) || hasSeen;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF03192E))),
      );
    }
    
    if (_isPermissionGranted) {
      return const MainScreen();
    } else {
      return const PermissionScreen();
    }
  }
}
