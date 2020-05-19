import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  String title;
  @HiveField(1)
  DateTime day;
  @HiveField(2)
  TimeOfDay time;
  @HiveField(3)
  bool isChecked;

  Task({this.title, this.day, this.time, this.isChecked = false});
}
