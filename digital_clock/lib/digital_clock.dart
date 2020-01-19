// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flare_flutter/flare_actor.dart';

enum _Element {
  background,
  text,
  shadow,
}

final _lightTheme = {
  _Element.background: Color(0xFF81B3FE),
  _Element.text: Colors.white,
  _Element.shadow: Colors.black,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white,
  _Element.shadow: Color(0xFF174EA6),
};

/// A basic digital clock.
///
/// You can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  List<Color> sunny = [Colors.lightBlue[400], Colors.lightBlue[200]];
  List<Color> cloudy = [Colors.blueGrey[600], Colors.blueGrey[400]];
  List<Color> rainy = [Colors.blueGrey[700], Colors.blueGrey[500]];
  List<Color> foggy = [Colors.blueGrey[900], Colors.blueGrey[700]];
  List<Color> snowy = [Colors.blueGrey[300], Colors.blueGrey[200]];
  List<Color> night = [Colors.black, Colors.black38];

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  Widget scene(
      List<Color> background,
      Color textColor,
      String topRight,
      String topRightAnimation,
      String trees,
      String treeAnimation,
      String air,
      String airAnimation) {
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final fontSize = MediaQuery.of(context).size.width / 4.5;
    final defaultStyle = TextStyle(
      color: textColor,
      fontFamily: 'Comfortaa',
      fontSize: fontSize,
    );

    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: background,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: (FlareActor(topRight,
              animation: topRightAnimation, fit: BoxFit.cover)),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child:
              (FlareActor(trees, animation: treeAnimation, fit: BoxFit.cover)),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: (FlareActor(air, animation: airAnimation, fit: BoxFit.cover)),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Text(widget.model.location,
                style: TextStyle(
                    color: textColor,
                    fontSize: fontSize / 6.5,
                    fontFamily: 'Comfortaa',
                    fontWeight: FontWeight.bold)),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Text(widget.model.temperatureString,
                style: TextStyle(
                    color: textColor,
                    fontSize: fontSize / 6.0,
                    fontFamily: 'Comfortaa',
                    fontWeight: FontWeight.bold)),
          ),
        ),
        Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  hour,
                  style: defaultStyle,
                ),
                Text(
                  ':',
                  style: defaultStyle,
                ),
                Text(
                  minute,
                  style: defaultStyle,
                )
              ],
            ))
      ],
    );
  }

  Widget weather() {
    if (Theme.of(context).brightness == Brightness.light) {
      if (widget.model.weatherCondition == WeatherCondition.sunny) {
        return scene(
            sunny,
            Colors.teal[700],
            'third_party/flare/Sun.flr',
            null,
            'third_party/flare/SunnyTrees.flr',
            null,
            'third_party/flare/Breeze.flr',
            'Loop');
      } else if (widget.model.weatherCondition == WeatherCondition.cloudy) {
        return scene(
            cloudy,
            Colors.blueGrey[100],
            'third_party/flare/Clouds.flr',
            null,
            'third_party/flare/CloudyTrees.flr',
            null,
            'third_party/flare/Breeze.flr',
            'Loop');
      } else if (widget.model.weatherCondition == WeatherCondition.rainy) {
        return scene(
            rainy,
            Colors.blueGrey[100],
            'third_party/flare/SimpleRain.flr',
            'Rain',
            'third_party/flare/CloudyTrees.flr',
            null,
            'third_party/flare/Breeze.flr',
            'Loop');
      } else if (widget.model.weatherCondition == WeatherCondition.windy) {
        return scene(
            sunny,
            Colors.teal[700],
            'third_party/flare/Sun.flr',
            null,
            'third_party/flare/WindyTrees.flr',
            'Loop',
            'third_party/flare/Wind.flr',
            'Wind');
      } else if (widget.model.weatherCondition ==
          WeatherCondition.thunderstorm) {
        return scene(
            rainy,
            Colors.blueGrey[100],
            'third_party/flare/ThunderStorm.flr',
            'Rain',
            'third_party/flare/CloudWindyTrees.flr',
            'Loop',
            'third_party/flare/Wind.flr',
            'Wind');
      } else if (widget.model.weatherCondition == WeatherCondition.foggy) {
        return scene(
            foggy,
            Colors.blueGrey[100],
            'third_party/flare/Clouds.flr',
            null,
            'third_party/flare/MistTrees.flr',
            null,
            'third_party/flare/Mist.flr',
            'Loop');
      } else if (widget.model.weatherCondition == WeatherCondition.snowy) {
        return scene(
            snowy,
            Colors.blueGrey[50],
            'third_party/flare/Snow.flr',
            'Snow',
            'third_party/flare/SnowTrees.flr',
            null,
            'third_party/flare/Breeze.flr',
            'Loop');
      }
    } else {
      if (widget.model.weatherCondition == WeatherCondition.sunny) {
        return scene(
            night,
            Colors.blueGrey[100],
            'third_party/flare/Moon.flr',
            null,
            'third_party/flare/NightTrees.flr',
            null,
            'third_party/flare/Breeze.flr',
            'Loop');
      } else if (widget.model.weatherCondition == WeatherCondition.cloudy) {
        return scene(
            night,
            Colors.blueGrey[300],
            'third_party/flare/Clouds.flr',
            null,
            'third_party/flare/NightTrees.flr',
            null,
            'third_party/flare/Breeze.flr',
            'Loop');
      } else if (widget.model.weatherCondition == WeatherCondition.rainy) {
        return scene(
            night,
            Colors.blueGrey[200],
            'third_party/flare/SimpleRain.flr',
            'Rain',
            'third_party/flare/NightTrees.flr',
            null,
            'third_party/flare/Breeze.flr',
            'Loop');
      } else if (widget.model.weatherCondition == WeatherCondition.windy) {
        return scene(
            night,
            Colors.blueGrey[100],
            'third_party/flare/Moon.flr',
            null,
            'third_party/flare/NightWindyTrees.flr',
            'Loop',
            'third_party/flare/Wind.flr',
            'Wind');
      } else if (widget.model.weatherCondition ==
          WeatherCondition.thunderstorm) {
        return scene(
            night,
            Colors.blueGrey[200],
            'third_party/flare/ThunderStorm.flr',
            'Rain',
            'third_party/flare/NightWindyTrees.flr',
            'Loop',
            'third_party/flare/Wind.flr',
            'Wind');
      } else if (widget.model.weatherCondition == WeatherCondition.foggy) {
        return scene(
            night,
            Colors.blueGrey[200],
            'third_party/flare/Clouds.flr',
            null,
            'third_party/flare/MistTrees.flr',
            null,
            'third_party/flare/Mist.flr',
            'Loop');
      } else if (widget.model.weatherCondition == WeatherCondition.snowy) {
        return scene(
            night,
            Colors.blueGrey[50],
            'third_party/flare/Snow.flr',
            'Snow',
            'third_party/flare/SnowTrees.flr',
            null,
            'third_party/flare/Breeze.flr',
            'Loop');
      }
    }
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      // _timer = Timer(
      //   Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
      //   _updateTime,
      // );
    });
  }

  @override
  Widget build(BuildContext context) {
    return weather();
  }
}
