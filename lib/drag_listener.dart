import 'package:flutter/cupertino.dart';

abstract class DragListener {
  onMinimised();
  onMaximised();
  onFullScreen();
  onDrag(double dragPosition);
  onExit(BuildContext context);
}