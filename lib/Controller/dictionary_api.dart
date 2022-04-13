import 'dart:convert';
import 'package:http/http.dart' as http;

const host = 'api.dictionaryapi.dev';
const path = '/api/v2/entries/en_US';

class DicApi {
  Future<dynamic> getWordData(String word) async {
    // Map<String, dynamic> queryParameters = {
    //   'word': word,
    // };
    //http
    var url = Uri.https(host, path + '/' + word);
    http.Response response = await http.get(url);
    if (response.statusCode == 200) {
      dynamic data = jsonDecode(response.body);
      return data;
    } else {
      print(response.statusCode);
    }
  }
}
