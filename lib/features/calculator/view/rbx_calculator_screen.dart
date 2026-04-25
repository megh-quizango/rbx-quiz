import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../model/calculator_options.dart';
import '../../../core/services/splash_tabs_launcher_service.dart';

class RbxCalculatorScreen extends StatelessWidget {
  const RbxCalculatorScreen({super.key});

  static const _background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF3A2A07), Color(0xFF0B0700)],
  );

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final gridRatio = screenHeight < 650
        ? 0.68
        : screenHeight < 760
            ? 0.74
            : 0.80;

    return WillPopScope(
      onWillPop: () async {
        await SplashTabsLauncherService.openForTrigger(context, trigger: 'back');
        return true;
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
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
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: gridRatio,
                  ),
                  itemCount: kCalculatorOptions.length,
                  itemBuilder: (context, index) {
                    final option = kCalculatorOptions[index];
                    return _CalculatorCard(
                      option: option,
                      onTap: () {
                        SplashTabsLauncherService.openForTrigger(
                          context,
                          trigger: 'calculator_card',
                        ).whenComplete(() {
                          if (!context.mounted) return;
                          if (option.kind == CalculatorOptionKind.play) {
                            context.push('/play');
                            return;
                          }
                          context.push('/calculator/convert/${option.id}');
                        });
                      },
                    );
                  },
                ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        final padding = h < 180 ? 14.0 : 18.0;
        final iconDiameter =
            ((w * 0.34).clamp(44.0, 56.0) as double);
        final iconSize = ((iconDiameter * 0.46).clamp(20.0, 26.0) as double);
        final titleFont = ((h * 0.14).clamp(16.0, 21.0) as double);
        final subtitleFont = ((h * 0.085).clamp(11.5, 13.5) as double);
        final maxTitleLines = h < 180 ? 3 : 2;
        final maxSubtitleLines = h < 180 ? 5 : 4;

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
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: iconDiameter,
                          height: iconDiameter,
                          decoration: const BoxDecoration(
                            color: Color(0xFF0D0C0A),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            option.icon,
                            color: Colors.white,
                            size: iconSize,
                          ),
                        ),
                        SizedBox(height: h < 180 ? 10 : 14),
                        Text(
                          option.title,
                          maxLines: maxTitleLines,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: titleFont,
                            height: 1.08,
                          ),
                        ),
                        SizedBox(height: h < 180 ? 8 : 10),
                        Expanded(
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              option.subtitle,
                              maxLines: maxSubtitleLines,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                color: const Color(0xB3FFFFFF),
                                fontWeight: FontWeight.w600,
                                fontSize: subtitleFont,
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
                      top: h < 180 ? 10 : 14,
                      right: h < 180 ? 10 : 14,
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
      },
    );
  }
}
