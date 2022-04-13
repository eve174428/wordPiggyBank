import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class WordsData with ChangeNotifier {
  var _index = 0;
  List<String> words = [];
  List<String> rangedWords = [];
  int get wordsLength => words.length;

  void getRange(int from, int to) {
    rangedWords = words.getRange(from - 1, to).toList();
    print('word Range: $rangedWords');
    notifyListeners();
  }

  void cleanWords() {
    _index = 0;
    words.clear();
    notifyListeners();
  }

  String getWord() {
    return rangedWords[_index];
  }

  Future<String> getTranslate(String lang) async {
    final translator = GoogleTranslator();
    String? translated;
    await translator
        .translate(rangedWords[_index], from: 'en', to: lang)
        .then((v) => translated = v.toString());
    if (translated != null) {
      return translated!;
    } else {
      translated = 'network is required';
      return translated!;
    }
  }

  int nextIndex() {
    if (_index < rangedWords.length - 1) {
      _index++;
    } else {
      _index = 0;
    }
    return _index;
  }

  int getIndex() {
    return _index;
  }

  int getLength() {
    return rangedWords.length;
  }

  bool isFinished() {
    if (_index < rangedWords.length - 1) {
      return false;
    } else {
      return true;
    }
  }
}
