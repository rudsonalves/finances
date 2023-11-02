import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../constants/themes/app_text_styles.dart';

const urlFinances =
    'https://play.google.com/store/apps/details?id=br.com.jrblog.finances&hl=en-US&ah=ZX2hkg0PO2zTT6vYapfrg3lDy9M';

const adMobEnable = false;

class AdmobBanner {
  AdmobBanner._() {
    if (adMobEnable) _loadAdWithRetry();
  }

  static final AdmobBanner _instance = AdmobBanner._();

  static AdmobBanner get instance => _instance;

  final logger = Logger();

  Function? _refresh;

  set refreshFunction(Function func) => _refresh = func;

  BannerAd? _bannerAd;

  final String _adUnitId = 'ca-app-pub-8497496188098593/3045787588';

  /// Loads and shows a banner ad.
  ///
  /// Dimensions of the ad are determined by the AdSize class.
  void _loadAdWithRetry() async {
    BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          _bannerAd = ad as BannerAd;
          logger.i('New ad received...');
          if (_refresh != null) _refresh!();
          // notifyListeners();
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          logger.e(err);
          ad.dispose();

          Future.delayed(
            const Duration(seconds: 30),
            () {
              _loadAdWithRetry();
            },
          );
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) {},
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) {},
        // Called when an impression occurs on the ad.
        onAdImpression: (Ad ad) {},
      ),
    ).load();
  }

  void disposeAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
  }

  final double _height = 50;
  final double _width = 320;

  double? get height => 90 + _height;

  static Future<bool> launchGooglePlay() async {
    return await launchUrl(
      Uri.parse(
        urlFinances,
      ),
    );
  }

  List<Widget> build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return _bannerAd != null
        ? [
            const Divider(),
            SizedBox(
              width: _width,
              height: _height,
              child: AdWidget(ad: _bannerAd!),
            ),
          ]
        : [
            const Divider(),
            SizedBox(
              width: _width,
              height: _height,
              child: InkWell(
                onTap: launchGooglePlay,
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/google_play.png',
                      width: 50,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      locale.admob_msg_banner,
                      maxLines: 3,
                      style: AppTextStyles.textStyle11.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
  }
}

class AdmobIntersticial {
  AdmobIntersticial._() {
    if (adMobEnable) _loadAdWithRetry();
  }

  static final AdmobIntersticial _instance = AdmobIntersticial._();

  static AdmobIntersticial get instance => _instance;

  final logger = Logger();

  final adUnitId = 'ca-app-pub-8497496188098593/8283787920';

  InterstitialAd? _interstitialAd;

  InterstitialAd? get interstitialAd => _interstitialAd;

  Future<void> show() async {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
    }
  }

  /// Loads an interstitial ad.
  void _loadAdWithRetry() {
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          logger.i('$ad loaded.');
          // Keep a reference to the ad so you can show it later.
          _interstitialAd = ad;
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (LoadAdError error) async {
          logger.e('InterstitialAd failed to load: $error');

          await Future.delayed(
            const Duration(seconds: 30),
            () {
              _loadAdWithRetry();
            },
          );
        },
      ),
    );
  }
}
