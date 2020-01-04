import 'dart:async';
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

class MapView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  double zoomLevel;
  LatLng position;
  LatLng gpsPosition;

  MapController mapController;
  LocationData currentLocation;
  bool youHaveTappedOnModal = false;
  double currentLat;
  double currentLng;
  double currentAlt;
  double currentSpeed;
  double currentHeading;

  bool dataModalVisible = true;

  var location = new Location();

  List points = <LatLng>[
    LatLng(44, 10),
    LatLng(44.2, 10.2),
    LatLng(44.3, 10.3),
    LatLng(44.5, 10.4),
    LatLng(44.7, 10.5),
    LatLng(44.6, 10.6),
  ];

  List trackPoints = <LatLng>[];

  @override
  initState() {
    super.initState();

    mapController = MapController();
    zoomLevel = 8;
    position = LatLng(46.0835, 6.9887);
    //dopo che la mappa si è caricata, ricerco la posizione
    Future.delayed(new Duration(milliseconds: 500), () {
      //(in alternativa plugin geolocation)
      _getMyGPSLocationOnInit();
      _getMyGPSLocationOnMove();
      _getTrackPoints();
    });
  }

  void showModal() {
    setState(() {
      dataModalVisible = !dataModalVisible;
    });
  }

  void _locateMyPosition(lat, lng, zoom) {
    mapController.move(LatLng(lat, lng), zoom);
  }

  void _getMyGPSLocationOnInit() async {
    location.changeSettings(
        accuracy: LocationAccuracy.HIGH, interval: 2000, distanceFilter: 3);
    currentLocation = await location.getLocation();
    setState(() {
      currentAlt = currentLocation.altitude;
      currentLat = currentLocation.latitude;
      currentLng = currentLocation.longitude;
      currentSpeed = currentLocation.speed;
      currentHeading = currentLocation.heading;
      gpsPosition = LatLng(currentLat, currentLng);
    });
    //mi va subito alla positione aggiornandola se c è
    _locateMyPosition(currentLat, currentLng, zoomLevel);
    print(currentLocation.latitude);
    print(currentLocation.longitude);
    print(currentLocation.speed);
    print(currentLocation.altitude);
  }

  void _getMyGPSLocationOnMove() {
    //cosi streamo la mia posizione in continuo
    location.onLocationChanged().listen((LocationData currentLocation) {
      print(currentLocation.latitude);
      print(currentLocation.longitude);

      print('GPS LOCATION CHIAMATO DALLO STREAM');

      //mi va subito alla positione aggiornandola se c è.
      //per questioni di usabilità, non ha senso chiamarla.
      // _locateMyPosition(currentLat, currentLng, zoomLevel);

      //aggiungo il nuovo punto alla traccia
      _setTrackPoints(currentLocation.latitude, currentLocation.longitude);

      setState(() {
        position = LatLng(currentLocation.latitude, currentLocation.longitude);
        currentAlt = currentLocation.altitude;
        currentLat = currentLocation.latitude;
        currentLng = currentLocation.longitude;
        currentSpeed = currentLocation.speed;
        currentHeading = currentLocation.heading;
        gpsPosition = LatLng(currentLat, currentLng);
      });
    });
  }

  void _onMyPositionChangingOnMapGesture(lat, lng, zoom) {
    setState(() {
      position = LatLng(lat, lng);
      zoomLevel = zoom;
    });
    print('my current map position is -> lat${lat}, lng${lng}');
  }

  void _setTrackPoints(double lat, double lng) {
    trackPoints.add(LatLng(lat, lng));
    print('LISTA PUNTI?????? ---- >${trackPoints}');
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
        (!container.loadedMaps)
            ? _loadingView
            : FlutterMap(
                mapController: mapController,
                options: MapOptions(
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
                    urlTemplate: container.maps[0].url,
                    subdomains: ['a', 'b', 'c'],

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
                  PolylineLayerOptions(
                    polylines: [
                      Polyline(
                          points: trackPoints,
                          strokeWidth: 4.0,
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
                          child: Icon(
                            Icons.add_circle_outline,
                            color: Colors.red[800],
                            size: 20,
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
        (youHaveTappedOnModal) ? _youHaveTappedOn : Container(),
        Positioned(
          top: 100,
          left: 5,
          child: Material(
            child: InkWell(
              onTap: () {
                print('ok');
                showModal();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: (dataModalVisible)
                    ? Icon(Icons.close)
                    : Icon(Icons.add_circle_outline),
              ),
            ),
          ),
        ),
        Visibility(
          visible: dataModalVisible,
          child: Positioned(
              top: 100,
              left: 50,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Text('Lat->${currentLat.toString()}'),
                    Text('Lng->${currentLng.toString()}'),
                    Text('Altitude->${currentAlt.toString()}'),
                    Text('Speed->${currentSpeed.toString()}'),
                    Text('Heading dir->${currentHeading.toString()}'),
                    Text('ERROR->${container.errorFetchMaps.toString()}'),
                    Container(
                      width: 200,
                      height: 100,
                      color: Colors.grey,
                      child: Text('Speed->${container.maps[0].url.toString()}'),
                    )
                  ],
                ),
              )),
        ),
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
        (container.email == '')
            ? Container()
            : Positioned(
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
                          setState(() {
                            container.showMapListPage = true;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
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
                    _locateMyPosition(currentLat, currentLng, zoomLevel);

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
                      zoomLevel = zoomLevel + 1;
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
