//
//class Issue {
//  List<Topic> topics;
//  int totalPoint;
//  String location;
//
//  Issue({this.topics, this.totalPoint, this.location});
//
//  factory Issue.fromJson(Map<String, dynamic> json) {
//    return Issue(
//      topics: json['id'] as List<Topic>,
//      totalPoint: json['title'] as int,
//      location: json['thumbnailUrl'] as String,
//    );
//  }
//}
//
//class Topic{
//  int point;
//  String word;
//}

import 'dart:math';
import 'dart:ui';

import 'package:flutter/painting.dart';

class Issue {
  const Issue(
      this.word,
      this.size,
      this.rotated,
      );
  final String word;
  final int size;
  final bool rotated;
}
