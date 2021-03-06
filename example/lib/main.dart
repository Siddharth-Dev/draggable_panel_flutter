import 'package:draggable_panel_flutter_example/draggable_example_four.dart';
import 'package:flutter/material.dart';

import 'draggable_new_screen_example.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: ExampleApp());
  }
}

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Draggable Panel Example'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            _getButton("New Screen Example", () {
              _pushNewScreen(context, DraggableExampleOne());
            }),
            SizedBox(
              height: 10,
            ),
            _getButton("Parent passed to draggable panel", () {
              _pushNewScreen(context, DraggableExampleFour());
            }),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  _pushNewScreen(BuildContext context, Widget widget) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
  }

  Widget _getButton(String name, Function onPressed) {
    return FlatButton(
      color: Colors.blue,
      child: Text(name),
      onPressed: onPressed,
    );
  }
}
