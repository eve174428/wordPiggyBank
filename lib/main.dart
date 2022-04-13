import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart' as nativeAd;
import 'package:wordPiggyBank/View/loading_page.dart';
import 'package:wordPiggyBank/Controller/score_database.dart';
import 'package:wordPiggyBank/Controller/iap_provider.dart';
import 'package:wordPiggyBank/Controller/ads_state.dart';
import 'package:wordPiggyBank/Controller/words_data.dart';

void main() async {
  //ads
  WidgetsFlutterBinding.ensureInitialized();
  final initFuture = MobileAds.instance.initialize();
  final adState = AdState(initFuture);
  //iap
  if (defaultTargetPlatform == TargetPlatform.android) {
    InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
  }
  //native_admob_flutter
  await nativeAd.MobileAds.initialize(bannerAdUnitId: admobBannerID);
  //iap
  InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
  //add ads provider
  runApp(
    Provider.value(
      value: adState,
      builder: (context, child) => MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ScoreDB>(create: (context) => ScoreDB()),
        ChangeNotifierProvider<DashPurchases>(
            create: (context) => DashPurchases()),
        ChangeNotifierProvider<WordsData>(create: (context) => WordsData()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoadingPage(),
      ),
    );
  }
}
