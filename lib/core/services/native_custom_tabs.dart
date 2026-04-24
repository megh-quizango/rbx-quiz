import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum NativeCustomTabEventType { shown, hidden }

@immutable
class NativeCustomTabEvent {
  const NativeCustomTabEvent(this.type, {this.timestamp});

  final NativeCustomTabEventType type;
  final DateTime? timestamp;

  static NativeCustomTabEvent? tryParse(dynamic value) {
    if (value is Map) {
      final t = value['event'];
      final ts = value['ts'];
      DateTime? parsed;
      if (ts is int) {
        parsed = DateTime.fromMillisecondsSinceEpoch(ts);
      } else if (ts is num) {
        parsed = DateTime.fromMillisecondsSinceEpoch(ts.toInt());
      }
      if (t == 'shown') {
        return NativeCustomTabEvent(
          NativeCustomTabEventType.shown,
          timestamp: parsed,
        );
      }
      if (t == 'hidden') {
        return NativeCustomTabEvent(
          NativeCustomTabEventType.hidden,
          timestamp: parsed,
        );
      }
    }
    if (value == 'shown') return const NativeCustomTabEvent(NativeCustomTabEventType.shown);
    if (value == 'hidden') return const NativeCustomTabEvent(NativeCustomTabEventType.hidden);
    return null;
  }
}

class NativeCustomTabs {
  NativeCustomTabs._();

  static final NativeCustomTabs instance = NativeCustomTabs._();

  static const MethodChannel _channel = MethodChannel('rbx_quiz/custom_tabs');
  static const EventChannel _eventsChannel = EventChannel('rbx_quiz/custom_tabs_events');

  Stream<NativeCustomTabEvent>? _events;

  bool get isSupported => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Stream<NativeCustomTabEvent> events() {
    if (!isSupported) return const Stream.empty();
    return _events ??= _eventsChannel
        .receiveBroadcastStream()
        .map(NativeCustomTabEvent.tryParse)
        .where((e) => e != null)
        .cast<NativeCustomTabEvent>();
  }

  Future<void> warmup() async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod<void>('warmup');
    } catch (_) {
      // ignore
    }
  }

  Future<void> open(String url) async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod<void>('open', <String, dynamic>{'url': url});
    } catch (_) {
      // ignore
    }
  }
}
