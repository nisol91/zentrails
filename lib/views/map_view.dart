import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

class MapView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(44.5, 10),
        zoom: 8.0,
      ),
      layers: [
        TileLayerOptions(
          //thunderforest
          urlTemplate:
              "https://tile.thunderforest.com/outdoors/{z}/{x}/{y}.png?apikey=2dc9e186f0cd4fa89025f5bd286c6527",

          //opentopo
          // urlTemplate: "https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png",
          // subdomains: ['a', 'b', 'c'],

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
    );
  }
}
