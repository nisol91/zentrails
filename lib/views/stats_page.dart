import 'dart:async';

import 'package:ZenTrails/plugins/timer_text.dart';

import '../main.dart';
import '../app_state_container.dart';
import 'auth_screen.dart';
import 'map_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_state_container.dart';
import 'package:pk_skeleton/pk_skeleton.dart';
import '../widgets/service_card.dart';

import 'settings_page.dart';

class StatsPage extends StatefulWidget {
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  double currentLat;
  double currentLng;
  double currentAlt;
  double currentSpeed;
  double currentHeading;
  double totalDistSum = 0;
  double totalElevationGain;
  double elevSum = 0;
  double avgSpeed;
  double grade = 0;
  double verticalSpeed;
  List trackPoints = <List>[];

  @override
  initState() {
    super.initState();
  }

  void setGpsData() {
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        final container = AppStateContainer.of(context);

        currentLat = container.currentLat;
        currentLng = container.currentLng;
        currentAlt = container.currentAlt;
        currentSpeed = container.currentSpeed;
        currentHeading = container.currentHeading;
        totalDistSum = container.totalDistSum;
        totalElevationGain = container.totalElevationGain;
        elevSum = container.elevSum;
        avgSpeed = container.avgSpeed;
        grade = container.grade;
        verticalSpeed = container.verticalSpeed;
        trackPoints = container.trackPoints;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setGpsData();
  }

  Widget get _loading {
    return Container(
      width: MediaQuery.of(context).size.width * 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[CircularProgressIndicator()],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final container = AppStateContainer.of(context);

    // TODO: implement build
    return Padding(
      padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
      child: Container(
        child: Column(
          children: <Widget>[
            Text('Lat->${currentLat.toString()}'),
            Text('Lng->${currentLng.toString()}'),
            Text('Altitude->${currentAlt.toString()} m'),
            Text('Speed->${currentSpeed.toString()} km/h'),
            Text('Heading dir->${currentHeading.toString()}°'),
            Text('Elapsed time->${container.stopwatch.elapsed.toString()}'),
            TimerText(stopwatch: container.stopwatch),
            Text('distance->${(totalDistSum / 1000).toString()} km'),
            Text('Avg Speed->${avgSpeed.toString()} km/h'),
            Text('D+->${totalElevationGain.toString()} m'),
            Text('grade->${grade.toString()} %'),
            Text('vert spd->${verticalSpeed.toString()} m/min'),
            Text('D+ intervallo->${elevSum.toString()} m'),
            Text(
                'ultimo elev->${(trackPoints.isNotEmpty) ? trackPoints.last[3] : 0} '),
            Text(
                'penultimo elev->${(trackPoints.isNotEmpty) ? trackPoints[trackPoints.length - 2][3] : 0} '),
            Text(
                'ultimo tempo->${(trackPoints.isNotEmpty) ? trackPoints.last[4] : 0} '),
            Text(
                'penultimo tempo->${(trackPoints.isNotEmpty) ? trackPoints[trackPoints.length - 2][4] : 0} '),
          ],
        ),
      ),
    );
  }
}
