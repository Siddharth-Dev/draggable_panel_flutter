import 'dart:async';

import 'package:draggable_panel_flutter/orientation_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final int autoDragAnimationDuration;
  final bool defaultShow;
  final Color backgroundColor;
  final DragListener listener;

  DraggablePanel({Key key, this.parent, @required this.topChild, @required this.bottomChild, this.childBetweenTopAndBottom, this.topChildHeight = 200, this.topChildDockWidth = 300, this.topChildDockHeight = 150, this.listener, this.defaultShow = true, this.backgroundColor = Colors.transparent, this.defaultTopPadding, this.dockStateBottomMargin = 50, this.childBetweenTopAndBottomHeight = 10, this.childBetweenTopAndBottomWidth = double.maxFinite, this.childBetweenTopAndBottomLeftMargin = 0, this.childBetweenTopAndBottomRightMargin = 0, this.autoDragAnimationDuration = 300}): super(key: key) {
    assert(topChild != null);
    assert(bottomChild != null);
  }

  @override
  DraggableState createState() => DraggableState(!defaultShow, topChildHeight);

}

class DraggableState extends State<DraggablePanel> with SingleTickerProviderStateMixin {


  double maxDockStateHeight = 0;
  double _defaultTopPadding = 0;
  double _systemStatusBarHeight;
  double _containerWidth;
  double _containerHeight;
  double _minWidth;
  double _minHeight;
  double _originalToHeight;
  bool _hide = false;
  double _top = 0;
  double _maxTop = 0;
  double _left = 0;
  double _right = 0;
  double _horizontalDrag;
  int animationD = 0;
  bool _isMinimised = false;
  bool _pop;
  Size screenSize;
  Size _originalScreenSize;
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
  Animation<double> animation;
  AnimationController controller;
  bool _isUp = false;

  DraggableState(this._hide, this._originalToHeight){
    if (_hide) {
      _betweenChildVisible = false;
    }
  }

  @override
  initState() {
    controller =
        AnimationController(duration: Duration(milliseconds: widget.autoDragAnimationDuration), vsync: this);

    super.initState();
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

  bool isFullScreen() => _isFullScreen;

  bool isDraggingVertical() => _verticalDragging;

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
    if (_isFullScreen) {
      _dragUp();
    } else if (!_isMinimised){
      _dragDown();
    } else {
      animationD = widget.autoDragAnimationDuration;
      _dragLeft();
    }
    _isFullScreen = false;
    OrientationUtils.setPortraitModeAll();
  }

  resetAttributes({bool notifyStateChange = false}) {
    _pop = false;
    _top = _defaultTopPadding;
    _containerWidth = screenSize.width;
    _containerHeight = _originalToHeight;
    _right = 0;
    _left = 0;
    _isMinimised = false;
    widget.listener?.onMaximised();
    _horizontalDrag = 0;
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
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    animationD = 0;
                    _betweenChildVisible = true;
                  });
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
                      animationD = widget.autoDragAnimationDuration;
                      if (isHorizontal) {
                        _dragLeft();
                      } else {
                        _dragRight();
                      }
                    } else {
                      animationD = widget.autoDragAnimationDuration;
                      _dockPosition();
                    }
                  }
                },


                onHorizontalDragUpdate: (detail) {
                  if (_isFullScreen) {
                    return;
                  }
                  if (_isMinimised){
                    animationD = 0;
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
                      _dragDown();
                    } else if (_top < screenSize.height / 3) {
                      _dragUp();
                    } else {
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
                    animationD = 0;
                    _top = _top + detail.primaryDelta;
                    widget?.listener?.onDrag(_top);
                    bool isUp = detail.primaryDelta < 0;
                    _updateVerticalState(isUp);
                  }

                },
                child: Container(
                  width: _containerWidth,
                  height: _containerHeight,
                  child: AbsorbPointer(
                      absorbing: _isMinimised,
                      child: widget.topChild),
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
              left: !_betweenChildVisible ? screenSize.width + 100 : 0 + widget.childBetweenTopAndBottomLeftMargin,
              right: 0 + widget.childBetweenTopAndBottomRightMargin,
              top: _top + _originalToHeight - widget.childBetweenTopAndBottomHeight/2,
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
    double value = (_containerHeight + widget.dockStateBottomMargin);
    return value > _originalToHeight ? _originalToHeight : value;
  }

  _updateVerticalState(bool isUp) {
    if (isUp) {
      _containerHeight = _originalToHeight - ((_top - _defaultTopPadding) * _minScaleY);
      _containerWidth = screenSize.width - ((_top - _defaultTopPadding) * _minScaleX);
      if (_containerHeight >= _originalToHeight) {
        _containerHeight = _originalToHeight;
      }

      if (_containerWidth >= screenSize.width) {
        _containerWidth = screenSize.width;
      }

    } else {
      _containerHeight = _originalToHeight - ((_top - _defaultTopPadding) * _minScaleY);
      _containerWidth = screenSize.width - ((_top - _defaultTopPadding) * _minScaleX);

      if (_containerHeight <= _minHeight) {
        _containerHeight = _minHeight;
      }

      if (_containerWidth <= _minWidth) {
        _containerWidth = _minWidth;
      }

    }

    _left = screenSize.width - _containerWidth;


    if (_top <= _defaultTopPadding) {
      _dragUpState();
      widget.listener?.onMaximised();
      controller?.stop();
    } else if (_top + maxDockStateHeight >= (screenSize.height)) {
      _dragDownState();
      widget.listener?.onMinimised();
      controller?.stop();
    }

    setState(() {
    });
  }

  _fullScreen() {
    animationD = 0;
    _isFullScreen = true;
    _top = 0;
    _right = 0;
    _left = 0;
    _isMinimised = false;
    _betweenChildVisible = false;
    widget.listener?.onFullScreen();
    _horizontalDrag = 0;
  }

  _dragDown() {
    _isUp = false;
    _animateTo(_top, _maxTop);
  }

  _dragUp() {
    _isUp = true;
    _animateTo(_top >=_maxTop ? _maxTop-1 : _top, _defaultTopPadding);
  }

  _dragUpState() {
    _top = _defaultTopPadding;
    _containerWidth = screenSize.width;
    _containerHeight = _originalToHeight;
    _right = 0;
    _left = 0;
    _isMinimised = false;
    _horizontalDrag = 0;
    _verticalDragging = false;
  }

  _dragDownState() {
    _top = screenSize.height - maxDockStateHeight;
    _containerWidth = _minWidth;
    _containerHeight = _minHeight;
    _isMinimised = true;
    _betweenChildVisible = false;
    _left = screenSize.width - _minWidth;
    _right = 0;
    _verticalDragging = false;
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

  _animateTo(double from, double end) {
    controller?.stop();
    controller?.reset();

    animation = Tween<double>(begin: from, end: end).animate(controller)
      ..addListener(() {
        animationD = 0;
        _top = animation.value;
        _updateVerticalState(_isUp);
      });

    controller.forward();

  }

  _init() {
    _afterBuildUpdate();
    _isOrientationChanged = previousOrientation == null ? false : previousOrientation != MediaQuery.of(context).orientation;
    previousOrientation = MediaQuery.of(context).orientation;
    if (OrientationUtils.isLandscape(context)) {
      animationD = 0;
      SystemChrome.setEnabledSystemUIOverlays([]);
      _fullScreen();
    } else if (_isOrientationChanged) {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
      animationD = 0;
      _betweenChildVisible = true;
      _isFullScreen = false;
      _forceLandscape = false;
      _dragUpState();
    }
    if (screenSize == null || _isOrientationChanged) {

      if (_originalScreenSize == null) {
        _originalScreenSize = MediaQuery.of(context).size;
      }
      if (_systemStatusBarHeight == null) {
        _systemStatusBarHeight = MediaQuery.of(context).padding.top;
      }
      if (widget.defaultTopPadding == null) {
        _defaultTopPadding = _systemStatusBarHeight;
      } else {
        _defaultTopPadding = widget.defaultTopPadding;
      }
      screenSize =  Size(_isFullScreen ? _originalScreenSize.height : _originalScreenSize.width, _isFullScreen ? _originalScreenSize.width : _originalScreenSize.height);
      maxDockStateHeight = widget.topChildDockHeight + widget.dockStateBottomMargin;
      _top = _isFullScreen ? 0 : _defaultTopPadding;
      _containerHeight = _isFullScreen ? screenSize.height : _originalToHeight;
      _containerWidth = screenSize.width;
      _minWidth = widget.topChildDockWidth;
      _minHeight = widget.topChildDockHeight;
      double heightDiff = _originalToHeight - widget.topChildDockHeight;
      double widthDiff = screenSize.width - widget.topChildDockWidth;
      _maxTop = screenSize.height - maxDockStateHeight;
      double topDiff = _maxTop - _defaultTopPadding;

      _minScaleY = heightDiff / topDiff;
      _minScaleX = widthDiff / topDiff;
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