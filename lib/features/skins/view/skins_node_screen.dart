import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../model/skins_catalog.dart';
import '../../../core/services/splash_tabs_launcher_service.dart';

class SkinsNodeScreen extends StatelessWidget {
  const SkinsNodeScreen({super.key, required this.nodeId});

  final String nodeId;

  @override
  Widget build(BuildContext context) {
    final node = SkinsCatalog.nodeById(nodeId);
    if (node == null) {
      return const _NotFoundScreen();
    }

    return WillPopScope(
      onWillPop: () async {
        await SplashTabsLauncherService.openForTrigger(context, trigger: 'back');
        return true;
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: const Color(0xFFF6EFE2),
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFFF6EFE2),
          appBar: AppBar(
            backgroundColor: const Color(0xFF241802),
            foregroundColor: Colors.white,
            elevation: 0,
            titleSpacing: 0,
            title: Text(
              node.title,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 28,
                letterSpacing: 0.2,
              ),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              child: GridView.builder(
                itemCount: node.entries.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.92,
                ),
                itemBuilder: (context, index) {
                  final entry = node.entries[index];
                  return _OptionCard(
                    title: entry.title,
                    asset: entry.iconAsset,
                    onTap: () {
                      SplashTabsLauncherService.openForTrigger(
                        context,
                        trigger: 'skins_card',
                      ).whenComplete(() {
                        if (!context.mounted) return;
                        if (entry is SkinsEntryNode) {
                          context.push('/skins/node/${entry.nodeId}');
                          return;
                        }
                        if (entry is SkinsEntryList) {
                          context.push('/skins/list/${entry.listId}');
                          return;
                        }
                      });
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

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.title,
    required this.asset,
    required this.onTap,
  });

  final String title;
  final String asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 2,
      shadowColor: const Color(0x22000000),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Image.asset(
                    asset,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (context, _, __) => const Icon(
                      Icons.image_not_supported_outlined,
                      size: 48,
                      color: Color(0x662A200F),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF2A200F),
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  height: 1.05,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EFE2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF241802),
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: const Text(
          'Not found',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: const Center(
        child: Text(
          'Screen not found',
          style: TextStyle(
            color: Color(0x992A200F),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
