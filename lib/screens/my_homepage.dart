import 'dart:core';
import 'package:audioplayers/audio_cache.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:todoeight/model/task_model.dart';
import 'package:todoeight/provider/task_provider.dart';
import 'package:todoeight/utils/src/calendar_controller.dart';
import 'package:todoeight/utils/src/calendar.dart';
import 'package:todoeight/utils/src/customization/calendar_style.dart';
import 'package:todoeight/utils/src/customization/header_style.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  DateTime pickedDate = DateTime.now();
  TimeOfDay pickedTime;
  bool show = true;
  TextEditingController controller;
  AnimationController _animationController;
  DateTime _selectedDay = DateTime.now();
  MyCalendarController _calendarController;
  bool isExpanded = false;
  bool check = false;
  String newTodo;
  // Notifications
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings androidInitializationSettings;
  IOSInitializationSettings iosInitializationSettings;
  InitializationSettings initializationSettings;

  void initializing() async {
    androidInitializationSettings = AndroidInitializationSettings('app_icon');
    iosInitializationSettings = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings = InitializationSettings(
        androidInitializationSettings, iosInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  void _showNotifications(String taskTitle) async {
    await notification(taskTitle);
  }

  Future<void> notification(String taskTitle) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            'Channel ID', 'Channel title', 'channel body',
            priority: Priority.High,
            importance: Importance.Max,
            ticker: 'test');

    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();
    NotificationDetails notificationDetails =
        NotificationDetails(androidNotificationDetails, iosNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        0,
        'Congratulations',
        'You have completed the task $taskTitle. Good job !! ',
        notificationDetails);
  }

  Future onSelectNotification(String payLoad) {
    if (payLoad != null) {
      print(payLoad);
    }
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(body),
      actions: <Widget>[
        CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              print("Tapped");
            },
            child: Text("Okay")),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    initializing();
    _calendarController = MyCalendarController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    controller.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List events) {
    setState(() {
      _selectedDay = day;
      pickedDate = _selectedDay;
    });
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {}

  void _onCalendarCreated(DateTime first, DateTime last, CalendarFormat format,
      Map<DateTime, List> callBackEvents) {}

  Widget buildBottomSheet(context) {
    return StatefulBuilder(
      builder:
          (BuildContext context, void Function(void Function()) setMState) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.45),
                  child: Divider(
                    height: 0,
                    thickness: 4,
                    color: Colors.white24,
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(
                      MediaQuery.of(context).size.width * 0.125,
                      MediaQuery.of(context).size.width * 0.125,
                      10,
                      MediaQuery.of(context).viewInsets.bottom * 0.5),
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      validator: AddTaskValidator.validate,
                      textCapitalization: TextCapitalization.sentences,
                      autocorrect: true,
                      autofocus: true,
                      onChanged: (newValue) {
                        setState(() {
                          if (newValue != null) {
                            newTodo = newValue;
                          }
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'What would you like to do ?',
                        hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.125,
                      vertical: 10),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          flex: 7,
                          child: Text(
                              pickedDate != null
                                  ? formatDate(
                                      pickedDate, [d, ' ', M, ' ', yyyy])
                                  : 'Pick a date',
                              style:
                                  TextStyle(color: DateTime(pickedDate.year, pickedDate.month, pickedDate.day)
                                      .difference(DateTime(
                                      DateTime.now().year, DateTime.now().month, DateTime.now().day))
                                      .inDays<0?Colors.red:Colors.grey, fontSize: 15))),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Stack(
                              children: <Widget>[
                                IconButton(
                                  icon: FaIcon(FontAwesomeIcons.solidCalendar,
                                      size: 30, color: Color(0xFF098cec)),
                                  onPressed: () {
                                    setMState(() {
                                      showDatePicker(
                                              context: context,
                                              builder: (context, child) {
                                                return Theme(
                                                  data: ThemeData.dark(),
                                                  child: child,
                                                );
                                              },
                                              initialDate: _selectedDay,
                                              firstDate: DateTime(2019, 8),
                                              lastDate: DateTime(2100))
                                          .then((value) {
                                        setMState(() {
                                          pickedDate = value;
                                        });
                                      });
                                    });
                                  },
                                ),
                              ],
                            )),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    highlightColor: Colors.green,
                    onPressed: () {
                      if (_formKey.currentState.validate()) {}
                      if (newTodo != null) {
                        Provider.of<TaskProvider>(context, listen: false)
                            .addTask(newTodo, pickedDate);
                        Navigator.pop(context);
                        newTodo = null;
                      } else {}
                    },
                    color: Color(0xFF098cec),
                    child: Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.add_circle,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'CREATE TASK',
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                    ))
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder(
        valueListenable: Provider.of<TaskProvider>(context).box.listenable(),
        builder: (BuildContext context, Box<Task> todos, _) {
          List<int> keys = todos.keys.cast<int>().toList();
          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.black,
            floatingActionButton: Builder(
              builder: (context) {
                return FloatingActionButton(
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          isDismissible: false,
                          isScrollControlled: true,
                          builder: buildBottomSheet,
                          useRootNavigator: true);
                    },
                    child: FaIcon(
                      FontAwesomeIcons.plus,
                      color: Colors.black,
                      size: 15,
                    ),
                    elevation: 5,
                    backgroundColor: Color(0xffd8dade));
              },
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.endDocked,
            appBar: AppBar(
              backgroundColor: Colors.black12,
              centerTitle: true,
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 10, top: 5),
                  child: Image.asset(
                    'images/user.png',
                    height: 40,
                    width: 40,
                    scale: 1,
                  ),
                )
              ],
              title: Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'TODO',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      'ey',
                      style: TextStyle(
                          color: Color(0xFF098cec), fontFamily: 'Stylish'),
                    )
                  ],
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 20, bottom: 3),
                    child: _buildTableCalendar(keys, todos),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.white,
                            offset: Offset(1, 1),
                            blurRadius: 0,
                            spreadRadius: 0),
                      ],
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(100),
                      ),
                    ),
                  ),
                  // _buildTableCalendarWithBuilders(),
                  const SizedBox(height: 30.0),
                  Flexible(
                    child: newBuildEvents(keys, todos),
                  ),
                  const SizedBox(height: 10.0),
                  Flexible(
                    child: showCompleted(keys, todos),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTableCalendar(List<int> keys, Box<Task> todos) {
    return Column(
      children: <Widget>[
        TableCalendar(
          calendarController: _calendarController,
          events: Provider.of<TaskProvider>(context).getEvents(),
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: MyCalendarStyle(
            selectedColor: Color(0xFF098cec),
            todayColor: Color(0xffd8dade),
            markersColor: Colors.green,
            outsideDaysVisible: false,
          ),
          headerStyle: MyHeaderStyle(
            formatButtonTextStyle:
                TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
            formatButtonDecoration: BoxDecoration(
              color: Colors.deepOrange[400],
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
          onDaySelected: _onDaySelected,
          onVisibleDaysChanged: _onVisibleDaysChanged,
          onCalendarCreated: _onCalendarCreated,
        ),
        _buildButtons()
      ],
    );
  }

  Widget _buildButtons() {
    return Container(
      child: IconButton(
        icon: FaIcon(
          isExpanded
              ? FontAwesomeIcons.angleDoubleDown
              : FontAwesomeIcons.angleDoubleUp,
          color: Colors.white,
          size: 18,
        ),
        onPressed: () {
          setState(() {
            isExpanded
                ? _calendarController.setCalendarFormat(CalendarFormat.month)
                : _calendarController.setCalendarFormat(CalendarFormat.week);
            isExpanded = !isExpanded;
          });
        },
      ),
    );
  }

  Widget newBuildEvents(List<int> keys, Box<Task> todos) {
    return Consumer<TaskProvider>(builder: (BuildContext context, value, _) {
      List<bool> isTrue = [];
      List<Task> sel = value.getEvents()[
          DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day)];

      if (sel == null) {
        return Container(
          height: 202,
          padding: EdgeInsets.symmetric(
            vertical: 0,
          ),
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image(
                  image: AssetImage(
                    'images/todo_new_bg.png',
                  ),
                  height: 150,
                  width: 100,
                ),
                Text(
                  'You have a free day',
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(
                  height: 20,
                ),
                Text('Ready for some new tasks ? Tap + to write them down',
                    style: TextStyle(color: Colors.grey))
              ],
            ),
            color: Colors.black87,
          ),
        );
      } else
        sel
          ..every((element) {
            isTrue.add(element.isChecked);
            return element.isChecked;
          });
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          isTrue.contains(false) ? showDate() : Container(),
          Container(
            child: ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              addRepaintBoundaries: true,
              addAutomaticKeepAlives: true,
              itemCount: sel.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                Task task = sel[index];
                return Container(
                  decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.only(bottomLeft: Radius.circular(40)),
                      color: Colors.white),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Dismissible(
                    direction: DismissDirection.startToEnd,
                    key: UniqueKey(),
                    onDismissed: (dir) {
                      value.deleteTask(task);
                    },
                    background: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.only(bottomLeft: Radius.circular(40)),
                        color: Colors.red,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Icon(
                            Icons.delete,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    child: task.isChecked
                        ? Container()
                        : ListTile(
                            key: UniqueKey(),
                            title: Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 9, left: 10, top: 2),
                              child: Text(
                                task.title,
                                style: TextStyle(
                                    decoration: task.isChecked
                                        ? TextDecoration.lineThrough
                                        : null),
                              ),
                            ),
                            subtitle: Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 10, left: 10),
                              child: getDaysLeftCount(),
                            ),
                            trailing: Container(
                              width: 100,
                              child: Row(
                                children: <Widget>[
                                  IconButton(
                                    icon: FaIcon(FontAwesomeIcons.edit),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              backgroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              title: Text(
                                                'Update',
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                              content: TextFormField(
                                                  initialValue: task.title,
                                                  textCapitalization:
                                                      TextCapitalization
                                                          .sentences,
                                                  autocorrect: true,
                                                  autofocus: true,
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                  onChanged: (newValue) {
                                                    if (newValue != null) {
                                                      newTodo = newValue;
                                                    }
                                                  }),
                                              actions: <Widget>[
                                                FlatButton(
                                                  onPressed: () {
                                                    if (newTodo != null) {
                                                      setState(() {
                                                        value.updateTask(
                                                            newTodo,
                                                            _selectedDay,
                                                            task);
                                                        Navigator.pop(context);
                                                        newTodo = null;
                                                      });
                                                    } else {
                                                      Navigator.pop(context);
                                                    }
                                                  },
                                                  child: Text('EDIT'),
                                                )
                                              ],
                                            );
                                          });
                                    },
                                    iconSize: 15,
                                    color: Color(0xFF098cec),
                                  ),
                                  Checkbox(
                                    tristate: true,
                                    activeColor: Color(0xFF098cec),
                                    value: task.isChecked,
                                    onChanged: (newValue) {
                                      _showNotifications(task.title);
                                      playSound();
                                      value.toggleCheckTrue(task, _selectedDay);
                                    },
                                    key: UniqueKey(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget showCompleted(List<int> keys, Box<Task> todos) {
    return Consumer<TaskProvider>(
      builder: (BuildContext context, TaskProvider value, _) {
        List<bool> isTrue = [];
        List<Task> sel = value.getEvents()[
            DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day)];
        if (sel == null)
          return Container();
        else
          sel.forEach((element) {
            isTrue.add(element.isChecked);
          });
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            isTrue.contains(true)
                ? Stack(
                    children: <Widget>[
                      Divider(
                        color: Colors.white12,
                        thickness: 22,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, bottom: 10),
                        child: Text(
                          'COMPLETED',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Calendar',
                              fontSize: 10),
                        ),
                      ),
                    ],
                  )
                : Container(),
            Container(
              child: ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: sel.length,
                itemBuilder: (BuildContext context, int index) {
                  Task task = sel[index];
                  return Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.black),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 10.0),
                    child: Dismissible(
                      direction: DismissDirection.startToEnd,
                      key: UniqueKey(),
                      onDismissed: (dir) {
                        setState(() {
                          value.deleteTask(task);
                        });
                      },
                      background: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          color: Colors.red,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Icon(
                              Icons.delete,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      child: task.isChecked == false
                          ? Container()
                          : ListTile(
                              title: Text(
                                task.title,
                                style: TextStyle(
                                    decoration: task.isChecked
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: Colors.grey),
                              ),
                              trailing: Container(
                                width: 100,
                                child: Row(
                                  children: <Widget>[
                                    IconButton(
                                      icon: FaIcon(
                                        FontAwesomeIcons.edit,
                                        color: Colors.white12,
                                        size: 15,
                                      ),
                                      onPressed: () {
                                        Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'You cannot edit completed tasks',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                            backgroundColor: Colors.white,
                                            duration: Duration(seconds: 2),
                                            action: SnackBarAction(
                                              label: 'OK',
                                              onPressed: () {},
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    Checkbox(
                                      activeColor: Color(0xFF098cec),
                                      value: task.isChecked,
                                      onChanged: (newValue) {
                                        value.toggleCheckFalse(
                                            task, _selectedDay);
                                      },
                                      key: UniqueKey(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget showDate() {
    return Stack(
      children: <Widget>[
        Divider(
          color: Colors.white12,
          thickness: 22,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 5),
          child: Text(
            formatDate(_selectedDay, [M, ' ', d]),
            style: TextStyle(
                color: Colors.white, fontSize: 10, fontFamily: 'Calendar'),
          ),
        )
      ],
    );
  }

  Widget getDaysLeftCount() {
    int days = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day)
        .difference(DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day))
        .inDays;
    if (days.isNegative) {
      if (days == -1) {
        return Text('${-days} day overdue',
            style: TextStyle(
              color: Colors.red,
            ));
      } else
        return Text('${-days} days overdue',
            style: TextStyle(
              color: Colors.red,
            ));
    } else if (days == 0) {
      return Text('Today',
          style: TextStyle(
            color: Color(0xFF098cec),
          ));
    } else if (days == 1) {
      return Text('$days day left',
          style: TextStyle(
            color: Color(0xFF098cec),
          ));
    } else
      return Text('$days days left',
          style: TextStyle(
            color: Color(0xFF098cec),
          ));
  }

  void playSound() {
    final player = AudioCache();
    player.play('final.wav');
  }

}

class AddTaskValidator {
  static String validate(String value){
      if (value.isEmpty) {
        return 'Forgot to enter task ?';
      }else
      return null;
  }
}