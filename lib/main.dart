import 'package:flutter/material.dart';
import 'screens/home.dart';

void main() => runApp(MyApp());
/*
class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}
*/
class MyApp extends StatelessWidget {
  // @override
  // void initState() {
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(title: 'Home'),
    );
  }


}
