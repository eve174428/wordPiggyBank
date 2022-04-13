import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wordPiggyBank/Controller/ads_state.dart';
import 'package:wordPiggyBank/Model/const.dart';
import 'package:wordPiggyBank/View/menu_page.dart';
import 'package:wordPiggyBank/Controller/score_database.dart';

class ScorePage extends StatefulWidget {
  const ScorePage({Key? key}) : super(key: key);

  @override
  _ScorePageState createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  // google_mobile_ads
  BannerAd? banner;
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    final AdState adState = context.watch<AdState>();
    adState.initialization.then((v) {
      setState(() {
        banner = adState.oneBanner();
      });
    });
  }

  @override
  void dispose() {
    banner!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          banner == null
              ? SizedBox()
              : Container(
                  height: 50.0,
                  width: MediaQuery.of(context).size.width,
                  child: AdWidget(ad: banner!),
                ),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(
                    Icons.home,
                    color: wordColor,
                  ),
                  onPressed: () => Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => RotationMenuPage())),
                ),
                elevation: 0.0,
                backgroundColor: appbarColor,
                actions: [
                  IconButton(
                      onPressed: () async {
                        await Provider.of<ScoreDB>(context, listen: false)
                            .deleteScoreTb();
                      },
                      icon: Icon(
                        Icons.delete_forever,
                        color: wordColor,
                      ))
                ],
              ),
              body: Container(
                decoration: gradientBgImage,
                child: Container(
                  margin: EdgeInsets.only(
                      right: 20.0,
                      left: 20.0,
                      bottom: MediaQuery.of(context).size.height * 0.1),
                  child: Consumer<ScoreDB>(
                    builder: (context, scoreDb, child) {
                      List<TestResult> _scores = scoreDb.scoreList;
                      return FutureBuilder(
                        future: scoreDb.queryScoreTb(),
                        builder: (context, AsyncSnapshot<dynamic> snapshot) {
                          if (snapshot.hasData) {
                            _scores = snapshot.data;
                          }
                          return ListWheelScrollView.useDelegate(
                            itemExtent: 60,
                            childDelegate: ListWheelChildBuilderDelegate(
                              builder: (context, i) {
                                if (i < 0 || i > _scores.length - 1) {
                                  return null;
                                }
                                return ListTile(
                                  leading: Text(
                                    _scores[i].time!.substring(0, 10) +
                                        '\n' +
                                        _scores[i].time!.substring(11),
                                    textAlign: TextAlign.center,
                                    style: wordBoldStyle,
                                  ),
                                  title: Text(
                                    _scores[i].testName!,
                                    style: wordBoldStyle,
                                  ),
                                  trailing: Text(
                                    '💰 ' + _scores[i].score!.toString(),
                                    style: boldFont.copyWith(color: wordColor),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
