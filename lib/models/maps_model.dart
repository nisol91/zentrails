import 'package:cloud_firestore/cloud_firestore.dart';

class Maps {
  String id;
  String name;
  String description;
  String img;
  String mapsType;
  Timestamp creationDate;

  Maps({
    this.id,
    this.name,
    this.description,
    this.img,
    this.mapsType,
    this.creationDate,
  });

  Maps.fromMap(Map snapshot, String id)
      : id = id ?? '',
        name = snapshot['name'] ?? '',
        description = snapshot['description'] ?? '',
        img = snapshot['img'] ?? '',
        mapsType = snapshot['mapsType'] ?? '',
        creationDate = snapshot['creationDate'];

  toJson() {
    return {
      "name": name,
      "description": description,
      "img": img,
      "mapsType": mapsType,
      "creationDate": creationDate,
    };
  }
}
