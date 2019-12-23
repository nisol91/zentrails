import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';

class MapView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  double zoomLevel;
  LatLng position;
  MapController mapController;
  LocationData currentLocation;
  bool youHaveTappedOnModal = false;
  double currentLat;
  double currentLng;
  double currentAlt;
  double currentSpeed;

  var location = new Location();

  @override
  initState() {
    super.initState();
    zoomLevel = 10;
    mapController = MapController();
    position = LatLng(44.5, 10);
    getMyLocation();
  }

  void getMyLocation() async {
    currentLocation = await location.getLocation();
    setState(() {
      currentAlt = currentLocation.altitude;
      currentLat = currentLocation.latitude;
      currentLng = currentLocation.longitude;
      currentSpeed = currentLocation.speed;
      position = LatLng(currentLat, currentLng);
    });

    print(currentLocation.latitude);
    print(currentLocation.longitude);
    print(currentLocation.speed);
    print(currentLocation.altitude);

//cosi streamo la mia posizione in continuo
    // location.onLocationChanged().listen((LocationData currentLocation) {
    //    print(currentLocation.latitude);
    //    print(currentLocation.longitude);
    //   setState(() {
    //     position = LatLng(currentLocation.latitude, currentLocation.longitude);
    //   });
    // });
  }

  void _onMyPositionChanging(lat, lng) {
    setState(() {
      position = LatLng(lat, lng);
    });
    print('my current map position is -> lat${lat}, lng${lng}');
  }

  _onMapTapped(LatLng point) {
    CustomPoint<num> screenPosition =
        Epsg3857().latLngToPoint(mapController.center, mapController.zoom);
    print('Map Center: ${mapController.center}, zoom: ${mapController.zoom}');
    print('Screen position: $screenPosition');
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

  @override
  Widget build(BuildContext context) {
    var tema = Theme.of(context);

    return Stack(
      children: <Widget>[
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            center: position,
            zoom: zoomLevel,
            onPositionChanged: (position, bool) {
              double lat = position.center.latitude.toDouble();
              double lng = position.center.longitude.toDouble();
              print(lat);
              print(lng);

              _onMyPositionChanging(lat, lng);
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
              //thunderforest
              // urlTemplate:
              //     "https://tile.thunderforest.com/outdoors/{z}/{x}/{y}.png?apikey=2dc9e186f0cd4fa89025f5bd286c6527",

              //opentopo
              urlTemplate: "https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c'],

              //mapbox
              // urlTemplate: "https://{s}.tile.opentopomap.org/"
              //     "{z}/{x}/{y}.png",
              // additionalOptions: {
              // 'accessToken':
              //     'pk.eyJ1Ijoibmlzb2w5MSIsImEiOiJjazBjaWRvbTIwMWpmM2hvMDhlYWhhZGV0In0.wyRaVw6FXdw6g3wp3t9FNQ',
              // 'id': 'mapbox.streets',
              // },
            ),
            MarkerLayerOptions(
              markers: [
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: LatLng(44.5, 10),
                  builder: (ctx) => Container(
                      // child: Image.asset('assets/echo_logo.png'),
                      ),
                ),
              ],
            ),
          ],
        ),
        (youHaveTappedOnModal) ? _youHaveTappedOn : Container(),
        Positioned(
            top: 100,
            left: 20,
            child: Container(
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  Text('Altitude->${currentAlt.toString()}'),
                  Text('Speed->${currentSpeed.toString()}'),
                  Text('Lat->${currentLat.toString()}'),
                  Text('Lng->${currentLng.toString()}'),
                ],
              ),
            )),
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
                  onPressed: () => print('btn maps pressed'),
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
                    mapController.move(
                        LatLng(currentLat, currentLng), zoomLevel);

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
                    setState(() {
                      zoomLevel = zoomLevel + 1;
                    });
                    mapController.move(position, zoomLevel);
                    print('zoom in');
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
