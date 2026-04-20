import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RbxCalculatorScreen extends StatefulWidget {
  const RbxCalculatorScreen({super.key});

  @override
  State<RbxCalculatorScreen> createState() => _RbxCalculatorScreenState();
}

class _RbxCalculatorScreenState extends State<RbxCalculatorScreen> {
  static const _background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF3A2A07), Color(0xFF0B0700)],
  );

  int _days = 0;

  void _decrement() => setState(() => _days = (_days - 1).clamp(0, 999999));
  void _increment() => setState(() => _days = (_days + 1).clamp(0, 999999));

  Future<void> _count() async {
    final result = _days * 0.025;
    final value = _formatPoints(result);

    if (!mounted) return;
    await showDialog<void>(
      context: context,
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
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'BASIC RBX CASH CALC',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    fontSize: 16,
                    color: Color(0xFF2A200F),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'If you are a new PUBG player get:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2A200F),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$value BASIC RBX POINTS',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2A200F),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: 140,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE7D39A),
                      foregroundColor: const Color(0xFF2A200F),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Ok',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _formatPoints(double value) {
    final fixed = value.toStringAsFixed(3);
    return fixed.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

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
          backgroundColor: Color(0xFF2A200F),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: const Text('RBX Calculator'),
          foregroundColor: const Color(0xCCFFFFFF),
        ),
        extendBodyBehindAppBar: false,
        body: Container(
          decoration: const BoxDecoration(gradient: _background),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 14),
                const Text(
                  'ENTER NUMBER\nOF DAYS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 18),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 26),
                  child: Text(
                    'Please enter the number of days to\nget the basic rbx cash calculation\nof that days',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontSize: 16,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _StepButton(label: '-1', onTap: _decrement),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Container(
                          height: 56,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '$_days',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2A200F),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      _StepButton(label: '+1', onTap: _increment),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
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
                      onPressed: _count,
                      child: const Text(
                        'COUNT',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 22),
                  child: Text(
                    '*Note: we never store any information about you',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
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
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
