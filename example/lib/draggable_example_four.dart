import 'dart:io';
import 'package:draggable_panel_flutter/draggable_panel_flutter.dart';
import 'package:flutter/material.dart';

class DraggableExampleFour extends StatefulWidget {

  DraggableExampleState createState() => DraggableExampleState();
}

class DraggableExampleState extends State<DraggableExampleFour> {

  GlobalKey<DraggableState> _globalKey = GlobalKey<DraggableState>();
  int _currentTabIndex = 0;
  List<Widget> widgetsAdded = List();

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: onBackPressed,
      child: DraggablePanel(
        key: _globalKey,
        parent: Scaffold(
          appBar: AppBar(
            title: Text("Draggable code in same stack"),
          ),

          bottomNavigationBar: BottomNavigationBar(items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), title: Text("Home")),
            BottomNavigationBarItem(icon: Icon(Icons.contacts), title: Text("Contact")),
            BottomNavigationBarItem(icon: Icon(Icons.list), title: Text("My List")),
            BottomNavigationBarItem(icon: Icon(Icons.explore), title: Text("Explore")),
          ],
            onTap: (index){
              print("Tab $index cliked");
              _currentTabIndex = index;
              setState(() {});
            },
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.black,
          ),

          body: Column(

            children: <Widget>[

              Padding( padding: EdgeInsets.all(15),child: Text("Tab ${_currentTabIndex+1}")),
              SizedBox(height: 20,),
              FlatButton(
                color: Colors.grey,
                child: Text("Open widget in between"),
                onPressed: (){
                  _addWidgetsInBetween(NewScreen("Settings", this));
                },
              ),
              SizedBox(height: 20,),
              FlatButton(
                color: Colors.grey,
                child: Text("Open Player"),
                onPressed: (){
                  _globalKey.currentState.show(reset: true);
                },
              ),
            ],
          ),
        ),
        topChild:   Container(color: Colors.blue, alignment: Alignment.center, child: Icon(Icons.feedback, size: 80,),),
        bottomChild: Container(color: Colors.red,),
        defaultShow: false,
//        defaultTopPadding: 100,
      ),
    );
  }

  Future<bool> onBackPressed() async {

    if (widgetsAdded.length > 0) {
      Widget widget = widgetsAdded.removeLast();
      _globalKey.currentState.removeWidget(widget);
      return false;
    }

    if (_globalKey.currentState.isShown()) {
      _globalKey.currentState.hide();
      return false;
    }

    return true;
  }

  _addWidgetsInBetween(Widget widget) {
    widgetsAdded.add(widget);
    _globalKey.currentState.addWidgetInBetween(widget);
  }
}

class NewScreen extends StatelessWidget {

  final String title;
  final DraggableExampleState _draggableState;

  NewScreen(this.title, this._draggableState);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBarForNewScreen(title),
      body: Container(
        color: Colors.orange,
        child: Center(child: Text("New Screen"),),
      ),
    );
  }

  AppBar getAppBarForNewScreen(String title) {
    return AppBar(
      elevation: 2,
      title: Text(title),
      leading: IconButton(icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back), onPressed: () {
        _draggableState.onBackPressed();
      },),
      automaticallyImplyLeading: true,
    );
  }
}