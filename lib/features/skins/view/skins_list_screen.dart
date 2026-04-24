import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../model/skins_catalog.dart';
import '../model/skins_detail_args.dart';

class SkinsListScreen extends StatelessWidget {
  const SkinsListScreen({super.key, required this.listId});

  final String listId;

  @override
  Widget build(BuildContext context) {
    final spec = SkinsCatalog.listById(listId);
    if (spec == null) {
      return const _NotFoundScreen();
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
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
            spec.title,
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
              itemCount: spec.count,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.92,
              ),
              itemBuilder: (context, index) {
                final title = spec.itemTitleForIndex(index);
                final asset = spec.assetForIndex(index);
                return _OptionCard(
                  title: title,
                  asset: asset,
                  onTap: () => context.push(
                    '/skins/detail',
                    extra: SkinsDetailArgs(title: title, asset: asset),
                  ),
                );
              },
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

