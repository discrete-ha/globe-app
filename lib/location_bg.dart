import 'package:flutter/cupertino.dart';

class LocationBg extends StatelessWidget{
  final String location;
  LocationBg(this.location);

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 1,
      child:
      new Text(
        location.toUpperCase(),
        style: TextStyle(
          color: Color.fromRGBO(0, 0, 0, 0.1),
          fontSize: 200,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
