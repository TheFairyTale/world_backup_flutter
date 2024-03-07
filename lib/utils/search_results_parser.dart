import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_demo/models/search_result.dart';

class SearchResultsParser {
  Future<List<SearchResult>> parseInBackground(String encodedJson) {
    // compute spawns an isolate, runs a callback on that isolate, and returns a Future with the result
    // compute是dart中为我们封装好的快速使用isolate 的方法
    return compute(_decodeAndParseJson, encodedJson);
  }

  List<SearchResult> _decodeAndParseJson(String encodedJson) {
    final jsonData = jsonDecode(encodedJson);
    final resultsJson = jsonData['results'] as List<dynamic>;
    return resultsJson.map((json) => SearchResult.fromJson(json)).toList();
  }
}
