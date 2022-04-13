import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';
import 'package:show_more_text_popup/show_more_text_popup.dart';
import 'dart:math';
import 'dart:io';
import 'package:wordPiggyBank/Controller/words_data.dart';
import 'package:wordPiggyBank/Controller/score_database.dart';
import 'package:wordPiggyBank/Controller/dictionary_api.dart';
import 'package:wordPiggyBank/View/score_page.dart';
import 'package:wordPiggyBank/Model/circular_button_widget.dart';
import 'package:wordPiggyBank/Model/const.dart';

class WordsPage extends StatefulWidget {
  final String? langCode;
  final String? testName;
  @override
  _WordsPageState createState() => _WordsPageState();
  WordsPage({@required this.langCode, @required this.testName});
}

class _WordsPageState extends State<WordsPage> {
  //word
  late String langCode = widget.langCode!;
  late String testName = widget.testName!;
  String? engWord;
  String? translate;
  //database
  int score = 0;
  String time = DateTime.now().toString().substring(0, 16);
  String? answer;
  bool isRight = false;
  //device language
  String deviceLang = Platform.localeName;

  //Native Ads
  BannerAdController bannerController = BannerAdController();
  @override
  void initState() {
    super.initState();
    //ads
    bannerController.onEvent.listen((e) {
      final event = e.keys.first;
      switch (event) {
        case BannerAdEvent.loaded:
          break;
        default:
          break;
      }
    });
    bannerController.load();
  }

  @override
  void didChangeDependencies() async {
    WordsData wordsData = Provider.of(context, listen: false);
    engWord = wordsData.getWord();
    translate = await wordsData.getTranslate(langCode);
    super.didChangeDependencies();
    await _pronounce();
  }

  //audio
  final AudioPlayer player = AudioPlayer();
  Future<void> _pronounce() async {
    dynamic audioData = await DicApi().getWordData(engWord!);
    if (audioData != null) {
      await player.setUrl('https:' + audioData[0]['phonetics'][0]['audio']);
      await player.play();
    }
  }

  //coin
  void _showCoin() => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        content: Transform.scale(
          scale: 0.2,
          child: Image.asset(
            'assets/coin.png',
          ),
        ),
        duration: Duration(milliseconds: 450),
        onVisible: () {
          Future.delayed(Duration(milliseconds: 430), () {
            player.setAsset('assets/coin_sound_effect.mp3');
            player.play();
          });
        },
      ));
  //Answer
  Future<void> _showFutureInput() async {
    await Future.delayed(Duration(seconds: 6), () {
      return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        duration: Duration(minutes: 120),
        content: Consumer2<ScoreDB, WordsData>(
            builder: (context, scoreDB, wordsData, child) {
          // tip popup
          GlobalKey key = GlobalKey();
          ShowMoreTextPopup pop = ShowMoreTextPopup(
            context,
            padding: EdgeInsets.all(4.0),
            text: engWord,
            height: 40.0,
            width: 100.0,
            textStyle: TextStyle(color: Colors.white),
          );

          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 40.0),
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 2.0),
                ], color: mainColor, borderRadius: BorderRadius.circular(20.0)),
                padding: EdgeInsets.only(right: 30.0, left: 30.0, top: 30.0),
                height: MediaQuery.of(context).size.height * 0.2,
                child: TextFormField(
                  decoration: InputDecoration(
                    focusColor: wordColor,
                    labelStyle: TextStyle(
                        color: wordColor.withOpacity(0.5),
                        fontSize: 20.0,
                        fontFamily: 'Schoolbell'),
                    hintStyle: TextStyle(fontSize: 16.0),
                    suffixIcon: IconButton(
                      key: key,
                      onPressed: () => pop.show(widgetKey: key),
                      icon: Icon(
                        Icons.lightbulb,
                        color: wordColor.withOpacity(0.5),
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                    labelText: translate,
                    filled: true,
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xffAE781D))),
                  ),
                  cursorColor: Color(0xffAE781D),
                  maxLength: engWord!.length,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: wordColor,
                      fontSize: 25.0,
                      fontFamily: 'Schoolbell'),
                  autofocus: true,
                  onChanged: (v) {
                    answer = v;
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircularImageButton(
                    size: 0.1,
                    onPressed: () async {
                      TestResult result = TestResult(
                        testName: testName,
                        time: time,
                        score: score,
                      );
                      await scoreDB.insertScoreTb(result);
                      FocusManager.instance.primaryFocus?.unfocus();
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => ScorePage()));
                    },
                    child: Transform(
                      origin: Offset(17.0, 0.0),
                      transform: Matrix4.rotationY(pi),
                      child: Icon(
                        Icons.savings,
                        color: wordColor,
                        size: 35.0,
                      ),
                    ),
                  ),
                  CircularImageButton(
                    size: 0.1,
                    onPressed: () async {
                      if (answer == engWord) {
                        score++;
                        _showCoin();
                      }
                      wordsData.nextIndex();
                      if (wordsData.getIndex() != 0) {
                        translate = await wordsData.getTranslate(langCode);
                        setState(() {
                          engWord = wordsData.getWord();
                        });
                        _pronounce();
                        FocusManager.instance.primaryFocus?.unfocus();
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      } else {
                        TestResult result = TestResult(
                          testName: testName,
                          time: time,
                          score: score,
                        );
                        await scoreDB.insertScoreTb(result);
                        FocusManager.instance.primaryFocus?.unfocus();
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ScorePage()));
                      }
                    },
                    child: Icon(
                      Icons.play_arrow,
                      color: wordColor,
                      size: 50.0,
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ));
    });
  }

  @override
  void dispose() {
    bannerController.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WordsData wordsData = context.watch<WordsData>();
    return SafeArea(
        child: Column(
      children: [
        BannerAd(controller: bannerController, size: BannerSize.BANNER),
        Builder(
            builder: (_) => Expanded(
                  child: Scaffold(
                    appBar: AppBar(
                      automaticallyImplyLeading: false,
                      backgroundColor: appbarColor,
                      elevation: 0.0,
                      title: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 7.0,
                          showValueIndicator: ShowValueIndicator.always,
                          valueIndicatorColor: Colors.orange[700],
                          thumbColor: Colors.orange[700],
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 8.0),
                          inactiveTrackColor: Colors.white.withOpacity(0.5),
                          activeTrackColor: Colors.orange[700],
                        ),
                        child: Slider(
                          value: ((wordsData.getIndex() + 1) /
                              wordsData.getLength()),
                          onChanged: (v) => null,
                          label: (wordsData.getIndex() + 1).toString(),
                        ),
                      ),
                    ),
                    body: Container(
                      decoration: gradientBgImage,
                      child: Column(
                        children: [
                          Expanded(
                            flex: 8,
                            child: Center(
                              child: FutureBuilder(
                                future: _showFutureInput(),
                                builder:
                                    (context, AsyncSnapshot<dynamic> snapshot) {
                                  return Word(engWord!);
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                                child: Text(
                              '\$ ' + score.toString(),
                              style: wordBoldStyle.copyWith(
                                  fontSize: 20.0, fontFamily: 'Schoolbell'),
                            )),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
      ],
    ));
  }
}

class Word extends StatefulWidget {
  final String engWord;
  @override
  _WordState createState() => _WordState();
  Word(this.engWord);
}

class _WordState extends State<Word> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..repeat(reverse: true);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          widget.engWord,
          style:
              wordBoldStyle.copyWith(fontSize: 50.0, fontFamily: 'Schoolbell'),
        ),
      ),
    );
  }
}
