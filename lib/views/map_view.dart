import 'dart:async';
import 'dart:io';
import 'package:ZenTrails/plugins/timer_text.dart';
import 'package:ZenTrails/widgets/save_track_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import '../app_state_container.dart';
import '../models/maps_model.dart';
import 'settings_page.dart';
import '../views/settings_page.dart';
import '../views/map_list_page.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_map/plugin_api.dart';
import '../plugins/scale_layer_plugin_options.dart';
import 'package:battery_optimization/battery_optimization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/app_lifecycle_reactor.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MapView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> with TickerProviderStateMixin {
  double zoomLevel;
  LatLng position;
  LatLng gpsPosition;

  ScreenshotController screenshotController = ScreenshotController();

  MapController mapController;
  LocationData currentLocation;
  double currentLat;
  double currentLng;
  double currentAlt;
  double currentSpeed;
  double currentHeading;

  bool youHaveTappedOnModal = false;
  bool dataModalVisible = true;
  bool record = false;

  File _mapScreenshot;

  var location = new Location();

  List points = <LatLng>[
    LatLng(44, 10),
    LatLng(44.2, 10.2),
    LatLng(44.3, 10.3),
    LatLng(44.5, 10.4),
    LatLng(44.7, 10.5),
    LatLng(44.6, 10.6),
  ];

  List trackPoints = <List>[];
  List trackPointsForDb = <List>[];

  List trackPointsLatLng = <LatLng>[];

  //mi serve per fare differenze tra angoli per la heading
  List headingList = <double>[
    0.0,
    0.0,
  ];

  double numPoints = 0;
  double totalDistSum = 0;
  double totalElevationGain = 0;
  double velSum = 0;
  double elevSum = 0;
  double vrtSpd = 0;
  double grd = 0;

  double avgSpeed;
  double grade;
  double verticalSpeed;

  AnimationController positionAnimationController;
  Animation<double> positionAnimation;
  AnimationController animatedMapMoveController;

  @override
  initState() {
    super.initState();
    animatePositionMarkerDir(0.0, 0.0);
    mapController = MapController();
    zoomLevel = 8;
    position = LatLng(46.0835, 6.9887);

    //dopo che la mappa si è caricata, ricerco la posizione
    Future.delayed(new Duration(milliseconds: 500), () {
      //(in alternativa plugin geolocation)
      _getMyGPSLocationOnInit();
      // _getMyGPSLocation();
      _getMyGPSLocationOnMove();
      _getTrackPoints();
    });
  }

  void showModal() {
    setState(() {
      dataModalVisible = !dataModalVisible;
    });
  }

  void animatePositionMarkerDir(double begin, double end) {
    positionAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    positionAnimation = Tween(begin: begin, end: end).animate(CurvedAnimation(
        parent: positionAnimationController, curve: Curves.linear));
    // positionAnimationController.forward();
    if (positionAnimationController.isAnimating) {
      // positionAnimationController.stop();
    } else {
      // positionAnimationController.reset();
      positionAnimationController.forward();
    }
  }

  void takeScreenshot() async {
    final directory = (await getApplicationDocumentsDirectory())
        .path; //from path_provide package
    String fileName = DateTime.now().toIso8601String();
    String path = '$directory/$fileName.png';
    screenshotController.capture(path: path).then((File image) {
      print('screenshot done');
      print(image);

      //Capture Done
      setState(() {
        _mapScreenshot = image;
      });
    }).catchError((onError) {
      print(onError);
    });
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final _latTween = Tween<double>(
        begin: mapController.center.latitude, end: destLocation.latitude);
    final _lngTween = Tween<double>(
        begin: mapController.center.longitude, end: destLocation.longitude);
    final _zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    var animatedMapMoveController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    Animation<double> animation = CurvedAnimation(
        parent: animatedMapMoveController, curve: Curves.fastOutSlowIn);

    animatedMapMoveController.addListener(() {
      mapController.move(
          LatLng(_latTween.evaluate(animation), _lngTween.evaluate(animation)),
          _zoomTween.evaluate(animation));
    });

    // animation.addStatusListener((status) {
    //   if (status == AnimationStatus.completed) {
    //     animatedMapMoveController.dispose();
    //   } else if (status == AnimationStatus.dismissed) {
    //     animatedMapMoveController.dispose();
    //   }
    // });

    animatedMapMoveController.forward();
  }

  void _locateMyPosition(lat, lng, zoom) {
    mapController.move(LatLng(lat, lng), zoom);
  }

  void _getMyGPSLocationOnInit() async {
    final container = AppStateContainer.of(context);
    location.changeSettings(
        accuracy: LocationAccuracy.HIGH, interval: 2000, distanceFilter: 1);
    currentLocation = await location.getLocation();
    setState(() {
      currentAlt = currentLocation.altitude;
      currentLat = currentLocation.latitude;
      currentLng = currentLocation.longitude;
      currentSpeed = currentLocation.speed;
      currentHeading = currentLocation.heading;
      gpsPosition = LatLng(currentLat, currentLng);

      //le setto anche nell app container
      container.currentLat = currentLat;
      container.currentLng = currentLng;
      container.currentAlt = currentAlt;
      container.currentSpeed = currentSpeed;
      container.currentHeading = currentHeading;
    });

    print(currentLocation.latitude);
    print(currentLocation.longitude);
    print(currentLocation.speed);
    print(currentLocation.altitude);
    print('OGNI 2 SECONDI CERCO LA POSIZIONE======');
    //mi va subito alla positione aggiornandola se c è
    _locateMyPosition(currentLat, currentLng, zoomLevel);
  }

  // void _getMyGPSLocation() {
  //   var container = AppStateContainer.of(context);
  //   if (mounted) {
  //     Timer.periodic(Duration(milliseconds: 2000), (timer) async {
  //       location.changeSettings(
  //           accuracy: LocationAccuracy.HIGH, interval: 1000, distanceFilter: 2);
  //       currentLocation = await location.getLocation();
  //       setState(() {
  //         currentAlt = currentLocation.altitude;
  //         currentLat = currentLocation.latitude;
  //         currentLng = currentLocation.longitude;
  //         currentSpeed = currentLocation.speed;
  //         currentHeading = currentLocation.heading;
  //         gpsPosition = LatLng(currentLat, currentLng);

  //         //le setto anche nell app container
  //         container.currentLat = currentLat;
  //         container.currentLng = currentLng;
  //         container.currentAlt = currentAlt;
  //         container.currentSpeed = currentSpeed;
  //         container.currentHeading = currentHeading;
  //       });

  //       print(currentLocation.latitude);
  //       print(currentLocation.longitude);
  //       print(currentLocation.speed);
  //       print(currentLocation.altitude);
  //       print('OGNI 2 SECONDI CERCO LA POSIZIONE======');
  //     });
  //   }
  // }

  void _getMyGPSLocationOnMove() {
    final container = AppStateContainer.of(context);

    //cosi streamo la mia posizione in continuo
    location.onLocationChanged().listen((LocationData currentLocation) {
      print(currentLocation.latitude);
      print(currentLocation.longitude);

      print('GPS LOCATION CHIAMATO DALLO STREAM');

      //mi va subito alla positione aggiornandola se c è.
      //per questioni di usabilità, non ha senso chiamarla.
      // _locateMyPosition(currentLat, currentLng, zoomLevel);

      //aggiungo il nuovo punto alla traccia
      if (record) {
        _setTrackPoints(currentLocation.latitude, currentLocation.longitude,
            currentLocation.speed, currentLocation.altitude);
      }
      setState(() {
        position = LatLng(currentLocation.latitude, currentLocation.longitude);
        currentAlt = currentLocation.altitude;
        currentLat = currentLocation.latitude;
        currentLng = currentLocation.longitude;
        currentSpeed = currentLocation.speed * 3.6;
        currentHeading = currentLocation.heading;
        gpsPosition = LatLng(currentLat, currentLng);
        //le setto anche nell app container
        container.currentLat = currentLat;
        container.currentLng = currentLng;
        container.currentAlt = currentAlt;
        container.currentSpeed = currentSpeed;
        container.currentHeading = currentHeading;
      });
      double currentHeadingRadian = currentHeading * (PI / 180.0);
      headingList.add(currentHeadingRadian);
      animatePositionMarkerDir(
          headingList[headingList.length - 2], headingList.last);
      print('PENULTIMOOOOOOOO-->>${headingList[headingList.length - 2]}');

      print('ULTIMOOOOOOOO-->>${headingList.last}');
      print('listaaaaaaaaaa-->>${headingList}');
    });
  }

  void _onMyPositionChangingOnMapGesture(lat, lng, zoom) {
    setState(() {
      position = LatLng(lat, lng);
      zoomLevel = zoom;
    });
    print('my current map position is -> lat${lat}, lng${lng}');
  }

  void _setTrackPoints(double lat, double lng, double vel, double elev) {
    final container = AppStateContainer.of(context);

    trackPoints
        .add([lat, lng, vel, elev, container.stopwatch.elapsed.inSeconds]);
    trackPointsLatLng.add(LatLng(lat, lng));
    print('TEMPO-->${container.stopwatch.elapsed.inSeconds}');
    print('LISTA PUNTI?????? ---- >$trackPoints');
    //calcolo distanza percorsa
    final Distance distance = new Distance();
    final double meterDist = distance(
        LatLng(trackPoints.last[0], trackPoints.last[1]),
        LatLng(trackPoints[trackPoints.length - 2][0],
            trackPoints[trackPoints.length - 2][1]));
    //calcolo D+
    //settandoli simulo un parziale d+ per poter testare
    // trackPoints.last[3] = 11.0;
    // trackPoints[trackPoints.length - 2][3] = 10.0;
    elevSum = 0;
    if (trackPoints.last[3] - trackPoints[trackPoints.length - 2][3] > 0) {
      elevSum = trackPoints.last[3] - trackPoints[trackPoints.length - 2][3];
    } else {
      elevSum = 0;
    }
    //calcolo vert spd in m/min
    vrtSpd = 0;
    if (trackPoints.last[3] - trackPoints[trackPoints.length - 2][3] > 0) {
      vrtSpd = (trackPoints.last[3] - trackPoints[trackPoints.length - 2][3]) /
          (trackPoints.last[4] - trackPoints[trackPoints.length - 2][4]);
    }
    //calcolo pendenza
    grd = 0;
    if (trackPoints.last[3] - trackPoints[trackPoints.length - 2][3] > 0) {
      grd = ((trackPoints.last[3] - trackPoints[trackPoints.length - 2][3]) /
              meterDist) *
          100;
    }

    setState(() {
      avgSpeed = (totalDistSum / container.stopwatch.elapsed.inSeconds) * 3.6;
      totalElevationGain += elevSum;
      totalDistSum += meterDist;
      verticalSpeed = vrtSpd * 60;
      grade = grd;

//le setto anche nell app container

      container.totalDistSum = totalDistSum;
      container.totalElevationGain = totalElevationGain;
      container.elevSum = elevSum;
      container.avgSpeed = avgSpeed;
      container.grade = grade;
      container.verticalSpeed = verticalSpeed;
      container.trackPoints = trackPoints;
    });
    print('DISTANZA CUMULATA===$totalDistSum');
    print('DISLIVELLO CUMULATO===$totalElevationGain');
    print('AVG SPEED!!! $avgSpeed');
    print('VERTICAL SPEED!!! $verticalSpeed');
    trackPointsForDb.add([
      lat,
      lng,
      vel,
      elev,
      avgSpeed,
      totalElevationGain,
      totalDistSum,
      container.stopwatch.elapsed.inSeconds,
      Timestamp.now()
    ]);
  }

  void saveTrack(String name, String description) {
    Firestore.instance
        .collection("users")
        .document(AppStateContainer.of(context).id)
        .collection('Tracks')
        .add({
      'name': name,
      'description': description,
      'creationDate': Timestamp.now(),
    }).then((onValue) {
      trackPointsForDb.forEach((point) {
        onValue.collection('Points').add({
          'lat': point[0],
          'lng': point[1],
          'vel': point[2],
          'elev': point[3],
          'avgSpeed': point[4],
          'totalElevationGain': point[5],
          'totalDistSum': point[6],
          'stopwatch': point[7],
          'timestamp': point[8],
        });
      });
    });
  }

  void _getTrackPoints() {
    Firestore.instance
        .collection("users")
        .document(AppStateContainer.of(context).id)
        .collection('Tracks')
        .document('6UqAowqXk9Ua282FpVWq')
        .collection('Points')
        .getDocuments()
        .then((doc) {
      var punti = doc.documents.toList();

      print('================');
      punti.forEach((el) {
        print('quota punto-->${el.data['elev'].toString()}');
        print(
            'coord punto-->${el.data['lat'].toString()} | ${el.data['lng'].toString()}');
      });

      print('================');
      List fetchedPoints = <LatLng>[];
      punti.forEach((el) {
        fetchedPoints.add(LatLng(el.data['lat'], el.data['lng']));
      });
      print('LISTA PUNTI ---- >${fetchedPoints}');
      print('LISTA PUNTI ORIGINALE ---- >${points}');

      setState(() {
        points = fetchedPoints;
      });
    });
  }

  _onMapTapped(LatLng point) {
    CustomPoint<num> screenPosition =
        Epsg3857().latLngToPoint(mapController.center, mapController.zoom);
    print('Map Center: ${mapController.center}, zoom: ${mapController.zoom}');
    print('Screen position: $screenPosition');
  }

  Widget get _loadingView {
    return new Scaffold(
      body: new Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  Text('loading map...'),
                  // Image(image: AssetImage('assets/echo_logo.png'))
                ],
              ),
            ),
            new CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget get _batteryOptimization {
    final container = AppStateContainer.of(context);

    return AlertDialog(
      title: new Text('Please exclude this app from battery optimization'),
      content: new Text(
        'You have to do that in order to make it run in background. You also always need to activate gps location.',
        style: new TextStyle(fontSize: 30.0),
      ),
      actions: <Widget>[
        new FlatButton(
            onPressed: () {
              print('no');
              setState(() {
                container.batteryOptModal = false;
              });
            },
            child: new Text('no')),
        new FlatButton(
            onPressed: () {
              print('yes');
              setState(() {
                container.batteryOptModal = false;
              });
              if (Platform.isAndroid) {
                BatteryOptimization.openBatteryOptimizationSettings();
              }
            },
            child: new Text('yes')),
      ],
    );
  }

  Widget get _youHaveTappedOn {
    return SimpleDialog(
      title: const Text('You have tapped on:'),
      children: <Widget>[
        SimpleDialogOption(
          child: Column(
            children: <Widget>[
              Text('Coords->${mapController.center}'),
              Text('Zoom->${mapController.zoom}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget get _mapList {
    return Dialog(
      child: Text('dialog'),
    );
  }

  @override
  void dispose() {
    positionAnimationController.dispose();
    animatedMapMoveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var tema = Theme.of(context);
    final container = AppStateContainer.of(context);

    //questo è un fix per un problema dovuto al chiamare un setState
    //nell' onPositionChanged
    bool _building = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _building = false;
    });

    return Stack(
      children: <Widget>[
        (!container.loadedMaps && container.email != '')
            ? _loadingView
            : Screenshot(
                controller: screenshotController,
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    plugins: [
                      ScaleLayerPlugin(),
                    ],
                    center: position,
                    interactive: true,
                    zoom: zoomLevel,
                    onPositionChanged: (position, bool) {
                      double lat = position.center.latitude.toDouble();
                      double lng = position.center.longitude.toDouble();
                      double zoom = position.zoom.toDouble();

                      print(lat);
                      print(lng);
                      print('ZOOOOOOM${position.zoom}');
                      if (!_building) {
                        _onMyPositionChangingOnMapGesture(lat, lng, zoom);
                      }
                    },
                    onTap: (point) {
                      _onMapTapped(point);
                      setState(() {
                        youHaveTappedOnModal = !youHaveTappedOnModal;
                      });
                    },
                  ),
                  layers: [
                    TileLayerOptions(
                      //select map from DB
                      urlTemplate: (container.email == '')
                          ? "https://tile.thunderforest.com/outdoors/{z}/{x}/{y}@2x.png?apikey=2dc9e186f0cd4fa89025f5bd286c6527"
                          : container.maps[0].url,
                      subdomains: ['a', 'b', 'c'],

                      //la placeholder image purtroppo non può avere le dimensioni di tutto lo schermo
                      // placeholderImage: (_mapScreenshot != null)
                      //     ? FileImage(_mapScreenshot, scale: 100)
                      //     : NetworkImage(
                      //         'https://www.ambientiroma.it/wp-content/uploads/2017/07/grey-04.jpg'),

                      //forse la tile size potrebbe gestire le dimensioni degli elementi sullo schermo
                      //il problema è che poi la posizione si sballa.
                      // tileSize: 200

                      //thunderforest
                      // urlTemplate:
                      // "https://tile.thunderforest.com/outdoors/{z}/{x}/{y}@2x.png?apikey=2dc9e186f0cd4fa89025f5bd286c6527",

                      //cartodb
                      // urlTemplate:
                      //     "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}@3x.png",
                      // subdomains: ['a', 'b', 'c'],

                      //opentopo
                      // urlTemplate: "https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png",
                      // subdomains: ['a', 'b', 'c'],

                      //openstreet
                      // urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      // subdomains: ['a', 'b', 'c'],

                      //mapbox
                      // urlTemplate: "https://api.tiles.mapbox.com/v4/"
                      //     "{id}/{z}/{x}/{y}@2x.png?access_token={accessToken}",
                      // additionalOptions: {
                      //   'accessToken':
                      //       'pk.eyJ1Ijoibmlzb2w5MSIsImEiOiJjazBjaWRvbTIwMWpmM2hvMDhlYWhhZGV0In0.wyRaVw6FXdw6g3wp3t9FNQ',
                      //   'id': 'mapbox.streets',
                      // },
                    ),
                    ScaleLayerPluginOption(
                      lineColor: Colors.black,
                      lineWidth: 2,
                      textStyle: TextStyle(color: Colors.black, fontSize: 12),
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.width * 1.62,
                          left: MediaQuery.of(context).size.width * 0.6),
                    ),
                    PolylineLayerOptions(
                      polylines: [
                        Polyline(
                            points: trackPointsLatLng,
                            strokeWidth: 5.0,
                            color: Colors.purple),
                      ],
                    ),
                    MarkerLayerOptions(
                      markers: [
                        Marker(
                          width: 50.0,
                          height: 50.0,
                          point: gpsPosition,
                          builder: (ctx) => Container(
                            height: 40,
                            width: 40,
                            // color: Colors.blue,
                            child: Center(
                              child: AnimatedBuilder(
                                  animation: positionAnimation,
                                  child: Icon(
                                    Icons.arrow_drop_up,
                                    color: Colors.purple[800],
                                    size: 50,
                                  ),
                                  builder: (context, child) {
                                    return Transform.rotate(
                                      angle: positionAnimation.value,
                                      child: child,
                                    );
                                  }),
                              //     Transform.rotate(
                              //   angle: positionAnimation.value * currentHeading,
                              //   child: Icon(
                              //     Icons.arrow_drop_up,
                              //     color: Colors.purple[800],
                              //     size: 50,
                              //   ),
                              // ),
                            ),
                          ),
                        ),
                        // Marker(
                        //   width: 80.0,
                        //   height: 80.0,
                        //   point: mapController.center,
                        //   builder: (ctx) => Container(
                        //     child: Icon(Icons.home),
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
        (youHaveTappedOnModal) ? _youHaveTappedOn : Container(),
        (container.batteryOptModal) ? _batteryOptimization : Container(),

        AppLifecycleReactor(),
        // Positioned(
        //   top: 100,
        //   left: 5,
        //   child: Material(
        //     child: InkWell(
        //       onTap: () {
        //         print('ok');
        //         showModal();
        //       },
        //       child: Padding(
        //         padding: const EdgeInsets.all(8.0),
        //         child: (dataModalVisible)
        //             ? Icon(Icons.close)
        //             : Icon(Icons.add_circle_outline),
        //       ),
        //     ),
        //   ),
        // ),
        // Visibility(
        //   visible: dataModalVisible,
        //   child: Positioned(
        //       top: 100,
        //       left: 50,
        //       child: Container(
        //         padding: const EdgeInsets.all(16),
        //         color: Colors.white,
        //         child: Column(
        //           children: <Widget>[
        //             // Text('Lat->${currentLat.toString()}'),
        //             // Text('Lng->${currentLng.toString()}'),
        //             // Text('Altitude->${currentAlt.toString()} m'),
        //             // Text('Speed->${currentSpeed.toString()} km/h'),
        //             // Text('Heading dir->${currentHeading.toString()}°'),
        //             // Text('Elapsed time->${stopwatch.elapsed.toString()}'),
        //             // TimerText(stopwatch: stopwatch),
        //             // Text('distance->${(totalDistSum / 1000).toString()} km'),
        //             // Text('Avg Speed->${avgSpeed.toString()} km/h'),
        //             // Text('D+->${totalElevationGain.toString()} m'),
        //             // Text('D+ intervallo->${elevSum.toString()} m'),
        //             // Text('grade->${grade.toString()} %'),
        //             // Text('vert spd->${verticalSpeed.toString()} m/min'),
        //             // Text('ERROR->${container.errorFetchMaps.toString()}'),
        //             // Container(
        //             //   width: 200,
        //             //   height: 100,
        //             //   color: Colors.grey,
        //             //   child: Text('Speed->${container.maps[0].url.toString()}'),
        //             // )
        //           ],
        //         ),
        //       )),
        // ),
        (container.email == '')
            ? Container()
            : Positioned(
                top: 160,
                right: 20,
                child: Material(
                  color: Colors.transparent,
                  child: Center(
                    child: Ink(
                      decoration: const ShapeDecoration(
                        color: Colors.blueGrey,
                        shape: CircleBorder(),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.settings),
                        color: Colors.white,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute<Null>(
                                builder: (BuildContext context) {
                                  return SettingsList();
                                },
                                fullscreenDialog: true,
                              ));
                        },
                      ),
                    ),
                  ),
                ),
              ),

        Positioned(
          top: 100,
          right: 20,
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Ink(
                decoration: const ShapeDecoration(
                  color: Colors.blueGrey,
                  shape: CircleBorder(),
                ),
                child: IconButton(
                  icon: Icon(Icons.list),
                  color: Colors.white,
                  onPressed: () {
                    (container.email == '')
                        ? Fluttertoast.showToast(
                            msg: "Register to get full access to all maps",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIos: 1,
                            backgroundColor: Colors.teal,
                            textColor: Colors.white,
                            fontSize: 16.0)
                        : setState(() {
                            container.showMapListPage = true;
                          });
                  },
                ),
              ),
            ),
          ),
        ),
        Positioned(
          width: 30,
          height: 30,
          bottom: 30,
          left: 100,
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Ink(
                decoration: ShapeDecoration(
                  color: (record) ? Colors.yellow : Colors.green,
                  shape: CircleBorder(),
                ),
                child: IconButton(
                  icon: Icon(
                    (record) ? Icons.pause : Icons.play_arrow,
                    size: 15,
                  ),
                  color: Colors.white,
                  onPressed: () {
                    container.handleRecord();
                    setState(() {
                      record = !record;
                    });
                  },
                ),
              ),
            ),
          ),
        ),
        (!record)
            ? Positioned(
                width: 30,
                height: 30,
                bottom: 30,
                left: 150,
                child: Material(
                  color: Colors.transparent,
                  child: Center(
                    child: Ink(
                      decoration: ShapeDecoration(
                        color: (true) ? Colors.red : Colors.grey,
                        shape: CircleBorder(),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.stop,
                          size: 15,
                        ),
                        color: Colors.white,
                        onPressed: () {
                          container.resetStopwatch();
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return SaveTrackModal(
                                  saveTrackFunction: saveTrack,
                                );
                                //passo al costruttore del modal la funzione saveTrack
                              });
                        },
                      ),
                    ),
                  ),
                ),
              )
            : Container(),
        (!record)
            ? Positioned(
                width: 30,
                height: 30,
                bottom: 30,
                left: 200,
                child: Material(
                  color: Colors.transparent,
                  child: Center(
                    child: Ink(
                      decoration: ShapeDecoration(
                        color: Colors.grey,
                        shape: CircleBorder(),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.delete,
                          size: 15,
                        ),
                        color: Colors.white,
                        onPressed: () {
                          print('delete');
                          container.resetStopwatch();

                          setState(() {
                            trackPoints = <List>[];
                            trackPointsForDb = <List>[];
                            trackPointsLatLng = <LatLng>[];
                            headingList = [];
                          });
                        },
                      ),
                    ),
                  ),
                ),
              )
            : Container(),
        Positioned(
          bottom: 30,
          left: 20,
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Ink(
                decoration: const ShapeDecoration(
                  color: Colors.blueGrey,
                  shape: CircleBorder(),
                ),
                child: IconButton(
                  icon: Icon(Icons.my_location),
                  color: Colors.white,
                  onPressed: () {
                    _getMyGPSLocationOnInit();
                    // _locateMyPosition(currentLat, currentLng, zoomLevel);
                    _animatedMapMove(LatLng(currentLat, currentLng), zoomLevel);
                    print('locate position');
                  },
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          right: 20,
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Ink(
                decoration: const ShapeDecoration(
                  color: Colors.blueGrey,
                  shape: CircleBorder(),
                ),
                child: IconButton(
                  icon: Icon(Icons.remove),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      zoomLevel = zoomLevel - 1;
                      position = LatLng(mapController.center.latitude,
                          mapController.center.longitude);
                    });
                    mapController.move(position, zoomLevel);
                    print('zoom out');
                  },
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          right: 20,
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Ink(
                decoration: const ShapeDecoration(
                  color: Colors.blueGrey,
                  shape: CircleBorder(),
                ),
                child: IconButton(
                  icon: Icon(Icons.add),
                  color: Colors.white,
                  onPressed: () {
                    print('il centro della mia vista:${mapController.center}');
                    setState(() {
                      zoomLevel = (zoomLevel.ceilToDouble() + 0.5);
                    });
                    setState(() {
                      position = LatLng(
                          mapController.center.latitude + 0.00000001,
                          mapController.center.longitude + 0.00000001);
                    });
                    mapController.move(position, zoomLevel);
                    //questo fix serve perchè pare che la mappa, una volta fatto lo zoom in
                    //col mapcontroller, non ricarichi finche non si sposta.
                    //allora gli faccio cambiare posizione appena dopo aver fatto zoom in
                    new Future.delayed(new Duration(milliseconds: 10), () {
                      setState(() {
                        position = LatLng(
                            mapController.center.latitude - 0.00000001,
                            mapController.center.longitude - 0.00000001);
                      });
                      mapController.move(position, zoomLevel);
                    });
                    print('zoom in');
                  },
                ),
              ),
            ),
          ),
        ),
        (container.showMapListPage) ? MapListPage() : Container(),
      ],
    );
  }
}
