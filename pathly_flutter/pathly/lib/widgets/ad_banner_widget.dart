import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';
import '../theme/app_theme.dart';

/// بانر صغير اختياري يظهر في أسفل بعض الشاشات
/// (مثلاً شاشة التقدم أو الأهداف — ليس الشاشة الرئيسية)
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    final adService = AdService();
    final banner = adService.createBannerAd();
    banner.load().then((_) {
      if (mounted) setState(() { _bannerAd = banner; _loaded = true; });
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _bannerAd == null) return const SizedBox.shrink();

    return Container(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: PathlyTheme.border, width: 0.5)),
      ),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
