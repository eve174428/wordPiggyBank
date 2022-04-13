import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wordPiggyBank/Controller/ads_state.dart';
import 'package:wordPiggyBank/View/score_page.dart';
import 'package:wordPiggyBank/View/words_page.dart';
import 'package:wordPiggyBank/Model/const.dart';
import 'package:wordPiggyBank/Model/circular_button_widget.dart';
import 'package:wordPiggyBank/Model/rangeInput_widget.dart';
import 'package:wordPiggyBank/Model/translate.dart';
import 'package:wordPiggyBank/Model/word/basic.dart';
import 'package:wordPiggyBank/Model/word/toeic.dart';
import 'package:wordPiggyBank/Model/word/toefl.dart';
import 'package:wordPiggyBank/Controller/iap_provider.dart';
import 'package:wordPiggyBank/Controller/words_data.dart';

enum Exam {
  toeic,
  toefl,
  basic,
}

class RotationMenuPage extends StatefulWidget {
  @override
  _RotationMenuPageState createState() => _RotationMenuPageState();
}

class _RotationMenuPageState extends State<RotationMenuPage>
    with TickerProviderStateMixin {
  Exam? _selectExam;
  String? _exam;
  String langCode = 'zh-tw';
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: Duration(seconds: 1))
        ..forward();
  late final Animation<double> _animation =
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn);
  //key
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  //slider
  void _showRangeDialog() async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      duration: Duration(seconds: 20),
      content: Consumer<WordsData>(
        builder: (context, wordsData, child) {
          int _min = 1;
          int? _max;
          bool _inputIsValid = true;
          wordsData.cleanWords();
          switch (_selectExam) {
            case Exam.toeic:
              _exam = 'TOEIC';
              toeic.forEach((e) {
                wordsData.words.add(e.toString());
              });
              break;
            case Exam.toefl:
              _exam = 'TOEFL';
              toefl.forEach((e) {
                wordsData.words.add(e.toString());
              });
              break;
            default:
              _exam = 'Basic';
              basic.forEach((e) {
                wordsData.words.add(e.toString());
              });
          }
          int _maxLength = wordsData.words.length;
          return StatefulBuilder(builder: (_, setState) {
            return Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 40.0),
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.15,
                    padding: EdgeInsets.only(
                        top: 40.0, left: 10.0, right: 10.0, bottom: 10.0),
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(color: wordColor, blurRadius: 10.0)
                        ],
                        color: mainColor,
                        borderRadius: BorderRadius.circular(20.0)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              RangeInput(
                                label: 'MIN',
                                error: _inputIsValid
                                    ? null
                                    : '1~${_maxLength - 1}',
                                onChange: (v) {
                                  if (int.parse(v) < 1 ||
                                      int.parse(v) == _maxLength) {
                                    setState(() => _inputIsValid = false);
                                  } else {
                                    setState(() {
                                      _inputIsValid = true;
                                      _min = int.parse(v);
                                    });
                                  }
                                  print(_min);
                                },
                              ),
                              Text('-', style: TextStyle(color: wordColor)),
                              RangeInput(
                                label: 'MAX',
                                error: _inputIsValid
                                    ? null
                                    : '$_min~${_maxLength - 1}',
                                onChange: (v) {
                                  var _temp = v;
                                  if (int.parse(_temp) < _min ||
                                      int.parse(_temp) > _maxLength) {
                                    setState(() => _inputIsValid = false);
                                  } else {
                                    setState(() {
                                      _inputIsValid = true;
                                      _max = int.parse(_temp);
                                    });
                                    print(_max);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: CircularImageButton(
                            size: 0.06,
                            onPressed: () {
                              wordsData.getRange(_min, _max!);
                              ScaffoldMessenger.of(context)
                                  .removeCurrentSnackBar();
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WordsPage(
                                            langCode: langCode,
                                            testName: '$_exam:$_min-$_max',
                                          )));
                            },
                            child: Icon(
                              Icons.play_arrow,
                              size: 30.0,
                              color: wordColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                CircularImageButton(
                  size: 0.1,
                  child: Text(_exam!, style: wordBoldStyle),
                ),
              ],
            );
          });
        },
      ),
    ));
  }

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
    _controller.dispose();
    banner!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var purchases = context.watch<DashPurchases>();
    var products = purchases.products;
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
            child: Builder(
              builder: (_) => Scaffold(
                key: _scaffoldKey,
                endDrawer: Theme(
                  data: Theme.of(context)
                      .copyWith(canvasColor: Colors.transparent),
                  child: Drawer(
                    elevation: 0.0,
                    child: ListView(
                      itemExtent: 42,
                      children: Translate()
                          .languages
                          .map((e) => TextButton(
                                child: Text(
                                  e.lang,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20.0),
                                ),
                                onPressed: () {
                                  setState(() {
                                    langCode = e.code;
                                  });
                                  Navigator.pop(context);
                                },
                              ))
                          .toList(),
                    ),
                  ),
                ),
                appBar: AppBar(
                  elevation: 0.0,
                  leading: IconButton(
                      icon: Icon(Icons.favorite),
                      color: wordColor,
                      onPressed: () async {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        _scaffoldKey.currentState!.openEndDrawer();
                        await banner!.dispose();
                        purchases.buy(products[0]);
                      }),
                  backgroundColor: appbarColor,
                  automaticallyImplyLeading: false,
                  actions: [
                    Builder(
                      builder: (_) => IconButton(
                          icon: Icon(
                            Icons.settings,
                            color: wordColor,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context)
                                .removeCurrentSnackBar();
                            _scaffoldKey.currentState!.openEndDrawer();
                          }),
                    ),
                  ],
                ),
                body: Stack(
                  children: [
                    Container(
                      decoration: gradientBgImage,
                      child: ScaleTransition(
                        scale: _animation,
                        child: RotationTransition(
                          turns: _animation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularImageButton(
                                size: 0.1,
                                onPressed: () {
                                  setState(() {
                                    _selectExam = Exam.basic;
                                  });
                                  _showRangeDialog();
                                },
                                child: Text('Basic', style: wordBoldStyle),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  CircularImageButton(
                                    size: 0.1,
                                    onPressed: () {
                                      setState(() {
                                        _selectExam = Exam.toeic;
                                      });
                                      _showRangeDialog();
                                    },
                                    child: Text('TOEIC', style: wordBoldStyle),
                                  ),
                                  CircularImageButton(
                                    size: 0.1,
                                    onPressed: () {
                                      setState(() {
                                        _selectExam = Exam.toefl;
                                      });
                                      _showRangeDialog();
                                    },
                                    child: Text('TOEFL', style: wordBoldStyle),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                        bottom: MediaQuery.of(_).viewInsets.bottom,
                        left: MediaQuery.of(_).size.width * 0.5,
                        child: IconButton(
                            onPressed: () => Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (_) => ScorePage())),
                            icon: Transform(
                                transform: Matrix4.rotationY(pi),
                                child: Icon(Icons.savings, color: wordColor)))),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
