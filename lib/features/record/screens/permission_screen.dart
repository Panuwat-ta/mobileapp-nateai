import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../home/screens/main_screen.dart';
class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key});

  Future<void> _requestPermission(BuildContext context) async {
    await Permission.microphone.request();
    bool overlayGranted = await FlutterOverlayWindow.isPermissionGranted();
    if (!overlayGranted) {
      await FlutterOverlayWindow.requestPermission();
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/has_seen_permission.txt');
    await file.writeAsString('true');

    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 48),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDEEEF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFDDE2E5)),
                        ),
                        child: const Icon(Icons.school_outlined, size: 40, color: Color(0xFF03192E)),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'ยินดีต้อนรับสู่ Lecture Note AI',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF191C1D)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'เพื่อให้คุณได้รับประสบการณ์การเรียนรู้แบบออฟไลน์ที่ดีที่สุด เราจำเป็นต้องขออนุญาตสิทธิ์บางอย่างเพื่อเริ่มต้นใช้งาน',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Color(0xFF43474D), height: 1.5),
                      ),
                      const SizedBox(height: 32),
                      
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFDDE2E5)),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildPermissionRow(Icons.mic_none_rounded, 'ไมโครโฟน', 'เพื่อบันทึกและถอดเสียงบรรยายของคุณภายในเครื่อง'),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Divider(height: 1, color: Color(0xFFEDEEEF)),
                            ),
                            _buildPermissionRow(Icons.layers_outlined, 'แสดงผลทับหน้าจอ', 'เพื่อแสดงแผงควบคุมและสถานะระหว่างที่คุณใช้งานแอปอื่น'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFDDE2E5)),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Icon(Icons.verified_user_outlined, color: Color(0xFF51606F), size: 20),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'ข้อมูลของคุณจะถูกประมวลผลแบบออฟไลน์เท่านั้น จะไม่มีการส่งไฟล์เสียงหรือข้อความใดๆ ออกจากอุปกรณ์นี้',
                                style: TextStyle(fontSize: 14, color: Color(0xFF51606F), height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _requestPermission(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF03192E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Flexible(
                        child: Text(
                          'อนุญาตสิทธิ์และดำเนินการต่อ', 
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'คุณสามารถเปลี่ยนแปลงการตั้งค่านี้ได้ในภายหลัง เราจะจดจำสิ่งที่คุณเลือกและจะไม่ถามซ้ำอีก',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF43474D), height: 1.4),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionRow(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFEDEEEF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF03192E)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF191C1D))),
              const SizedBox(height: 4),
              Text(desc, style: const TextStyle(fontSize: 14, color: Color(0xFF43474D), height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
