# draggble_pannel_flutter

Plugin to replicate the DraggabePanel functionality as in Draggable panel in Android.

Here the main class is DraggablePannel with accepts two (top and bottom) widget.
When the top panel is dragged to bottom it is scaled down using the scale factor.
You can choose to either go by Scale or go with minWidth & minHeight for top widget.

# Code
Simple use
DraggablePanel(
  topChild: Container(color: Colors.blue, alignment: Alignment.center, child: Icon(Icons.filter, size: 50,),),
  bottomChild: Container(color:  Colors.red,),
)

# 1) You can push it as new screen (But you won't be able to touch the back stack widget)
Navigator.of(context).push(TransparentRoute(
  builder: (ctx) => DraggablePanel(
    topChild: Container(color: Colors.blue, alignment: Alignment.center, child: Icon(Icons.filter, size: 50,),),
    bottomChild: Container(color:  Colors.red,),
  )
));

# 2) If you want to touch the back stack widget when the panel is minimized, use-
DraggablePanel(
  parent: Container(color:  Colors.grey,)
  topChild: Container(color: Colors.blue, alignment: Alignment.center, child: Icon(Icons.filter, size: 50,),),
  bottomChild: Container(color:  Colors.red,),
)
With above you will be able to touch parent container and can perform action on the same.



# I am trying to figure out a way by which I can access the back widget without placing them in the same stack.
# So even if the panel is pushed as a new screen, we can touch the previous screen.

