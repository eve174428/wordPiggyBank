// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:native_admob_flutter/native_admob_flutter.dart';
// import 'dart:io';
// import 'package:wordPiggyBank/Controller/score_database.dart';
// import 'package:wordPiggyBank/Controller/dictionary_api.dart';
// import 'package:wordPiggyBank/View/score_page.dart';
// import 'package:wordPiggyBank/Model/circular_button_widget.dart';
// import 'package:wordPiggyBank/Model/const.dart';
//
// class TofelPage extends StatefulWidget {
//   final int? start;
//   final int? end;
//   @override
//   _TofelPageState createState() => _TofelPageState();
//   TofelPage({@required this.start, @required this.end});
// }
//
// class _TofelPageState extends State<TofelPage> {
//   //word
//   late int start = widget.start!;
//   late int end = widget.end!;
//   late ToeicData wordDB = ToeicData(from: start, to: end);
//   late String engWord = wordDB.getTOEIC();
//   String? translate;
//   //database
//   int score = 0;
//   String time = DateTime.now().toString().substring(0, 16);
//   late String testName = 'TOEIC : ' + start.toString() + '-' + end.toString();
//   String? answer;
//   bool isRight = false;
//   //device language
//   String deviceLang = Platform.localeName;
//   //audio
//   final AudioPlayer player = AudioPlayer();
//   Future<void> _pronounce() async {
//     dynamic audioData = await DicApi().getWordData(engWord);
//     if (audioData != null) {
//       await player.setUrl('https:' + audioData[0]['phonetics'][0]['audio']);
//       await player.play();
//     }
//   }
//
//   //Native Ads
//   BannerAdController bannerController = BannerAdController();
//   @override
//   void initState() {
//     super.initState();
//     bannerController.onEvent.listen((e) {
//       final event = e.keys.first;
//       switch (event) {
//         case BannerAdEvent.loaded:
//           break;
//         default:
//           break;
//       }
//     });
//     if (Platform.isAndroid) {
//       bannerController.load();
//     }
//     print(deviceLang);
//   }
//
//   @override
//   void didChangeDependencies() async {
//     super.didChangeDependencies();
//     await _pronounce();
//     translate = await wordDB.getTranslate('zh-tw');
//   }
//
//   void _showCoin() => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0.0,
//         content: Transform.scale(
//           scale: 0.2,
//           child: Image.asset(
//             'assets/coin.png',
//           ),
//         ),
//         duration: Duration(milliseconds: 450),
//         onVisible: () {
//           Future.delayed(Duration(milliseconds: 430), () {
//             player.setAsset('assets/coin_sound_effect.mp3');
//             player.play();
//           });
//         },
//       ));
//
//   Future<void> _futureDialog() => Future.delayed(Duration(seconds: 4), () {
//         ScoreDB scoreDb = Provider.of<ScoreDB>(context, listen: false);
//         return showGeneralDialog(
//             barrierColor: Colors.black.withOpacity(0.1),
//             transitionBuilder: (context, a1, a2, widget) {
//               return Transform.scale(
//                 scale: a1.value,
//                 child: Opacity(
//                   opacity: a1.value,
//                   child: AlertDialog(
//                     elevation: 0.0,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20.0)),
//                     backgroundColor: Colors.transparent,
//                     actions: [
//                       Stack(
//                         alignment: Alignment.bottomCenter,
//                         children: [
//                           Column(
//                             children: [
//                               Platform.isAndroid
//                                   ? BannerAd(
//                                       controller: bannerController,
//                                       size: BannerSize.BANNER)
//                                   : SizedBox(),
//                               Container(
//                                 decoration: BoxDecoration(
//                                     color: mainColor,
//                                     borderRadius: BorderRadius.circular(20.0)),
//                                 padding: EdgeInsets.symmetric(horizontal: 30.0),
//                                 height:
//                                     MediaQuery.of(context).size.height * 0.2,
//                                 child: Center(
//                                   child: TextFormField(
//                                     decoration: InputDecoration(
//                                       focusColor: wordColor,
//                                       labelStyle: TextStyle(
//                                           color: wordColor.withOpacity(0.5),
//                                           fontSize: 20.0,
//                                           fontFamily: 'Schoolbell'),
//                                       suffixIcon: Icon(
//                                         Icons.edit,
//                                         color: wordColor.withOpacity(0.5),
//                                       ),
//                                       contentPadding:
//                                           EdgeInsets.symmetric(horizontal: 8.0),
//                                       labelText: translate,
//                                       filled: true,
//                                       focusedBorder: UnderlineInputBorder(
//                                           borderSide: BorderSide(
//                                               color: Color(0xffAE781D))),
//                                     ),
//                                     cursorColor: Color(0xffAE781D),
//                                     maxLength: engWord.length,
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                         color: wordColor,
//                                         fontSize: 25.0,
//                                         fontFamily: 'Schoolbell'),
//                                     autofocus: false,
//                                     onChanged: (v) {
//                                       answer = v;
//                                     },
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: 40),
//                             ],
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             children: [
//                               CircularImageButton(
//                                 size: 0.1,
//                                 onPressed: () async {
//                                   TestResult result = TestResult(
//                                     testName: testName,
//                                     time: time,
//                                     score: score,
//                                   );
//                                   await scoreDb.insertScoreTb(result);
//                                   FocusManager.instance.primaryFocus?.unfocus();
//                                   Navigator.pushReplacement(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) => ScorePage()));
//                                 },
//                                 child: Icon(
//                                   Icons.savings,
//                                   color: wordColor,
//                                   size: 35.0,
//                                 ),
//                               ),
//                               CircularImageButton(
//                                 size: 0.1,
//                                 onPressed: () async {
//                                   if (answer == engWord) {
//                                     score++;
//                                     _showCoin();
//                                   }
//                                   wordDB.nextIndex();
//                                   if (wordDB.getIndex() != 0) {
//                                     translate =
//                                         await wordDB.getTranslate('zh-tw');
//                                     setState(() {
//                                       engWord = wordDB.getTOEIC();
//                                     });
//                                     _pronounce();
//                                     FocusManager.instance.primaryFocus
//                                         ?.unfocus();
//                                     Navigator.pop(context);
//                                   } else {
//                                     TestResult result = TestResult(
//                                       testName: testName,
//                                       time: time,
//                                       score: score,
//                                     );
//                                     await scoreDb.insertScoreTb(result);
//                                     FocusManager.instance.primaryFocus
//                                         ?.unfocus();
//                                     Navigator.pushReplacement(
//                                         context,
//                                         MaterialPageRoute(
//                                             builder: (context) => ScorePage()));
//                                   }
//                                 },
//                                 child: Icon(
//                                   Icons.play_arrow,
//                                   color: wordColor,
//                                   size: 50.0,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               );
//             },
//             transitionDuration: Duration(milliseconds: 200),
//             barrierDismissible: false,
//             barrierLabel: '',
//             context: context,
//             pageBuilder: (context, animation1, animation2) => Text('nothing'));
//       });
//
//   @override
//   void dispose() {
//     bannerController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//         child: Column(
//       children: [
//         SizedBox(
//           height: 50.0,
//         ),
//         Builder(
//             builder: (_) => Expanded(
//                   child: Scaffold(
//                     appBar: AppBar(
//                       automaticallyImplyLeading: false,
//                       backgroundColor: appbarColor,
//                       elevation: 0.0,
//                       title: SliderTheme(
//                         data: SliderTheme.of(context).copyWith(
//                           trackHeight: 7.0,
//                           showValueIndicator: ShowValueIndicator.always,
//                           valueIndicatorColor: Colors.orange[700],
//                           thumbColor: Colors.orange[700],
//                           thumbShape:
//                               RoundSliderThumbShape(enabledThumbRadius: 8.0),
//                           inactiveTrackColor: Colors.white.withOpacity(0.5),
//                           activeTrackColor: Colors.orange[700],
//                         ),
//                         child: Slider(
//                           value: ((wordDB.getIndex() + 1) / wordDB.getLength()),
//                           onChanged: (v) {},
//                           label: wordDB.getIndex().toString(),
//                         ),
//                       ),
//                     ),
//                     body: Container(
//                       decoration: gradientBgImage,
//                       child: Column(
//                         children: [
//                           Expanded(
//                             flex: 8,
//                             child: Center(
//                               child: FutureBuilder(
//                                 future: _futureDialog(),
//                                 builder:
//                                     (context, AsyncSnapshot<dynamic> snapshot) {
//                                   return Word(engWord);
//                                 },
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                             child: Center(
//                                 child: Text(
//                               '\$ ' + score.toString(),
//                               style: wordBoldStyle.copyWith(
//                                   fontSize: 20.0, fontFamily: 'Schoolbell'),
//                             )),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 )),
//       ],
//     ));
//   }
// }
//
// class Word extends StatefulWidget {
//   final String engWord;
//   @override
//   _WordState createState() => _WordState();
//   Word(this.engWord);
// }
//
// class _WordState extends State<Word> with TickerProviderStateMixin {
//   late final AnimationController _controller = AnimationController(
//     duration: const Duration(seconds: 1),
//     vsync: this,
//   )..repeat(reverse: true);
//   late final Animation<double> _animation = CurvedAnimation(
//     parent: _controller,
//     curve: Curves.fastOutSlowIn,
//   );
//
//   @override
//   void dispose() {
//     super.dispose();
//     _controller.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ScaleTransition(
//       scale: _animation,
//       child: Padding(
//         padding: EdgeInsets.all(8.0),
//         child: Text(
//           widget.engWord,
//           style:
//               wordBoldStyle.copyWith(fontSize: 50.0, fontFamily: 'Schoolbell'),
//         ),
//       ),
//     );
//   }
// }
