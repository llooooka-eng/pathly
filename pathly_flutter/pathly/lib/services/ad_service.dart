import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService extends ChangeNotifier {
  static const String _rewardedIdAndroid =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _rewardedIdIOS =
      'ca-app-pub-3940256099942544/1712485313';

  static String get _adUnitId =>
      defaultTargetPlatform == TargetPlatform.android
          ? _rewardedIdAndroid
          : _rewardedIdIOS;

  RewardedAd? _ad;
  bool _adLoaded = false;
  bool _sessionUnlocked = false;
  bool _isLoading = false;
  String? _error;

  bool get adLoaded    => _adLoaded;
  bool get unlocked    => _sessionUnlocked;
  bool get isLoading   => _isLoading;
  String? get error    => _error;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    await loadAd();
  }

  Future<void> loadAd() async {
    if (_isLoading || _adLoaded) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    await RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _adLoaded = true;
          _isLoading = false;
          notifyListeners();
        },
        onAdFailedToLoad: (err) {
          _adLoaded = false;
          _isLoading = false;
          _error = 'تعذّر تحميل الإعلان. حاول مجدداً.';
          notifyListeners();
        },
      ),
    );
  }

  Future<bool> showAd() async {
    if (_ad == null) return false;
    bool rewarded = false;

    _ad!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _ad = null;
        _adLoaded = false;
        notifyListeners();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        _ad = null;
        _adLoaded = false;
        _error = 'فشل عرض الإعلان.';
        notifyListeners();
      },
    );

    await _ad!.show(
      onUserEarnedReward: (ad, reward) {
        rewarded = true;
        _sessionUnlocked = true;
        notifyListeners();
      },
    );
    return rewarded;
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }
}
