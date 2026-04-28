import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

import '../../../core/services/custom_tab_service.dart';
import '../../../core/widgets/overlay_shimmer.dart';

class ExitDialog extends StatelessWidget {
  const ExitDialog({
    super.key,
    required this.playStoreUrl,
    required this.adUrl,
  });

  final String playStoreUrl;
  final String adUrl;

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
      fontSize: 18,
      letterSpacing: 0.8,
    );

    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: const BoxDecoration(gradient: _background),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/exit.png',
                        width: 190,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Exit This App!!!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 40,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Are You Sure Want To Exit This App?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xCCFFFFFF),
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 54,
                                  child: Stack(
                                    children: [
                                      /// BUTTON
                                      SizedBox.expand(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFE7D39A),
                                            foregroundColor: const Color(0xFF2A200F),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                            SystemNavigator.pop();
                                          },
                                          child: const Text(
                                            'YES',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: buttonTextStyle,
                                          ),
                                        ),
                                      ),

                                      /// SHIMMER
                                      Positioned.fill(
                                        child: IgnorePointer(
                                          child: OverlayShimmer(
                                            borderRadius: BorderRadius.circular(16),
                                            opacity: 0.5,
                                            child: const SizedBox(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: SizedBox(
                                  height: 54,
                                  child: Stack(
                                    children: [
                                      /// BUTTON
                                      SizedBox.expand(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFE2A321),
                                            foregroundColor: const Color(0xFF2A200F),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text(
                                            'NO',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: buttonTextStyle,
                                          ),
                                        ),
                                      ),

                                      /// SHIMMER
                                      Positioned.fill(
                                        child: IgnorePointer(
                                          child: OverlayShimmer(
                                            borderRadius: BorderRadius.circular(16),
                                            opacity: 0.5,
                                            child: const SizedBox(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          OverlayShimmer(
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF2A200F),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () => _rateUs(context),
                                child: const Text(
                                  'RATE US',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: buttonTextStyle,
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
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    try {
                      await CustomTabService.open(adUrl);
                    } catch (_) {
                      // ignore
                    }
                  },
                  child: Image.asset(
                    'assets/native_ad.jpg',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
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
