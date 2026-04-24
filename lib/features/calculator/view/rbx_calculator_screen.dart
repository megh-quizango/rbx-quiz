import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../model/calculator_options.dart';

class RbxCalculatorScreen extends StatelessWidget {
  const RbxCalculatorScreen({super.key});

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
          backgroundColor: const Color(0xFF2A200F),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: const Text('All Calculator'),
          foregroundColor: const Color(0xCCFFFFFF),
        ),
        body: Container(
          decoration: const BoxDecoration(gradient: _background),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.80,
                ),
                itemCount: kCalculatorOptions.length,
                itemBuilder: (context, index) {
                  final option = kCalculatorOptions[index];
                  return _CalculatorCard(
                    option: option,
                    onTap: () {
                      if (option.kind == CalculatorOptionKind.play) {
                        context.push('/play');
                        return;
                      }
                      context.push('/calculator/convert/${option.id}');
                    },
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

class _CalculatorCard extends StatelessWidget {
  const _CalculatorCard({required this.option, required this.onTap});

  final CalculatorOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1A12),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0x22FFFFFF)),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0D0C0A),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(option.icon, color: Colors.white, size: 26),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      option.title,
                      maxLines: 2,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 21,
                        height: 1.08,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          option.subtitle,
                          maxLines: 4,
                          overflow: TextOverflow.clip,
                          style: const TextStyle(
                            color: Color(0xB3FFFFFF),
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (option.showAdBadge)
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D0C0A),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0x22000000)),
                    ),
                    child: const Text(
                      'AD',
                      style: TextStyle(
                        color: Color(0xFFE7D39A),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                      ),
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
