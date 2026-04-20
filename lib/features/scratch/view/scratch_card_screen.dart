import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScratchCardScreen extends StatelessWidget {
  const ScratchCardScreen({super.key});

  static const _background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF3A2A07), Color(0xFF0B0700)],
  );

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFF0B0700),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: const Text('Scratch Card'),
          foregroundColor: const Color(0xCCFFFFFF),
        ),
        body: Container(
          decoration: const BoxDecoration(gradient: _background),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 26,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDFBF6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'SCRATCH TO REVEAL',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF2A200F),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Coming soon',
                          style: TextStyle(
                            color: Color(0x992A200F),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE7D39A),
                        foregroundColor: const Color(0xFF2A200F),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
