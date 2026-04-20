import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class RedeemEmailScreen extends StatefulWidget {
  const RedeemEmailScreen({super.key, required this.coins});

  final int coins;

  @override
  State<RedeemEmailScreen> createState() => _RedeemEmailScreenState();
}

class _RedeemEmailScreenState extends State<RedeemEmailScreen> {
  final _emailController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _done() async {
    if (_sending) return;
    setState(() => _sending = true);

    FocusScope.of(context).unfocus();
    await SystemChannels.textInput.invokeMethod('TextInput.hide');

    final rootContext = context;
    unawaited(
      showDialog<void>(
        context: rootContext,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.white,
              contentPadding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  const SizedBox(width: 14),
                  const Flexible(
                    child: Text(
                      'Sending email...',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2A200F),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    await Future<void>.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    Navigator.of(rootContext, rootNavigator: true).pop();
    if (!mounted) return;
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      rootContext.go('/');
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFFF6EFE2),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6EFE2),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: const Text('Free RBX Calculator'),
          foregroundColor: const Color(0xCCFFFFFF),
        ),
        extendBodyBehindAppBar: true,
        body: Column(
          children: [
            const _TopSpacerHeader(),
            const SizedBox(height: 34),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 26),
              child: Text(
                'Enter your email or username for\nRBX we will contact You soon on\nyou email',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF2A200F),
                  fontSize: 18,
                  height: 1.25,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: TextField(
                controller: _emailController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                enabled: !_sending,
                decoration: const InputDecoration(
                  hintText: 'Enter your email',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Color(0x662A200F),
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2A200F),
                  fontSize: 18,
                ),
                onSubmitted: (_) => _done(),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE7D39A),
                    foregroundColor: const Color(0xFF2A200F),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _sending ? null : _done,
                  child: const Text(
                    'DONE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _TopSpacerHeader extends StatelessWidget {
  const _TopSpacerHeader();

  static const _headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF3A2A07), Color(0xFF0B0700)],
  );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(38)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 86, 16, 20),
        decoration: const BoxDecoration(gradient: _headerGradient),
      ),
    );
  }
}
