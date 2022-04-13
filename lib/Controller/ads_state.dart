import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

final admobBannerTestID = Platform.isAndroid
    ? 'ca-app-pub-3940256099942544/6300978111'
    : 'ca-app-pub-3940256099942544/2934735716';

final admobBannerID = Platform.isAndroid
    //android
    ? 'ca-app-pub-6495599315568479/2248966926'
    //ios
    : 'ca-app-pub-6495599315568479/1981852541';

class AdState {
  late Future<InitializationStatus> initialization;
  AdState(this.initialization);
  //test ad id
  String get bannerAdUnitId => admobBannerID;

  BannerAdListener get bannerAdListener => _bannerAdListener;
  final BannerAdListener _bannerAdListener = BannerAdListener(
    // Called when an ad is successfully received.
    onAdLoaded: (Ad ad) => print('Ad loaded.'),
    // Called when an ad request failed.
    onAdFailedToLoad: (Ad ad, LoadAdError error) {
      // Dispose the ad here to free resources.
      ad.dispose();
      print('Ad failed to load: $error');
    },
    // Called when an ad opens an overlay that covers the screen.
    onAdOpened: (Ad ad) => print('Ad opened.'),
    // Called when an ad removes an overlay that covers the screen.
    onAdClosed: (Ad ad) => print('Ad closed.'),
    // Called when an impression occurs on the ad.
    onAdImpression: (Ad ad) => print('Ad impression.'),
  );

  BannerAd oneBanner() {
    return BannerAd(
      size: AdSize.banner, //320*50
      adUnitId: bannerAdUnitId,
      listener: bannerAdListener,
      request: AdRequest(),
    )..load();
    //'..load()' execute BannerAd(). '..'call the method, returns the object on which the method was called.
    // ..load() = BannerAd().load();
  }

  void closeAd() {
    oneBanner().dispose();
  }
}
