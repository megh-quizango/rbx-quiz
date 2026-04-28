import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

class WebLauncherService {
  Future<void> openUrl(String url) async {
    try {
      await launchUrl(
        Uri.parse(url),
        customTabsOptions: const CustomTabsOptions(showTitle: true),
        safariVCOptions: const SafariViewControllerOptions(
          entersReaderIfAvailable: false,
        ),
      );
    } catch (e) {
      throw Exception("Could not launch $url");
    }
  }
}
