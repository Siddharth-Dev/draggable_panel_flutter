import 'dart:io';
import 'package:draggable_panel_flutter/draggable_panel_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class DraggableExampleFour extends StatefulWidget {
  DraggableExampleState createState() => DraggableExampleState();
}

class DraggableExampleState extends State<DraggableExampleFour> {
  GlobalKey<DraggableState> _globalKey = GlobalKey<DraggableState>();
  int _currentTabIndex = 0;
  List<Widget> widgetsAdded = List();

  static Size getDockPanelSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double containerWidth = width * .8;
    double containerHeight = containerWidth * 8 / 16;
    return Size(containerWidth, containerHeight);
  }

  static double getToSectionHeight(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return height * .3;
  }

  @override
  Widget build(BuildContext context) {
    Size dockStateSize = getDockPanelSize(context);
    final double additionalBottomPadding =
        math.max(MediaQuery.of(context).padding.bottom - 14 / 2.0, 0.0);
    double margin = kBottomNavigationBarHeight + additionalBottomPadding;
    return WillPopScope(
      onWillPop: onBackPressed,
      child: DraggablePanel(
        key: _globalKey,
        parent: Scaffold(
          appBar: AppBar(
            title: Text("Draggable code in same stack"),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home), title: Text("Home")),
              BottomNavigationBarItem(
                  icon: Icon(Icons.contacts), title: Text("Contact")),
              BottomNavigationBarItem(
                  icon: Icon(Icons.list), title: Text("My List")),
              BottomNavigationBarItem(
                  icon: Icon(Icons.explore), title: Text("Explore")),
            ],
            onTap: (index) {
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
              Padding(
                  padding: EdgeInsets.all(15),
                  child: Text("Tab ${_currentTabIndex + 1}")),
              SizedBox(
                height: 20,
              ),
              FlatButton(
                color: Colors.grey,
                child: Text("Open widget in between"),
                onPressed: () {
                  _addWidgetsInBetween(NewScreen("Settings", this));
                },
              ),
              SizedBox(
                height: 20,
              ),
              FlatButton(
                color: Colors.grey,
                child: Text("Open Player"),
                onPressed: () {
                  _globalKey.currentState.resetAttributes();
                  _globalKey.currentState.show(reset: true);
                },
              ),
            ],
          ),
        ),
        topChild: TopSectionWidget(_globalKey),
        bottomChild: BottomChild(),
        childBetweenTopAndBottom: SliderWidget(),
        childBetweenTopAndBottomHeight: 14,
//        childBetweenTopAndBottomWidth: MediaQuery.of(context).size.width + 20,
//        childBetweenTopAndBottomLeftMargin: -5,
//        childBetweenTopAndBottomRightMargin: -5,
        defaultShow: false,
        topChildDockWidth: dockStateSize.width,
        topChildDockHeight: dockStateSize.height,
        topChildHeight: getToSectionHeight(context),
        dockStateBottomMargin: margin,
        dockModeCornerRadius: 6,
      ),
    );
  }

  Future<bool> onBackPressed() async {
    if (widgetsAdded.length > 0) {
      Widget widget = widgetsAdded.removeLast();
      _globalKey.currentState.removeWidget(widget);
      return false;
    }

    if (_globalKey.currentState.canHandleBack()) {
      _globalKey.currentState.onBackPressed();
      return false;
    }

    return true;
  }

  _addWidgetsInBetween(Widget widget) {
    widgetsAdded.add(widget);
    _globalKey.currentState.addWidgetInBetween(widget);
  }
}

class TopSectionWidget extends StatefulWidget {
  final GlobalKey<DraggableState> _globalKey;

  TopSectionWidget(this._globalKey);

  @override
  State<StatefulWidget> createState() {
    return _TopSectionState();
  }
}

class _TopSectionState extends State<TopSectionWidget> {
  @override
  void initState() {
    print("Top init");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.lightBlue,
      ),
      child: FlatButton(
        child: Text("Full Screen"),
        color: Colors.grey,
        onPressed: () {
          widget._globalKey.currentState.setFullScreen();
        },
      ),
    );
  }

  @override
  void dispose() {
    print("Top dispose");
    super.dispose();
  }
}

class BottomChild extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.red,
      child: Column(
        children: <Widget>[
          Text("Hello welcome to this awesome example"),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
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
        child: Center(
          child: Text("New Screen"),
        ),
      ),
    );
  }

  AppBar getAppBarForNewScreen(String title) {
    return AppBar(
      elevation: 2,
      title: Text(title),
      leading: IconButton(
        icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
        onPressed: () {
          _draggableState.onBackPressed();
        },
      ),
      automaticallyImplyLeading: true,
    );
  }
}

class SliderWidget extends StatefulWidget {
  @override
  SliderWidgetState createState() => new SliderWidgetState();
}

class SliderWidgetState extends State {
  double valueHolder = 20;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
          trackShape: CustomTrackShape(),
          activeTrackColor: Colors.white,
          inactiveTrackColor: Colors.black,
          disabledActiveTrackColor: Colors.brown,
          disabledInactiveTrackColor: Colors.amberAccent),
      child: Slider(
        value: valueHolder,
        activeColor: Colors.white,
        min: 1,
        max: 100,
        onChanged: (double value) {
          setState(() {
            valueHolder = value;
          });
        },
      ),
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  Rect getPreferredRect({
    @required RenderBox parentBox,
    Offset offset = Offset.zero,
    @required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
