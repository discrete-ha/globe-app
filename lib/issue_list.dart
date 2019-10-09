import 'package:flutter/material.dart';
import 'package:globe_app/issue.dart';
import 'package:globe_app/location_bg.dart';
import 'package:globe_app/word_cloud.dart';

class IssueList extends StatelessWidget {
  final Map<String, dynamic> issue;
  final double ratio;

  IssueList({Key key, this.issue, this.ratio}) : super(key: key);

  List<Issue> generateIssueWords(rawIssues){
    List<Issue> resIssueWords = [];
    rawIssues["topics"].forEach((issue){
      int defalutPoint = issue["point"].toInt();
      rawIssues["totalPoint"] = rawIssues["totalPoint"] == 0 ? 1 :rawIssues["totalPoint"];
      int point = ( defalutPoint / rawIssues["totalPoint"] * 100 ).toInt();
      resIssueWords.add( Issue(issue["word"], point , false) );
    });
    return resIssueWords;
  }

  @override
  Widget build(BuildContext context) {
    print("IssueList build()");
    List<Issue> issueWords = generateIssueWords(this.issue);
    var location = this.issue['location'];
    var countryCode = this.issue['countryCode'];

    return new Listener(
        onPointerDown: (e) {
          print("down");
        },
        onPointerUp: (e) {
          print("up");
        },
        child:new Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20.0),
                  child: Center(
                    child:
                    new Stack(
                      children: [
                        Center(
                            child: FittedBox(
                                fit: BoxFit.contain,
                                child: LocationBg(location)
                            )
                        ),
                        Center(
                          child:FittedBox(
                              child: WordColud(issueWords, countryCode, this.ratio)
                          ),
                        )],
                    ),
                  )
              )
          ),
    );
  }
}