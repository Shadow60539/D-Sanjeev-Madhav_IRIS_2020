import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todoeight/model/task_model.dart';

class TaskProvider extends ChangeNotifier {
var box = Hive.box<Task>('tasks');

Map<DateTime,List<Task>> getEvents(){
  List<Task> allTasks=List<Task>();
  Map<DateTime,List<Task>> events = {};
  box.keys.forEach((key) {
    Task task = box.get(key);
    allTasks.add(task);
  });
    allTasks.forEach((task) {
      if (events.containsKey(task.day)) {
        events[task.day].add(task);
      } else {
        events[task.day] = [task];
      }
  });

  //notifyListeners();
  return events;
}
void addTask(String newTodo,DateTime pickedDate){
  box.add(Task(
      title: newTodo,
      day: DateTime(pickedDate.year, pickedDate.month,
          pickedDate.day)));
  notifyListeners();
}
void deleteTask(Task delTask){
  box.keys.forEach((key) {
    Task task = box.get(key);
    if(task==delTask){
      box.delete(key);
    }
  });
  notifyListeners();
}

void updateTask(String newTodo,DateTime pickedDate,Task delTask){
int eKey;
  box.keys.forEach((key) {
    Task task = box.get(key);
    if(task==delTask){
      box.delete(key);
      eKey=key;
    }
  });
  box.put(eKey, Task(title: newTodo,day: DateTime(pickedDate.year,pickedDate.month,pickedDate.day)));
  notifyListeners();
}
void toggleCheckTrue(Task delTask,DateTime pickedDate){
  int eKey;
  box.keys.forEach((key) {
    Task task = box.get(key);
    if(task==delTask){
      box.delete(key);
      eKey=key;
    }
  });
  box.put(eKey, Task(title: delTask.title,day: DateTime(pickedDate.year,pickedDate.month,pickedDate.day),isChecked: true));
  notifyListeners();
}
void toggleCheckFalse(Task delTask,DateTime pickedDate){
  int eKey;
  box.keys.forEach((key) {
    Task task = box.get(key);
    if(task==delTask){
      box.delete(key);
      eKey=key;
    }
  });
  box.put(eKey, Task(title: delTask.title,day: DateTime(pickedDate.year,pickedDate.month,pickedDate.day),isChecked: false));
  notifyListeners();
}

}
