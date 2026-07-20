import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/result.dart';

final llamaServiceProvider = Provider<LlamaService>((ref) {
  return LlamaService();
});

class LlamaService {
  // TODO: Initialize fllama with Qwen3-1.7B-Instruct-Q8_0.gguf
  // The initialization will be done once on isolate to prevent memory leak
  // and keep the model loaded for fast inference (< 15 sec).
  
  Future<Result<bool>> initializeModel(String modelPath) async {
    try {
      // โหลดโมเดล 1 ครั้งลงใน Isolate เพื่อลดการกินหน่วยความจำซ้ำซ้อน
      // และต้องมั่นใจว่าไม่มีการเรียก Network Request ใดๆ ออกไปภายนอก
      return const Success(true);
    } catch (e, st) {
      return Failure('Failed to load LLM model: $e', e, st);
    }
  }

  Future<Result<String>> generateSummary(String transcript) async {
    try {
      // บังคับคืนค่ากลับมาเป็น JSON ตามรูปแบบที่กำหนด
      // โมเดลจะถูกสั่งรันและคืนค่ากลับมาผ่าน Isolate
      
      await Future.delayed(const Duration(seconds: 2));
      return const Success('{"title": "Mock Title", "summary": "Mock summary", "homework": null, "exam": null}');
    } catch (e, st) {
      return Failure('Inference failed', e, st);
    }
  }

  void dispose() {
    // ต้องทำลาย Isolate ทุกครั้งที่ปิดแอปเพื่อป้องกัน Memory Leak
  }
}
