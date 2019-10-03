import 'dart:convert';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:globe_app/issue_list.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:globe_app/setting.dart';

class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView>  with WidgetsBindingObserver {

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

//      bottomBanner.load();
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
      print("difference: ${difference}");
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
      print("difference: ${difference}");
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
    return Scaffold( body:!this._isFetching && this.issue != null
        ? IssueList(issue: this.issue)
        : Center(child: CircularProgressIndicator())
    );
  }

  Future<Map<String, double>> _getLocation() async {
    var lastUpdateTime = prefs.getString(LAST_UPDATE_TIME);
    print("_getLocation _lastUpdateTime:"+lastUpdateTime);
    var location = new Location();
    Map<String, double> userLocation;
    userLocation = await location.getLocation();
    return userLocation;
  }

  _parseIssue(String responseBody) {
    final parsed = json.decode(responseBody);
    _setWoeid(parsed["woeid"]);
    setState(() {
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
      var lat = userLocation["latitude"].toString();
      var lon = userLocation["longitude"].toString();
      response = await client.get('${Setting.SERVER_URL}/topics/$API_APPID/$lat/$lon');
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
  adUnitId: Setting.admobUnitId,
  size: AdSize.smartBanner,
  targetingInfo: targetingInfo,
  listener: (MobileAdEvent event) {
    print("BannerAd event is $event");
  },
);

