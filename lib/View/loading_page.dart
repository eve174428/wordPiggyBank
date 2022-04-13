import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:wordPiggyBank/Model/const.dart';
import 'package:wordPiggyBank/View/menu_page.dart';
import 'package:wordPiggyBank/Controller/score_database.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    getMenuPage();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await context.watch<ScoreDB>().openDB();
  }

  void getMenuPage() {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => RotationMenuPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: gradientBgImage,
        child: Stack(
          children: [
            Center(
                child: Image.asset(
              'assets/logo.png',
              scale: 0.1,
              width: MediaQuery.of(context).size.width * 0.8,
            )),
            SpinKitSpinningCircle(
              duration: Duration(seconds: 3),
              color: Colors.orange,
              size: 50.0,
            ),
          ],
        ),
      ),
    );
  }
}
