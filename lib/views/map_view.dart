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
  double currentLat;
  double currentLng;
  double currentAlt;

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
    });

    print(currentLocation.latitude);
    print(currentLocation.longitude);
    print(currentLocation.speed);
    print(currentLocation.altitude);

    location.onLocationChanged().listen((LocationData currentLocation) {
      print(currentLocation.latitude);
      print(currentLocation.longitude);
    });
  }

  _onMapTapped(LatLng point) {
    CustomPoint<num> screenPosition =
        Epsg3857().latLngToPoint(mapController.center, mapController.zoom);
    print('Map Center: ${mapController.center}, zoom: ${mapController.zoom}');
    print('Screen position: $screenPosition');
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
            onTap: (point) => _onMapTapped(point),
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
        Positioned(
            top: 100,
            left: 20,
            child: Container(
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  Text('Altitude->${currentAlt.toString()}'),
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
                    mapController.move(LatLng(currentLat, currentLng), 10);

                    setState(() {
                      position = LatLng(30, 20);
                    });
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
                  onPressed: () => print('zoom out'),
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
                    print('zoom in');
                    mapController.move(LatLng(44.5, 11), 15);
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
