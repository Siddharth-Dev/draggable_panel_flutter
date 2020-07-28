import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DraggablePanel extends StatefulWidget {

  final Widget topChild;
  final Widget bottomChild;
  final double topChildHeight;
  final double topChildDockHeight;
  final double topChildDockWidth;
  final bool scale;
  final double scaleBy;
  final bool defaultShow;
  final DragListener listener;

  DraggablePanel({Key key, @required this.topChild, @required this.bottomChild, this.topChildHeight = 200, this.topChildDockWidth = 300, this.topChildDockHeight = 150, this.scale = true, this.scaleBy = .75, this.listener, this.defaultShow}): super(key: key) {
    assert(topChild != null);
    assert(bottomChild != null);
  }

  @override
  DraggableState createState() => DraggableState(defaultShow);

}

class DraggableState extends State<DraggablePanel> {


  double _containerWidth;
  double _containerHeight;
  double _minWidth;
  double _minHeight;
  bool _hide = false;
  double _top = 0;
  double _left = 0;
  double _right = 0;
  double _horizontalDrag;
  int animationD = 200;
  bool _isMinimised = false;
  bool _pop;
  Size screenSize;
  double _upperLimit, _lowerLimit;
  double _scale = 1;

  DraggableState(this._hide);

  show() {
    setState(() {
      _hide = false;
    });
  }

  hide() {
    setState(() {
      _hide = true;
    });
  }

  bool isMinimised() => _isMinimised;

  bool isMaximised() => !_isMinimised;

  minimise() {
    _dragDown();
  }

  maximise() {
    _dragUp();
  }

  @override
  Widget build(BuildContext context) {
    _init();
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: _hide
            ? Container()
            : Stack(
          children: <Widget>[
            AnimatedPositioned(
              duration: Duration(milliseconds: animationD),
              top: _top,
              left: _left,
              right: _right,
              onEnd: () {
                if (isMinimised() && _pop) {
                  print("Finished");
                  Navigator.pop(context);
                }
              },
              child: GestureDetector(

                onTap: () {
                  if (_isMinimised) {
                    animationD = 500;
                    _dragUp();
                  }
                },

                onHorizontalDragEnd: (detail){
                  bool isHorizontal = detail.primaryVelocity < 0;
                  double velocity = detail.primaryVelocity < 0 ? -detail.primaryVelocity : detail.primaryVelocity;
                  if (_isMinimised) {
                    if (velocity > 800) {
                      animationD = 500;
                      if (isHorizontal) {
                        _dragLeft();
                      } else {
                        _dragRight();
                      }
                    } else {
                      animationD = 300;
                      _dockPosition();
                    }
                  }
                },


                onHorizontalDragUpdate: (detail) {

                  if (_isMinimised){
                    animationD = 300;
                    _horizontalDrag = detail.primaryDelta;
                    print("Primary Delta ${detail.primaryDelta}");
                    print("Dx ${detail.delta.dx}");

                    _left = _left + _horizontalDrag;
                    _right = _right - _horizontalDrag;
                    setState(() {

                    });
                  }

                },

                onVerticalDragEnd: (detail){
                  if (!_isMinimised) {
                    if (detail.primaryVelocity > 600) {
                      animationD = 500;
                      _dragDown();
                    } else if (_top < screenSize.height / 3) {
                      animationD = 500;
                      _dragUp();
                    } else {
                      animationD = 500;
                      _dragDown();
                    }
                  }
                },

                onVerticalDragUpdate: (detail){

                  if (!_isMinimised) {
                    _pop = false;
                    animationD = 200;
                    _top = _top + detail.primaryDelta;
                    bool isUp = detail.primaryDelta < 0;

                    if (isUp) {
                      if (_containerHeight < widget.topChildHeight ||
                          _containerWidth < screenSize.width) {
                        _containerHeight++;
                        _containerWidth++;
                        if (_containerHeight >= widget.topChildHeight) {
                          _containerHeight = widget.topChildHeight;
                        }

                        if (_containerWidth >= screenSize.width) {
                          _containerWidth = screenSize.width;
                        } else {
                          _left--;
                        }
                      }

                    } else if (_top + widget.topChildHeight >= _upperLimit &&
                        _top + widget.topChildHeight <= _lowerLimit) {
                      _containerHeight--;
                      _containerWidth--;
                      if (_containerHeight <= _minHeight) {
                        _containerHeight = _minHeight;
                      }

                      if (_containerWidth <= _minWidth) {
                        _containerWidth = _minWidth;
                      } else {
                        _left++;
                      }
                    }

                    if (widget.scale) {
                      _scale = _containerHeight / widget.topChildHeight;
                    }

                    if (_top < 0) {
                      _top = 0;
                    } else if (_top + widget.topChildHeight >= (screenSize.height)) {
                      _top = screenSize.height - widget.topChildHeight;
                      _isMinimised = true;
                    }
                  }

                  setState(() {
                  });
                },
                child: Transform.scale(
                  scale: _scale,
                  alignment: Alignment.topRight,
                  child: Container(
                      width: widget.scale ? screenSize.width : _containerWidth,
                      height: widget.scale ? widget.topChildHeight : _containerHeight,
                      child: AbsorbPointer(
                          absorbing: _isMinimised,
                          child: widget.topChild)),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: animationD),
              left: 0,
              top: (_top + widget.topChildHeight),
              height: screenSize.height - widget.topChildHeight,
              width: screenSize.width,
              child: widget.bottomChild,
            )
          ],
        )
    );
  }

  _dragDown() {
    _top = screenSize.height - widget.topChildHeight;
    _containerWidth = _minWidth;
    _containerHeight = _minHeight;
    _left = screenSize.width - _minWidth;
    _right =0;
    _horizontalDrag = 0;
    _isMinimised = true;
    _scale = widget.scale ? widget.scaleBy : 1;
    widget.listener?.onMinimised();
    setState(() {

    });
  }

  _dragUp() {
    _top = 0;
    _containerWidth = screenSize.width;
    _containerHeight = widget.topChildHeight;
    _right = 0;
    _left = 0;
    _isMinimised = false;
    widget.listener?.onMaximised();
    _horizontalDrag = 0;
    _scale = 1;
    setState(() {

    });
  }

  _dragLeft() {
    _left = -_minWidth;
    _right = screenSize.width;
    _pop = true;
    _horizontalDrag = 0;
    setState(() {

    });
  }

  _dragRight() {
    _left = screenSize.width;
    _right = - _minWidth;
    _pop = true;
    _horizontalDrag = 0;
    setState(() {

    });
  }

  _dockPosition() {
    _pop = false;
    _left = screenSize.width - _minWidth;
    _right =0;
    _horizontalDrag = 0;
    setState(() {

    });
  }

  _init() {
    if (screenSize == null) {
      screenSize = MediaQuery.of(context).size;
      _containerHeight = widget.topChildHeight;
      _containerWidth = screenSize.width;
      _minWidth = widget.scale ? (_containerWidth * widget.scaleBy) : widget.topChildDockWidth;
      _minHeight = widget.scale ? (_containerHeight * widget.scaleBy) : widget.topChildDockHeight;
      _upperLimit = screenSize.height - _minHeight < _minWidth ? _minHeight : _minWidth;
      _lowerLimit = screenSize.height;
    }
  }
}

abstract class DragListener {
  onMinimised();
  onMaximised();
  onDrag(double dragPosition);
}