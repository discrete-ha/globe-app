import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scatter/flutter_scatter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert' show utf8;
import 'issue.dart';

class WordColud extends StatelessWidget {
  final List<Issue> words;
  List<Widget> widgets = <Widget>[];
  WordColud(this.words);

  @override
  Widget build(BuildContext context) {
    var length =  words.length > 30 ? 30 : words.length;

    var colorBottom = [80, 180, 255];
    var colorTop = [237, 20, 111];

    var diffR = colorBottom[0] - colorTop[0];
    var diffG = colorBottom[1] - colorTop[1];
    var diffB = colorBottom[2] - colorTop[2];
    var tolerance = 1;
    var maximumRawFontSize = words[0].size * tolerance;

    for (var i = 0; i < length; i++) {
      var wordSize = words[i].size * tolerance;
      var fontSize = ( (wordSize * 3).toInt() + 36 )  ;

      var ratio = wordSize / maximumRawFontSize;
      var color = Color.fromRGBO(
          (colorBottom[0] - ( diffR * ratio ) ).toInt() ,
          (colorBottom[1] - ( diffG * ratio ) ).toInt(),
          (colorBottom[2] - ( diffB * ratio ) ).toInt(), 1 );

      widgets.add( CloudItem(words[i].word, color, fontSize.toDouble() ));
    }

    return Scatter(
        fillGaps: false,
        delegate: ArchimedeanSpiralScatterDelegate(ratio: -2, step: 0.02, rotation: 1),
      children:widgets
    );
  }
}

class CloudItem extends StatelessWidget {
  CloudItem(this.word, this.color, this.fontSize);
  String word;
  final Color color;
  final double fontSize;


  @override
  Widget build(BuildContext context) {

    final TextStyle style = Theme.of(context).textTheme.body1.copyWith(
      fontSize: fontSize ,
      color: color
    );
    var encoded = utf8.encode(word);
    var wordDisplay= word;
    if(encoded.length > 30){
      wordDisplay = word.substring(0, 9) + "...";
    }

    return FlatButton(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 5.0),
        child: Text(
            wordDisplay,
            style: style,
            textAlign: TextAlign.center
        ),
        onPressed: (){
          openBrowser(word);
        }
      );
  }
}

openBrowser(String message) async {

  var searchUrl = Uri.encodeFull("https://www.google.co.jp/search?q=${message}&tbs=qdr:d");


  try {
    if (await canLaunch(searchUrl)) {
      await launch(searchUrl);
    }
  } catch(e){
    print(e);
  }
}



