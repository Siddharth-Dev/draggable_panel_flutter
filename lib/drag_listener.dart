import 'package:flutter/cupertino.dart';

abstract class DragListener {
  onMinimised();
  onMaximised();
  onDrag(double dragPosition);
  onExit(BuildContext context);
}