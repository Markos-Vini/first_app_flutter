import 'package:geolocator/geolocator.dart';
import 'package:app_flutter/models/task.dart';


class Task {
  String name;
  DateTime dateTime;
  Position location;

  Task({required this.name, required this.dateTime, required this.location});
}