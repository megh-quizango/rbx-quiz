import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/widgets/overlay_shimmer.dart';

class StayAndEarnScreen extends StatefulWidget {
  const StayAndEarnScreen({
    super.key,
    required this.sessionId,
    required this.elapsedSeconds,
    required this.onReset,
    required this.onStayAndEarn,
  });

  final String sessionId;
  final int elapsedSeconds;
  final VoidCallback onReset;
  final Future<void> Function() onStayAndEarn;

  @override
  State<StayAndEarnScreen> createState() => _StayAndEarnScreenState();
}

class _StayAndEarnScreenState extends State<StayAndEarnScreen>
    with WidgetsBindingObserver {
  static const int _targetSeconds = 180;
  static const _backgroundCancelAfter = Duration(seconds: 30);
  bool _closing = false;
  Timer? _backgroundCancelTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _backgroundCancelTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _backgroundCancelTimer?.cancel();
      _backgroundCancelTimer = null;
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _backgroundCancelTimer ??= Timer(_backgroundCancelAfter, _closeAndReset);
    }
  }

  void _closeAndReset() {
    if (_closing) return;
    _closing = true;
    _backgroundCancelTimer?.cancel();
    _backgroundCancelTimer = null;
    widget.onReset();
    if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  Future<void> _stayAndEarn() async {
    if (_closing) return;
    _closing = true;
    if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
    await widget.onStayAndEarn();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = (_targetSeconds - widget.elapsedSeconds).clamp(0, 999999);
    final mm = (remaining ~/ 60).toString().padLeft(2, '0');
    final ss = (remaining % 60).toString().padLeft(2, '0');

    return WillPopScope(
      onWillPop: () async {
        if (_closing) return false;
        _closing = true;
        widget.onReset();
        return true;
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: const Color(0xFF0B0700),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFF0B0700),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF3A2A07), Color(0xFF0B0700)],
              ),
            ),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final scale = (constraints.maxHeight / 780).clamp(0.80, 1.18);
                  final timerSize = (240 * scale).clamp(
                    200,
                    constraints.biggest.shortestSide * 0.74,
                  );

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: _closeAndReset,
                            icon: const Icon(Icons.close),
                            color: const Color(0xCCFFFFFF),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'Stay For 3 Minutes &\nGet 500 Coins!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 24 * scale,
                                  height: 1.10,
                                ),
                              ),
                              SizedBox(
                                width: timerSize.toDouble(),
                                height: timerSize.toDouble(),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/timer_bg.png',
                                      fit: BoxFit.contain,
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '$mm:$ss',
                                          style: TextStyle(
                                            color: const Color(0xFF2A200F),
                                            fontWeight: FontWeight.w900,
                                            fontSize: 44 * scale,
                                          ),
                                        ),
                                        SizedBox(height: 4 * scale),
                                        Text(
                                          'Time Remaining',
                                          style: TextStyle(
                                            color: const Color(0x992A200F),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14 * scale,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    "Don't Leave Early!",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 22 * scale,
                                    ),
                                  ),
                                  SizedBox(height: 8 * scale),
                                  Text(
                                    'Earn 500 Coins When The Timer\nReaches Zero',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xCCFFFFFF),
                                      fontWeight: FontWeight.w700,
                                      height: 1.25,
                                      fontSize: 15 * scale,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: double.infinity,
                                height: (58 * scale).clamp(52, 70).toDouble(),
                                child: Stack(
                                  children: [
                                    /// 🔥 BUTTON
                                    SizedBox.expand(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFE0AA14),
                                          foregroundColor: const Color(0xFF2A200F),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                        ),
                                        onPressed: _stayAndEarn,
                                        child: Text(
                                          'STAY & EARN',
                                          style: TextStyle(
                                            fontSize: 20 * scale,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ),
                                    ),

                                    /// 🔥 SHIMMER OVERLAY
                                    Positioned.fill(
                                      child: IgnorePointer(
                                        child: OverlayShimmer(
                                          borderRadius: BorderRadius.circular(14),
                                          opacity: 0.5,
                                          child: const SizedBox(), // required
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.fromLTRB(
                                  16,
                                  16 * scale,
                                  16,
                                  14 * scale,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDFBF6),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'EARN MORE REWARDS BY\nSTAYING LONGER!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: const Color(0xFF2A200F),
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8,
                                        fontSize: 14 * scale,
                                      ),
                                    ),
                                    SizedBox(height: 12 * scale),
                                    Text(
                                      '• Stay 5 Minutes & Get 1000 Coins',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: const Color(0x992A200F),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14 * scale,
                                      ),
                                    ),
                                    SizedBox(height: 6 * scale),
                                    Text(
                                      '• Stay 10 Minutes & Get 3000 Coins',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: const Color(0x992A200F),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14 * scale,
                                      ),
                                    ),
                                    SizedBox(height: 6 * scale),
                                    Text(
                                      '• Stay 15 Minutes & Get 5000 Coins',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: const Color(0x992A200F),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14 * scale,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
