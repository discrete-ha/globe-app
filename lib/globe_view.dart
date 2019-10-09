import 'dart:convert';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:globe_app/issue_list.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:globe_app/setting.dart';

import 'location_cards.dart';

class GlobeView extends StatefulWidget {
  @override
  _GlobeViewState createState() => _GlobeViewState();
}

class _GlobeViewState extends State<GlobeView>  with WidgetsBindingObserver {

  var _updateLimitSeconds = 30;
  var _updateWoeidLimitSeconds = 300;

  DateTime _lastUpdateTime;
  bool _isFetching = true;
  SharedPreferences prefs;
  String jsonStringConfig;
  Map<String,dynamic> issue;
  final String LAST_UPDATE_TIME = "LAST_UPDATE_TIME";
  final String LOCAL_WOEID = "LOCAL_WOEID";
  final String LOCAL_WOEID_TIME = "LOCAL_WOEID_TIME";
  String cityName = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    (() async {
      jsonStringConfig = await _loadConfig();
        this.prefs = await SharedPreferences.getInstance();
      _fetchIssue(http.Client());
      FirebaseAdMob.instance.initialize(appId: Setting.admobAppId);

      bottomBanner
        ..load()
        ..show(
          anchorOffset: 0.0,
          anchorType: AnchorType.bottom,
        );

    })();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool _checkCacheTime(){
    if(_lastUpdateTime != null){
      final date = DateTime.now();
      final difference = date.difference(_lastUpdateTime).inSeconds;
      if(difference > _updateLimitSeconds){
        return true;
      }
      return false;
    }else{
      return false;
    }
  }

  _saveUpdateTime() {
    _lastUpdateTime = DateTime.now();
    prefs.setString(LAST_UPDATE_TIME, DateTime.now().toString());
  }

  String _getWoeid(){
    var updateTime = prefs.getString(LOCAL_WOEID_TIME);
    if(updateTime != null){

      var now = DateTime.now();
      final difference = now.difference( DateTime.parse(updateTime) ).inSeconds;
      if(difference < _updateWoeidLimitSeconds){
        return prefs.getString(LOCAL_WOEID);
      }else{
        return null;
      }
    }else{
      return null;
    }
  }

  _setWoeid(woeid){
    var updateTime = prefs.getString(LOCAL_WOEID_TIME);
    if(updateTime != null){
      var now = DateTime.now();
      final difference = now.difference( DateTime.parse(updateTime) ).inSeconds;
      if(difference >= _updateWoeidLimitSeconds){
        prefs.setString(LOCAL_WOEID, woeid);
        prefs.setString(LOCAL_WOEID_TIME, now.toString());
      }
    }
  }

  void reloadData(){
    print("reloadData()");
    if (_checkCacheTime()){
      setState(() {
        this.issue = null;
        this._isFetching = true;
      });
      _fetchIssue(http.Client());
    }
  }

  @override
  Future didChangeAppLifecycleState(AppLifecycleState state) async {
    switch(state){
      case AppLifecycleState.resumed:
        reloadData();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.suspending:
        break;
    }
  }

  Future<String> _loadConfig() async {
    return await rootBundle.loadString('assets/config.json');
  }

  @override
  Widget build(BuildContext context) {
    print("_MainViewState build()");

    PreferredSize appBar = PreferredSize(
        preferredSize: Size.fromHeight(40.0),
        child: AppBar(
          iconTheme: IconThemeData(color: Colors.grey[600] ),
          title: Text(
              cityName,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700]
              )
          ),
          actions: <Widget>[
            new IconButton(
            color: Colors.grey[700],
              icon:
            new Icon(
                Icons.add,size: 25.0
            ),
              tooltip: 'Add Location',
              onPressed: () => {

              }, )
          ],
          backgroundColor: Colors.white,
          centerTitle: true,
        )
    );

    var locationCards = new LocationCards([this.issue], this.jsonStringConfig, this.prefs);

    return Scaffold(
        appBar: appBar,
//        drawer: Drawer(),
        body:!this._isFetching && this.issue != null
        ? locationCards : Center(child: CircularProgressIndicator())
    );
  }

  Future<Map<String, double>> _getLocation() async {
    var lastUpdateTime = prefs.getString(LAST_UPDATE_TIME);
    print("_getLocation _lastUpdateTime:"+lastUpdateTime);
    var location = new Location();

    try {
      Map<String, double> userLocation;
      userLocation = await location.getLocation();
      return userLocation;
    } catch (e) {
      return null;
    }
  }

  _parseIssue(String responseBody) {
    final parsed = json.decode(responseBody);
    print(parsed);
    _setWoeid(parsed["woeid"]);
    setState(() {
      this.cityName =  parsed["location"] == "Worldwide" ?parsed["location"] : parsed["location"]  + ", " + parsed["country"];
      this._isFetching = false;
      this.issue = parsed;
    });
  }

  Future<Map<String,dynamic>> _fetchIssue(http.Client client) async {
    _saveUpdateTime();

    final CONFIG = json.decode(jsonStringConfig);
    var API_APPID = CONFIG['API_APPID'];
    var response;
    var woeid = _getWoeid();
    print("_getWoeid: ${woeid}");

    if(woeid == null){
      Map<String, double> userLocation = await _getLocation();
      if(userLocation == null){
        woeid = "1";
        response = await client.get('${Setting.SERVER_URL}/topics/$API_APPID/$woeid');
      }else{
        var lat = userLocation["latitude"].toString();
        var lon = userLocation["longitude"].toString();
        response = await client.get('${Setting.SERVER_URL}/topics/$API_APPID/$lat/$lon');
      }
    }else{
      response = await client.get('${Setting.SERVER_URL}/topics/$API_APPID/$woeid');
    }

    _parseIssue( response.body );
  }
}

MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  keywords: <String>['flutterio', 'beautiful apps'],
  contentUrl: 'https://flutter.io',
  childDirected: false,
  designedForFamilies: false,
  testDevices: <String>[], // Android emulators are considered test devices
);

BannerAd bottomBanner = BannerAd(
  adUnitId: Setting.admobUnitIdTest,
  size: AdSize.largeBanner,
  targetingInfo: targetingInfo,
  listener: (MobileAdEvent event) {
    print("BannerAd event is $event");
  },
);

