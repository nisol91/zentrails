import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  String id;
  String companyId;
  String companyName;
  String name;
  String description;
  String address;
  String img;
  String companyType;
  bool featured;
  Timestamp creationDate;

  Service({
    this.id,
    this.companyId,
    this.companyName,
    this.name,
    this.description,
    this.address,
    this.img,
    this.companyType,
    this.featured,
    this.creationDate,
  });

  Service.fromMap(Map snapshot, String id)
      : id = id ?? '',
        companyId = snapshot['companyId'] ?? '',
        companyName = snapshot['companyName'] ?? '',
        name = snapshot['name'] ?? '',
        description = snapshot['description'] ?? '',
        address = snapshot['address'] ?? '',
        img = snapshot['img'] ?? '',
        companyType = snapshot['companyType'] ?? '',
        featured = snapshot['featured'],
        creationDate = snapshot['creationDate'];

  toJson() {
    return {
      "companyId": companyId,
      "companyName": companyName,
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
