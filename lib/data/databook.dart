import 'dart:convert';
import 'package:flutter/services.dart';
import '../bookmodel.dart';
class  Data {
  Future<List<DataBook>> loadAllDataJson() async {
    List<DataBook> allWords = [];
    final letters = 'abcdefghijklmnopqrstuvwxyz'.split('');
    for (String letter in letters) {
      try {
        final String path = 'data/json_new/$letter.json';

        final String response = await rootBundle.loadString(path);
        final List<dynamic> data = jsonDecode(response);

        List<DataBook> currentLetterWords = data
            .map((json) => DataBook.fromJson(json))
            .toList();
        allWords.addAll(currentLetterWords);
      } catch (e) {}
    }

    return allWords;
  }
}
