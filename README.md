# draggble_pannel_flutter

Plugin to replicate the DraggabePanel functionality as in Draggable panel in Android.

When the top widget is dragged to bottom it is scaled down using the scale factor.
You can choose to either go by Scale or go with minWidth & minHeight.

### Code
Two main class 1) DraggablePanel 2) DraggablePanelWithParent
```
DraggablePanel(
  topChild: Container(color: Colors.blue, alignment: Alignment.center, child: Icon(Icons.filter, size: 50,),),
  bottomChild: Container(color:  Colors.red,),)
```
```
DraggablePanelWithParent(
parent: Container(color: Colors.grey)
topChild: Container(color: Colors.blue, alignment: Alignment.center, child: Icon(Icons.filter, size: 50,),),
bottomChild: Container(color:  Colors.red,),)
```
1) You can push it as new screen (But you won't be able to touch the back stack widget)
```
Navigator.of(context).push(TransparentRoute(
  builder: (ctx) => DraggablePanel(
    topChild: Container(color: Colors.blue, alignment: Alignment.center, child: Icon(Icons.filter, size: 50,),),
    bottomChild: Container(color:  Colors.red,),
  )
));
```
2) If you want to touch the back stack widget when the panel is minimized, use-
```
DraggablePanelWithParent(
  parent: Container(color:  Colors.grey,)
  topChild: Container(color: Colors.blue, alignment: Alignment.center, child: Icon(Icons.filter, size: 50,),),
  bottomChild: Container(color:  Colors.red,),)
```
With above you will be able to touch parent container and can perform action on the same.
You can also perform operation like show/hide panel, add widgets in between Parent and Panel by accessing the panel state:
```
GlobalKey<DraggableState> _draggableKey = GlobalKey<DraggableState>();
_draggableKey.currentState.show();
_draggableKey.currentState.addWidgetInBetween(Scaffold(body: Container(),));
```

Other properties of the DraggablePanel-
  - parent: Parent Widget, widget that you want to place behind the DraggablePanel. Only available in DraggablePanelWithParent class.
  - topChild: The widget you want to show at top of panel
  - bottomChild: The widget you want to show after top widget, that covers the remainig panel area.
  - scale: Whether to use the scale factor when reducing the top widget on dragging
  - scaleBy: The factor by which the scale is done (default is .75)
  - topChildHeight: The height of the top widget
  - topChildDockWidth: The width when the top widget is dragged down
  - topChildDockHeight: The height when the top widget is dragged down
  - listener: Listener to get callback when the panel is Dragged, minimised, maximised
  - defaultShow: Initial state of panel show/hide

### Note: As you can see we have to place every widget inside same stack to access the touch event from panel when minimised.I am looking for something which may allow us to pass touch events to back widget without placing them in same stack. In case you find anything let me know.