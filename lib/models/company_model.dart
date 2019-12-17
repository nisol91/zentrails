import 'package:cloud_firestore/cloud_firestore.dart';

class Company {
  String id;
  String name;
  String description;
  String address;
  String img;
  String companyType;
  bool featured;
  Timestamp creationDate;

  Company({
    this.id,
    this.name,
    this.description,
    this.address,
    this.img,
    this.companyType,
    this.featured,
    this.creationDate,
  });

  Company.fromMap(Map snapshot, String id)
      : id = id ?? '',
        name = snapshot['name'] ?? '',
        description = snapshot['description'] ?? '',
        address = snapshot['address'] ?? '',
        img = snapshot['img'] ?? '',
        companyType = snapshot['companyType'] ?? '',
        featured = snapshot['featured'],
        creationDate = snapshot['creationDate'];

  toJson() {
    return {
      "name": name,
      "description": description,
      "address": address,
      "img": img,
      "companyType": companyType,
      "featured": featured,
      "creationDate": creationDate,
    };
  }
}
