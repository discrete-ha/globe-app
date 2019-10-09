import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:globe_app/issue_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';

class LocationCards extends StatelessWidget{
  SharedPreferences prefs;
  String jsonStringConfig;
  List<Map<String,dynamic>> issues;
  final String LAST_UPDATE_TIME = "LAST_UPDATE_TIME";
  final String LOCAL_WOEID = "LOCAL_WOEID";
  final String LOCAL_WOEID_TIME = "LOCAL_WOEID_TIME";
  String cityName = "";

  LocationCards(this.issues, this.jsonStringConfig, this.prefs);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    var cardWidth = size.height <= size.width*1.5 ? size.width * 0.5 :(size.width * 0.9);
    var cardHeight = size.height;

    var wordCloudRatio = (cardHeight/cardWidth).toDouble();

    var offsetVertical = 30.0;
    var offsetSide = (cardWidth + offsetVertical);
    var cardsCount = this.issues.length;
    var stateCount = this.issues.length >= 3 ? 3 : this.issues.length;
    var startIndex = 1;

    var rotateSetting = {
      0:0.0,
      2:25.0/180,
      1:-25.0/180
    };

    var translateSetting = {
      0:new Offset(0, 0.0),
      1:new Offset(offsetSide, -offsetVertical),
      2:new Offset(-offsetSide, -offsetVertical)
    };

    List<double> rotateArray = [];

    List<Offset> translateArray = [];

    for(var i=0; i<stateCount; i++){
      rotateArray.add(rotateSetting[i]);
      translateArray.add(translateSetting[i]);
    }

    var iconPrevious = stateCount == 1 ? null : Icons.arrow_back_ios ;
    var iconNext = stateCount <= 2 ? null : Icons.arrow_forward_ios;

    return Container(
        color: Colors.grey,
        child:Padding(
            padding: EdgeInsets.only(bottom:100.0),
            child: new Swiper(
                layout: SwiperLayout.CUSTOM,
                customLayoutOption: new CustomLayoutOption(
                    startIndex: startIndex,
                    stateCount: cardsCount
                ).addRotate(rotateArray)
                    .addTranslate(translateArray),
                itemWidth: cardWidth,
                itemHeight: cardHeight,
                itemBuilder: ( context, index ) {
                  return Padding(
                      padding: EdgeInsets.fromLTRB(5.0,5.0,5.0,15.0),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(40.0),
                          child: IssueList(
                              issue: this.issues[index],
                              ratio: wordCloudRatio
                          )
                      )
                  );
                },
                pagination: new SwiperPagination(
                  builder: new DotSwiperPaginationBuilder(
                      color: Colors.grey[300],
                      activeColor: Color.fromRGBO(80, 180, 255, 100)
                  ),
                  margin: const EdgeInsets.only(bottom:0.0),
                ),
                control: new SwiperControl(
                  iconPrevious: iconPrevious,
                  iconNext: iconNext,
                  color:Colors.grey[300],
                  padding:EdgeInsets.all(0),
                ),
                itemCount: stateCount)
        )
    );
  }
}


