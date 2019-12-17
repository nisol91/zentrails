import 'package:transparent_image/transparent_image.dart';
import '../app_state_container.dart';
import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../views/service_details.dart';

class ServiceCard extends StatelessWidget {
  final Service serviceDetails;
  final Color featuredColor;

  ServiceCard({this.serviceDetails, this.featuredColor});

  @override
  Widget build(BuildContext context) {
    var tema = Theme.of(context);
    var container = AppStateContainer.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ServiceDetails(service: serviceDetails)));
      },
      child: Padding(
        padding: EdgeInsets.all(3),
        child: Card(
          color: featuredColor,
          elevation: 5,
          child: Container(
            // height: MediaQuery.of(context).size.height * 0.45,
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                serviceDetails.name,
                                style: tema.textTheme.body2,
                                textAlign: TextAlign.start,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  serviceDetails.description,
                                  style: tema.textTheme.body1,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: <Widget>[
                            Image.network(
                              '${serviceDetails.img}',
                              height: 70,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: LinearProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
