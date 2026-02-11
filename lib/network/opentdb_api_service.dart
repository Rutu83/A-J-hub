
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';


getQuiz() async {
  var res = await rootBundle.loadString('assets/qution.json');
    var data = jsonDecode(res);
    if (kDebugMode) {
      print("Data is loaded $data");
    }
    return data;

}

