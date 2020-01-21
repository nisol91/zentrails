import 'package:cloud_firestore/cloud_firestore.dart';

class Track {
  String id;
  String name;
  String description;

  Timestamp creationDate;

  Track({
    this.id,
    this.name,
    this.description,
    this.creationDate,
  });

  Track.fromMap(Map snapshot, String id)
      : id = id ?? '',
        name = snapshot['name'] ?? '',
        description = snapshot['description'] ?? '',
        creationDate = snapshot['creationDate'];

  toJson() {
    return {
      "name": name,
      "description": description,
      "creationDate": creationDate,
    };
  }
}
