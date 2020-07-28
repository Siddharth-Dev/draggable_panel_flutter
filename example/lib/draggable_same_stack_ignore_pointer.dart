import 'package:draggable_panel_flutter/draggable_panel_flutter_ignore_pointer.dart';
import 'package:flutter/material.dart';

class DraggableExampleThree extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Stack(
        children: <Widget>[
          Scaffold(
            appBar: AppBar(
              title: Text("With ignore pointer"),
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
          DraggablePanelIgnorePointer(
            topChild:   Container(color: Colors.blue, alignment: Alignment.center, child: Icon(Icons.feedback, size: 80,),),
            bottomChild: Container(color: Colors.red,),
          )
        ]
    );
  }
}