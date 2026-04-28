import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_urls.dart';
import '../../../core/services/custom_tab_service.dart';
import '../../../core/services/firebase_content_service.dart';
import '../../../core/services/splash_tabs_launcher_service.dart';
import '../../../core/widgets/overlay_shimmer.dart';
import '../model/calculator_options.dart';

class RbxConversionScreen extends ConsumerStatefulWidget {
  const RbxConversionScreen({super.key, required this.spec});

  final ConversionSpec spec;

  @override
  ConsumerState<RbxConversionScreen> createState() =>
      _RbxConversionScreenState();
}

class _RbxConversionScreenState extends ConsumerState<RbxConversionScreen> {
  static const _background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF6EFE2), Color(0xFFF6EFE2)],
  );

  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  double? _result;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _convert() {
    FocusScope.of(context).unfocus();
    final raw = _controller.text.trim();
    final value = double.tryParse(raw.replaceAll(',', ''));
    if (value == null) {
      setState(() => _result = null);
      return;
    }
    setState(() => _result = widget.spec.compute(value));
  }

  String _formatResult(double value) {
    final unit = widget.spec.outputUnit.toLowerCase();
    if (unit == 'usd' || unit == 'dollar') {
      return value.toStringAsFixed(2);
    }
    final asInt = value.round();
    return asInt.toString();
  }

  @override
  Widget build(BuildContext context) {
    final spec = widget.spec;
    final remoteUrls = ref.watch(remoteUrlsProvider).valueOrNull;
    final doneUrl =
        ref.watch(welcomeUrlProvider).valueOrNull ??
        remoteUrls?.splash ??
        AppUrls.welcome;

    return WillPopScope(
      onWillPop: () async {
        await SplashTabsLauncherService.openForTrigger(
          context,
          trigger: 'back',
        );
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
            title: Text(spec.title),
            foregroundColor: const Color(0xCCFFFFFF),
          ),
          body: Container(
            decoration: const BoxDecoration(gradient: _background),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Enter Your ${spec.inputUnit}',
                              style: const TextStyle(
                                color: Color(0xFF241802),
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              height: 56,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFF241802),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: const Color(0x33FFFFFF),
                                ),
                              ),
                              child: TextField(
                                controller: _controller,
                                focusNode: _focusNode,
                                style: const TextStyle(
                                  color: Color(0xCCFFFFFF),
                                  fontWeight: FontWeight.w800,
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9\.,]'),
                                  ),
                                ],
                                decoration: InputDecoration(
                                  hintText:
                                      'Enter your ${spec.inputUnit} Amount',
                                  hintStyle: const TextStyle(
                                    color: Color(0x66FFFFFF),
                                    fontWeight: FontWeight.w700,
                                  ),
                                  border: InputBorder.none,
                                ),
                                onSubmitted: (_) => _convert(),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Stack(
                              children: [
                                SizedBox(
                                  height: 56,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE7D39A),
                                      foregroundColor: const Color(0xFF2A200F),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                    ),
                                    onPressed: _convert,
                                    child: Text(
                                      'Convert to ${spec.outputUnit}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),

                                /// 🔥 SHIMMER OVERLAY
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: OverlayShimmer(
                                      borderRadius: BorderRadius.circular(28),
                                      opacity: 0.5,
                                      child: const SizedBox(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            Container(
                              padding: const EdgeInsets.fromLTRB(
                                18,
                                18,
                                18,
                                16,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF241802),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(0x22FFFFFF),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Convert ${spec.outputUnit} Amount',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xCCFFFFFF),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    _result == null
                                        ? '0.0 ${spec.outputUnit}'
                                        : '${_formatResult(_result!)} ${spec.outputUnit}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xCCFFFFFF),
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  OverlayShimmer(
                                    borderRadius: BorderRadius.circular(28),
                                    child: SizedBox(
                                      width: 220,
                                      height: 54,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFE7D39A,
                                          ),
                                          foregroundColor: const Color(
                                            0xFF2A200F,
                                          ),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              28,
                                            ),
                                          ),
                                        ),
                                        onPressed: () async {
                                          FocusScope.of(context).unfocus();
                                          SplashTabsConfig config;
                                          try {
                                            config = await ref.read(splashTabsConfigProvider.future);
                                          } catch (_) {
                                            config = SplashTabsConfig.fallback;
                                          }
                                          if (config.enabled) {
                                            try {
                                              await CustomTabService.open(
                                                doneUrl,
                                              );
                                            } catch (_) {}
                                          }
                                          if (!mounted) return;
                                          Navigator.of(context).maybePop();
                                        },
                                        child: const Text(
                                          'Done',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
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
