import 'package:cloud_firestore/cloud_firestore.dart';

class Maps {
  String id;
  String tag;

  String name;
  String url;
  String description;
  String img;
  String mapsType;
  Timestamp creationDate;

  Maps({
    this.id,
    this.tag,
    this.name,
    this.url,
    this.description,
    this.img,
    this.mapsType,
    this.creationDate,
  });

  Maps.fromMap(Map snapshot, String id)
      : id = id ?? '',
        tag = snapshot['tag'] ?? '',
        name = snapshot['name'] ?? '',
        url = snapshot['url'] ?? '',
        description = snapshot['description'] ?? '',
        img = snapshot['img'] ?? '',
        mapsType = snapshot['mapsType'] ?? '',
        creationDate = snapshot['creationDate'];

  toJson() {
    return {
      "tag": tag,
      "name": name,
      "url": url,
      "description": description,
      "img": img,
      "mapsType": mapsType,
      "creationDate": creationDate,
    };
  }
}
