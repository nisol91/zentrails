import 'package:flutter/material.dart';

class AppLifecycleReactor extends StatefulWidget {
  const AppLifecycleReactor({Key key}) : super(key: key);

  @override
  _AppLifecycleReactorState createState() => _AppLifecycleReactorState();
}

class _AppLifecycleReactorState extends State<AppLifecycleReactor>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  AppLifecycleState _notification;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _notification = state;
    });
    print('===================$_notification');
  }

  @override
  Widget build(BuildContext context) {
    return Container();
    // return Positioned(
    //   top: 200,
    //   child: Container(
    //     color: Colors.blue,
    //     child: Text('Last notification: $_notification'),
    //   ),
    // );
  }
}
