// models/task.dart

import 'package:google_maps_flutter/google_maps_flutter.dart';

class Task {
  String name;
  DateTime dateTime;
  String address; 

  Task({
    required this.name,
    required this.dateTime,
    required this.address,
  });
}
