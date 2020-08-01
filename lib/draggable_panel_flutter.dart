import 'dart:async';

import 'package:draggable_panel_flutter/orientation_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'drag_listener.dart';

class DraggablePanel extends StatefulWidget {

  final Widget parent;
  final Widget topChild;
  final Widget bottomChild;
  final Widget childBetweenTopAndBottom;
  final double topChildHeight;
  final double topChildDockHeight;
  final double topChildDockWidth;
  final double dockStateBottomMargin;
  final double defaultTopPadding;
  final double childBetweenTopAndBottomHeight;
  final double childBetweenTopAndBottomWidth;
  final double childBetweenTopAndBottomLeftMargin;
  final double childBetweenTopAndBottomRightMargin;
  final bool defaultShow;
  final Color backgroundColor;
  final DragListener listener;

  DraggablePanel({Key key, this.parent, @required this.topChild, @required this.bottomChild, this.childBetweenTopAndBottom, this.topChildHeight = 200, this.topChildDockWidth = 300, this.topChildDockHeight = 150, this.listener, this.defaultShow = true, this.backgroundColor = Colors.transparent, this.defaultTopPadding, this.dockStateBottomMargin = 50, this.childBetweenTopAndBottomHeight = 10, this.childBetweenTopAndBottomWidth = double.maxFinite, this.childBetweenTopAndBottomLeftMargin = 0, this.childBetweenTopAndBottomRightMargin = 0}): super(key: key) {
    assert(topChild != null);
    assert(bottomChild != null);
  }

  @override
  DraggableState createState() => DraggableState(!defaultShow);

}

class DraggableState extends State<DraggablePanel> {


  double maxDockStateHeight = 0;
  double _defaultTopPadding = 0;
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
  double _scaleY = 1;
  double _scaleX = 1;
  double _minScaleX;
  double _minScaleY;
  bool _isFullScreen = false;
  Orientation previousOrientation;
  bool _isOrientationChanged = false;
  List<Widget> _backWidgets = List();
  Timer _debounce;
  bool _forceLandscape = false;
  bool _verticalDragging = false;
  bool _betweenChildVisible = false;

  DraggableState(this._hide){
    if (_hide) {
      _betweenChildVisible = false;
    }
  }

  addWidgetInBetween(Widget widget) {
    _backWidgets.add(widget);
    setState(() {});
  }

  removeWidget(Widget widget) {
    _backWidgets.remove(widget);
    setState(() {});
  }

  show({bool reset = false}) {
    animationD = 0;
    if (reset) {
      resetAttributes();
    }
    if (!_isFullScreen) {
      _betweenChildVisible = true;
    }
    setState(() {
      _hide = false;
    });
  }

  hide() {
    setState(() {
      _hide = true;
      _betweenChildVisible = false;
    });
  }

  bool isMinimised() => _isMinimised;

  bool isMaximised() => !_isMinimised;

  bool isShown() => !_hide;

  minimise() {
    _dragDown();
  }

  maximise() {
    _dragUp();
  }

  setFullScreen() {
    print("Full screen called");
    _fullScreen();
    _forceLandscape = true;
    OrientationUtils.setLandscapeModeAll();
    setState(() {});
  }

  bool canHandleBack() {
    return !_hide;
  }

  onBackPressed() {
    if (_hide) {
      return;
    }
    animationD = 400;
    if (_isFullScreen) {
      _dragUp();
    } else if (!_isMinimised){
      _dragDown();
    } else {
      _dragLeft();
    }
    _isFullScreen = false;
    OrientationUtils.setPortraitModeAll();
  }

  resetAttributes({bool notifyStateChange = false}) {
    _pop = false;
    _top = _defaultTopPadding;
    _containerWidth = screenSize.width;
    _containerHeight = widget.topChildHeight;
    _right = 0;
    _left = 0;
    _isMinimised = false;
    widget.listener?.onMaximised();
    _horizontalDrag = 0;
    _scaleY = 1;
    _scaleX = 1;
    if (notifyStateChange) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    _init();
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Stack(
        children: <Widget>[
          if (widget.parent != null)
            widget.parent,
          for (int i=0;i<_backWidgets.length;i++)
            _backWidgets[i],
          AnimatedPositioned(
            duration: Duration(milliseconds: animationD),
            top: _hide ? screenSize.height : _top,
            left: _left,
            right: _right,
            onEnd: () {
              if (!_isMinimised && !_hide && !_verticalDragging && !_isFullScreen) {
                setState(() {
                  _betweenChildVisible = true;
                });
              }
              if (isMinimised() && _pop) {
                _pop = false;
                print("Finished");
                hide();
                if (widget.listener != null) {
                  widget.listener.onExit(context);
                }
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
                  if (_isFullScreen) {
                    return;
                  }
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
                  if (_isFullScreen) {
                    return;
                  }
                  if (_isMinimised){
                    animationD = 300;
                    _horizontalDrag = detail.primaryDelta;
                    _left = _left + _horizontalDrag;
                    _right = _right - _horizontalDrag;
                    setState(() {

                    });
                  }

                },

                onVerticalDragEnd: (detail){
                  _verticalDragging = false;
                  if (_isFullScreen) {
                    return;
                  }
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

                onVerticalDragCancel: () {
                  _verticalDragging = false;
                },

                onVerticalDragStart: (detail) {
                  if (!_isFullScreen) {
                    _verticalDragging = true;
                  }
                },

                onVerticalDragUpdate: (detail){

                  if (_isFullScreen) {
                    return;
                  }
                  setState(() {
                    _betweenChildVisible = false;
                  });

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

                    } else if (_top > screenSize.height / 4
                        && _top + maxDockStateHeight >= _upperLimit
                        && _top + maxDockStateHeight <= _lowerLimit) {
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

                      if (_left > (screenSize.width - _minWidth)) {
                        _left = screenSize.width - _minWidth;
                      }

                    }


                    if (_top < _defaultTopPadding) {
                      _top = _defaultTopPadding;
                    } else if (_top + maxDockStateHeight >= (screenSize.height)) {
                      _top = screenSize.height - maxDockStateHeight;
                      _containerWidth = _minWidth;
                      _containerHeight = _minHeight;
                      _isMinimised = true;
                      _betweenChildVisible = false;
                      _left = screenSize.width - _minWidth;
                    }

                    _scaleX = _containerWidth / screenSize.width;
                    _scaleY = _containerHeight / widget.topChildHeight;

                    if (isUp) {
                      _scaleX = _scaleX > 1 ? 1 : _scaleX;
                      _scaleY = _scaleY > 1 ? 1 : _scaleY;
                    } else {
                      _scaleX = _scaleX < _minScaleX ? _minScaleX : _scaleX;
                      _scaleY = _scaleY < _minScaleY ? _minScaleY : _scaleY;
                    }
                  }

                  setState(() {
                  });
                },
                child: Transform(
                  transform: Matrix4.diagonal3Values(_scaleX, _scaleY, 1),
                  alignment: Alignment.topRight,
                  child: Container(
                    width: screenSize.width,
                    height: _isFullScreen ?  screenSize.height : widget.topChildHeight,
                    child: AbsorbPointer(
                        absorbing: _isMinimised,
                        child: widget.topChild),
                  ),
                )
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: animationD),
            left: 0,
            top: _isFullScreen || _hide ? screenSize.height : (_top + _bottomTopMargin()),
            height: screenSize.height - _bottomTopMargin(),
            width: screenSize.width,
            child: widget.bottomChild,
          ),

          if (widget.childBetweenTopAndBottom != null)
          Positioned(
            left: !_betweenChildVisible ? screenSize.width : 0 + widget.childBetweenTopAndBottomLeftMargin,
            right: 0 + widget.childBetweenTopAndBottomRightMargin,
            top: _top + widget.topChildHeight - widget.childBetweenTopAndBottomHeight/2,
            child: Container(
                width: widget.childBetweenTopAndBottomWidth,
                height: widget.childBetweenTopAndBottomHeight,
                child: widget.childBetweenTopAndBottom),
          )
        ],
      ),
    );
  }

  double _bottomTopMargin() {
    double value = (widget.topChildHeight * _scaleY + widget.dockStateBottomMargin);
    return value > widget.topChildHeight ? widget.topChildHeight : value;
  }

  _fullScreen() {
    animationD = 0;
    _isFullScreen = true;
    _top = _defaultTopPadding;
    _containerWidth = screenSize.width;
    _containerHeight = screenSize.height;
    _right = 0;
    _left = 0;
    _isMinimised = false;
    _betweenChildVisible = false;
    widget.listener?.onFullScreen();
    _horizontalDrag = 0;
    _scaleY = 1;
    _scaleX = 1;
  }

  _dragDown({bool changeState = true}) {
    _top = screenSize.height - maxDockStateHeight;
    _containerWidth = _minWidth;
    _containerHeight = _minHeight;
    _left = screenSize.width - _minWidth;
    _right =0;
    _horizontalDrag = 0;
    _isMinimised = true;
    _betweenChildVisible = false;
    _scaleY = _minScaleY;
    _scaleX = _minScaleX;
    widget.listener?.onMinimised();
    if (changeState) {
      setState(() {

      });
    }
  }

  _dragUp({bool changeState = true}) {
    _top = _defaultTopPadding;
    _containerWidth = screenSize.width;
    _containerHeight = widget.topChildHeight;
    _right = 0;
    _left = 0;
    _isMinimised = false;
    widget.listener?.onMaximised();
    _horizontalDrag = 0;
    _scaleY = 1;
    _scaleX = 1;
    if (changeState) {
      setState(() {

      });
    }
  }

  _dragLeft({bool changeState = true}) {
    _left = -_minWidth;
    _right = screenSize.width;
    _pop = true;
    _horizontalDrag = 0;
    if (changeState) {
      setState(() {

      });
    }
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
    _afterBuildUpdate();
    _isOrientationChanged = previousOrientation == null ? false : previousOrientation != MediaQuery.of(context).orientation;
    previousOrientation = MediaQuery.of(context).orientation;
    if (OrientationUtils.isLandscape(context)) {
      animationD = 0;
      _fullScreen();
    } else if (_isOrientationChanged) {
      animationD = 0;
      _betweenChildVisible = true;
      _isFullScreen = false;
      _forceLandscape = false;
      _dragUp(changeState: false);
    }
    if (screenSize == null || _isOrientationChanged) {
      print("screenSize changed");
      screenSize = MediaQuery.of(context).size;
      if (widget.defaultTopPadding == null) {
        _defaultTopPadding = MediaQuery
            .of(context)
            .padding
            .top;
      } else {
        _defaultTopPadding = widget.defaultTopPadding;
      }
      maxDockStateHeight = widget.topChildDockHeight + widget.dockStateBottomMargin;
      _top = _defaultTopPadding;
      _containerHeight = widget.topChildHeight;
      _containerWidth = screenSize.width;
      _minWidth = widget.topChildDockWidth;
      _minHeight = widget.topChildDockHeight;
      _upperLimit = screenSize.height - _minHeight < _minWidth ? _minHeight : _minWidth;
      _lowerLimit = screenSize.height;
      _minScaleY = widget.topChildDockHeight / widget.topChildHeight;
      _minScaleX = widget.topChildDockWidth / screenSize.width;
    }
  }

  _afterBuildUpdate() {
    if (_debounce?.isActive ?? false) {
      _debounce.cancel();
    }

    _debounce = Timer(Duration(seconds: 1), () async {
      if (_isMinimised || _hide || _verticalDragging) {
        OrientationUtils.setPortraitModeAll();
      } else if (_forceLandscape){
        OrientationUtils.setLandscapeModeAll();
      } else {
        OrientationUtils.setAutoMode();
      }
    });
  }

}