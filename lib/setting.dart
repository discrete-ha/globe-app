import 'dart:io';

class Setting {
  static final String SERVER_URL = "http://ec2-52-196-52-243.ap-northeast-1.compute.amazonaws.com:3000";
  static final String admobUnitIdTest = Platform.isAndroid ? 'ca-app-pub-3940256099942544/6300978111' : 'ca-app-pub-3940256099942544/2934735716';
//  static final String admobAppId = Platform.isAndroid ? 'ca-app-pub-9623769649834685~7994032794' : 'ca-app-pub-9623769649834685~3207957973';
//  static final String admobUnitId = Platform.isAndroid ? 'ca-app-pub-9623769649834685/2550134426' : 'ca-app-pub-9623769649834685/6380916226';
  static final String admobAppId = Platform.isAndroid ? 'ca-app-pub-3304304215047232~8077017567' : 'ca-app-pub-3304304215047232~8077017567';
  static final String admobUnitId = Platform.isAndroid ? 'ca-app-pub-3304304215047232/5259282534' : 'ca-app-pub-3304304215047232/5259282534';
}