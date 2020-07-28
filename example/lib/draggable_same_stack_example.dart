import 'package:draggble_pannel_flutter/draggble_pannel_flutter.dart';
import 'package:draggble_pannel_flutter/transparent_page_route.dart';
import 'package:flutter/material.dart';

class DraggableExampleTwo extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Stack(
        children: <Widget>[
          Scaffold(
            appBar: AppBar(
              title: Text("In same stack"),
            ),

            bottomNavigationBar: BottomNavigationBar(items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), title: Text("Home")),
              BottomNavigationBarItem(icon: Icon(Icons.contacts), title: Text("Contact")),
              BottomNavigationBarItem(icon: Icon(Icons.list), title: Text("My List")),
              BottomNavigationBarItem(icon: Icon(Icons.explore), title: Text("Explore")),
            ],
              onTap: (index){
                print("Tab $index cliked");
              },
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.black,
            ),

            body: Container(
              color: Colors.orange,
              width: double.maxFinite,
              height: double.maxFinite,
            ),
          ),
          DraggablePanel(
            topChild:   Container(color: Colors.blue, alignment: Alignment.center, child: Icon(Icons.feedback, size: 80,),),
            bottomChild: Container(color: Colors.red,),
          )
        ]
    );
  }
}