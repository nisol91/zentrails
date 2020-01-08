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
  @override
  initState() {
    super.initState();
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
    // TODO: implement build
    return Padding(
      padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
      child: Container(
        child: Text('data'),
      ),
    );
  }
}
