import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

class ExitDialog extends StatelessWidget {
  const ExitDialog({super.key, required this.playStoreUrl});

  final String playStoreUrl;

  static const _background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF3A2A07), Color(0xFF0B0700)],
  );

  Future<void> _rateUs(BuildContext context) async {
    try {
      await launchUrl(
        Uri.parse(playStoreUrl),
        customTabsOptions: CustomTabsOptions(
          showTitle: true,
          urlBarHidingEnabled: true,
          colorSchemes: CustomTabsColorSchemes.defaults(
            toolbarColor: const Color(0xFF201402),
            navigationBarColor: const Color(0xFF0B0700),
          ),
          shareState: CustomTabsShareState.off,
        ),
        safariVCOptions: const SafariViewControllerOptions(
          barCollapsingEnabled: true,
          entersReaderIfAvailable: false,
        ),
      );
    } catch (_) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    const buttonTextStyle = TextStyle(
      fontWeight: FontWeight.w900,
      fontSize: 22,
      letterSpacing: 0.8,
    );

    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: const BoxDecoration(gradient: _background),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 26),
            child: Column(
              children: [
                const Spacer(),
                Image.asset(
                  'assets/exit.png',
                  width: 200,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
                const SizedBox(height: 26),
                const Text(
                  'Exit This App!!!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 44,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Are You Sure Want To Exit This App?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xCCFFFFFF),
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                    height: 1.25,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE7D39A),
                            foregroundColor: const Color(0xFF2A200F),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                            SystemNavigator.pop();
                          },
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'YES',
                              style: buttonTextStyle,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF2A200F),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: () => _rateUs(context),
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'RATE US',
                              style: buttonTextStyle,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE2A321),
                            foregroundColor: const Color(0xFF2A200F),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'NO',
                              style: buttonTextStyle,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
