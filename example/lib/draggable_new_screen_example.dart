import 'package:draggable_panel_flutter/draggable_panel_flutter.dart';
import 'package:draggable_panel_flutter/transparent_page_route.dart';
import 'package:flutter/material.dart';

class DraggableExampleOne extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Draggable As new screen"),),
      body: Container(
        alignment: Alignment.center,
        child: FlatButton(
          color: Colors.grey,
          child: Text("Open Pannel"),
          onPressed: () {
            Navigator.of(context).push(TransparentRoute(
              builder: (ctx) => DraggablePanel(
                topChild: Container(color: Colors.blue, alignment: Alignment.center, child: Icon(Icons.filter, size: 50,),),
                bottomChild: Container(color:  Colors.red,),
              )
            ));
          },
        ),
      ),

    );
  }
}