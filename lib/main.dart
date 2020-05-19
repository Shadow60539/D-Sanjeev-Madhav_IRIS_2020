import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:todoeight/model/task_model.dart';
import 'package:todoeight/provider/task_provider.dart';
import 'package:todoeight/screens/my_homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  Hive.registerAdapter(TaskAdapter());
  Hive.openBox<Task>('tasks');
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TaskProvider>(
      create: (BuildContext context) => TaskProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: FutureBuilder(
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError)
                return Text(snapshot.error.toString());
              else
                return MyHomePage();
            } else
              return Scaffold(
                body: Center(
                  child: Text(
                    'loading  . . .',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Calendar',
                        letterSpacing: 5,
                        fontSize: 30),
                  ),
                ),
                backgroundColor: Colors.black,
              );
          },
          future: Hive.openBox<Task>('tasks'),
        ),
      ),
    );
  }
}
