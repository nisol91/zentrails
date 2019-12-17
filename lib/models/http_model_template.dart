import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// QUESTO FILE è UN TEMPLATE PER I MODEL con chiamata http

// example on how to fetch data from http call and create a list

List<Service> list = List();
Future<List<Service>> fetchService() async {
  final response =
      await http.get('https://jsonplaceholder.typicode.com/photos');

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON.
    list = (json.decode(response.body) as List)
        .map((data) => new Service.fromJson(data))
        .toList();
    print(list[0].title);
    print(list[1].title);
    return list;
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load service');
  }
}

class Service {
  final int userId;
  final int id;
  final String title;
  final String description;

  Service({this.userId, this.id, this.title, this.description});

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      description: json['description'],
    );
  }
}
