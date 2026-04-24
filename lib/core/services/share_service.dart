import 'package:flutter/services.dart';

class ShareService {
  static const MethodChannel _channel = MethodChannel('rbx_quiz/share');

  static Future<void> shareText(String text) async {
    try {
      await _channel.invokeMethod<void>('shareText', {'text': text});
    } catch (_) {
      // ignore
    }
  }
}
