import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/state/app_state.dart';

class RedeemCoinsScreen extends ConsumerStatefulWidget {
  const RedeemCoinsScreen({super.key});

  @override
  ConsumerState<RedeemCoinsScreen> createState() => _RedeemCoinsScreenState();
}

class _RedeemCoinsScreenState extends ConsumerState<RedeemCoinsScreen> {
  final _coinsController = TextEditingController(text: '0');

  @override
  void dispose() {
    _coinsController.dispose();
    super.dispose();
  }

  int _coins() {
    final raw = _coinsController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.isEmpty) return 0;
    return int.tryParse(raw) ?? 0;
  }

  String _usdText(int coins) => (coins / 1000).toStringAsFixed(1);

  void _next() {
    FocusScope.of(context).unfocus();
    final coins = _coins();
    context.push('/redeem/email?coins=$coins');
  }

  @override
  Widget build(BuildContext context) {
    final balance = ref.watch(balanceProvider);
    final coins = _coins();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

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
            _RedeemHeader(balance: balance),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 22 + bottomInset),
                child: Column(
                  children: [
                    const SizedBox(height: 22),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 26),
                      child: Text(
                        'How many coins you want to\nturn into RBX?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF2A200F),
                          fontSize: 18,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'It is ${_usdText(coins)}USD',
                      style: const TextStyle(
                        color: Color(0x992A200F),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: 220,
                      child: TextSelectionTheme(
                        data: const TextSelectionThemeData(
                          cursorColor: Color(0xFF2A200F),
                          selectionColor: Color(0x33E2A321),
                          selectionHandleColor: Color(0xFFE2A321),
                        ),
                        child: TextField(
                          controller: _coinsController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          cursorColor: const Color(0xFF2A200F),
                          style: const TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2A200F),
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
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
                          onPressed: _next,
                          child: const Text(
                            'NEXT',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'You must have +500 000 coins.',
                      style: TextStyle(
                        color: Color(0x992A200F),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const _RatesList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RedeemHeader extends StatelessWidget {
  const _RedeemHeader({required this.balance});

  final int balance;

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
        child: SizedBox(
          height: 72,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'assets/splash_logo.png',
                  width: 68,
                  height: 68,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
              const Align(
                alignment: Alignment.center,
                child: Text(
                  'MY BALANCE:',
                  style: TextStyle(
                    color: Color(0xCCFFFFFF),
                    fontSize: 14,
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$balance',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    height: 1.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RatesList extends StatelessWidget {
  const _RatesList();

  @override
  Widget build(BuildContext context) {
    const lines = [
      '1,000 points = \$0.20',
      '10,000 points = \$2',
      '30,000 points = \$6',
      '50,000 points = \$10',
      '100,000 points = \$20',
      '300,000 points = \$60',
      '500,000 points = \$100',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Column(
        children: [
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '• $line',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0x992A200F),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
