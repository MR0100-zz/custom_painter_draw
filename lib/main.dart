import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:local_notification_demo/paypal_screen.dart';

void main() => runApp(DemoApp());

class DemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PaintDemo(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PaintDemo extends StatefulWidget {
  @override
  _PaintDemoState createState() => _PaintDemoState();
}

class CPath {
  Offset point1;
  Offset point2;
  Offset startFrom;
  Offset endTo;
  Color shapColor;

  CPath({
    this.startFrom,
    this.endTo,
    this.point1,
    this.point2,
    this.shapColor,
  });
}

class _PaintDemoState extends State<PaintDemo> {
  bool save = false;

  List<CPath> draw = [];
  List<CPath> undoDraw = [];
  Color shapColor = Colors.red;

  @override
  void initState() {
    super.initState();
    draw.add(
      CPath(
        startFrom: Offset(0.0, 0.0),
        endTo: Offset(200.0, 0.0),
        point1: Offset(10.0, 0.0),
        point2: Offset(50.0, 0.0),
        shapColor: shapColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    Size screen = Size(screenSize.width, screenSize.height - 100);
    print('rebuild');
    return SafeArea(
      child: Scaffold(
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniStartDocked,
        floatingActionButton: Container(
          width: screen.width - 25,
          height: 70.0,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  child: Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      draw.add(
                        CPath(
                          startFrom: draw[draw.length - 1].endTo,
                          endTo: Offset(200.0, 0.0),
                          point1: Offset(10.0, 0.0),
                          point2: Offset(50.0, 0.0),
                          shapColor: shapColor,
                        ),
                      );
                      undoDraw.clear();
                    });
                  },
                ),
                SizedBox(
                  width: 20.0,
                ),
                FloatingActionButton(
                  child: Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      if (draw.length > 1) {
                        undoDraw.add(draw.last);
                        print(draw.last);
                        draw.removeLast();
                      }
                    });
                  },
                ),
                SizedBox(
                  width: 20.0,
                ),
                FloatingActionButton(
                  child: Icon(Icons.redo),
                  onPressed: () {
                    setState(() {
                      if (undoDraw.length > 0) {
                        draw.add(undoDraw[undoDraw.length - 1]);
                        undoDraw.removeLast();
                      }
                    });
                  },
                ),
                SizedBox(
                  width: 20.0,
                ),
                FloatingActionButton(
                  child: Icon(Icons.save),
                  onPressed: () {
                    setState(() {
                      save = !save;
                    });
                  },
                ),
                SizedBox(
                  width: 20.0,
                ),
                FloatingActionButton(
                    child: Icon(Icons.color_lens),
                    onPressed: () {
                      int selectedShap = 1;
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        child: AlertDialog(
                          title: const Text('Pick a color!'),
                          content: SingleChildScrollView(
                            child: Column(
                              children: [
                                Container(
                                  height: 40.0,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    physics: BouncingScrollPhysics(),
                                    child: Row(
                                      children: [
                                        RaisedButton(
                                          child: Text('Current Shap'),
                                          onPressed: () {
                                            setState(() {
                                              selectedShap = 1;
                                              draw[draw.length - 1].shapColor =
                                                  shapColor;
                                            });
                                          },
                                        ),
                                        SizedBox(width: 5.0),
                                        draw.length > 2
                                            ? RaisedButton(
                                                child: Text('Previous Shap'),
                                                onPressed: () {
                                                  setState(() {
                                                    draw[draw.length - 2]
                                                        .shapColor = shapColor;
                                                    selectedShap = 2;
                                                  });
                                                },
                                              )
                                            : SizedBox(),
                                        SizedBox(width: 5.0),
                                        RaisedButton(
                                          child: Text('Next Shap'),
                                          onPressed: () {
                                            setState(() {
                                              selectedShap = 3;
                                              shapColor = shapColor;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                ColorPicker(
                                  pickerColor: Colors.red,
                                  onColorChanged: (color) {
                                    setState(() {
                                      shapColor = color;
                                      if (selectedShap == 1) {
                                        draw[draw.length - 1].shapColor = color;
                                      } else if (selectedShap == 2) {
                                        draw[draw.length - 2].shapColor = color;
                                      } else {
                                        shapColor = color;
                                      }
                                    });
                                  },
                                  showLabel: true,
                                  pickerAreaHeightPercent: 0.8,
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            FlatButton(
                              child: Text('Set Color'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            )
                          ],
                        ),
                      );
                    }),
              ],
            ),
          ),
        ),
        body: Container(
          height: screen.height,
          width: screen.width,
          child: Stack(
            overflow: Overflow.visible,
            fit: StackFit.expand,
            children: [
              Container(
                width: screen.width,
                height: screen.height,
                child: CustomPaint(
                  child: Center(),
                  painter: GreedPainter(
                    curve1: 35,
                    curve2: 35,
                    curve3: 35,
                    curve4: 35,
                  ),
                ),
              ),
              Column(
                  children: List.generate(
                draw.length,
                (index) => CustomPaint(
                  painter: ThisPainter(
                    point1: draw[index].point1,
                    point2: draw[index].point2,
                    moveToP: draw[index].startFrom,
                    endToP: draw[index].endTo,
                    shapColor: draw[index].shapColor,
                  ),
                  child: Center(),
                ),
              )),
              Positioned(
                top: draw[draw.length - 1].startFrom.dy,
                left: draw[draw.length - 1].startFrom.dx,
                child: GestureDetector(
                  onPanUpdate: (p1u) {
                    print('pos : ${p1u.globalPosition}');
                    double p1ux = 200.0;
                    double p1uy = 0.0;
                    if (p1u.globalPosition.dx > screen.width - 20) {
                      p1ux = screen.width - 20;
                      setState(() {
                        draw[draw.length - 1].startFrom =
                            Offset(p1ux, draw[draw.length - 1].startFrom.dy);
                      });
                    } else if (p1u.globalPosition.dx < 10.0) {
                      p1ux = 10.0;
                      setState(() {
                        draw[draw.length - 1].startFrom =
                            Offset(p1ux, draw[draw.length - 1].startFrom.dy);
                      });
                    } else {
                      p1ux = p1u.globalPosition.dx;
                      setState(() {
                        draw[draw.length - 1].startFrom =
                            Offset(p1ux, draw[draw.length - 1].startFrom.dy);
                      });
                    }

                    if (p1u.globalPosition.dy < 10) {
                      p1uy = 10;
                      setState(() {
                        draw[draw.length - 1].startFrom =
                            Offset(draw[draw.length - 1].startFrom.dx, p1uy);
                      });
                    } else if (p1u.globalPosition.dy > screen.height - 40) {
                      p1uy = screen.height - 40;
                      setState(() {
                        draw[draw.length - 1].startFrom =
                            Offset(draw[draw.length - 1].startFrom.dx, p1uy);
                      });
                    } else {
                      p1uy = p1u.globalPosition.dy;
                      setState(() {
                        draw[draw.length - 1].startFrom =
                            Offset(draw[draw.length - 1].startFrom.dx, p1uy);
                      });
                    }
                  },
                  child: save
                      ? SizedBox()
                      : Container(
                          width: 20.0,
                          height: 20.0,
                          color: Colors.transparent,
                          alignment: Alignment.center,
                          child: Text(
                            'S',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                ),
              ),
              Positioned(
                top: draw[draw.length - 1].endTo.dy,
                left: draw[draw.length - 1].endTo.dx,
                child: GestureDetector(
                  onPanUpdate: (p1u) {
                    print('pos : ${p1u.globalPosition}');
                    double p1ux = 200.0;
                    double p1uy = 0.0;
                    if (p1u.globalPosition.dx > screen.width - 30) {
                      p1ux = screen.width - 30;
                      setState(() {
                        draw[draw.length - 1].endTo =
                            Offset(p1ux, draw[draw.length - 1].endTo.dy);
                      });
                    } else if (p1u.globalPosition.dx < 10.0) {
                      p1ux = 10.0;
                      setState(() {
                        draw[draw.length - 1].endTo =
                            Offset(p1ux, draw[draw.length - 1].endTo.dy);
                      });
                    } else {
                      p1ux = p1u.globalPosition.dx;
                      setState(() {
                        draw[draw.length - 1].endTo =
                            Offset(p1ux, draw[draw.length - 1].endTo.dy);
                      });
                    }

                    if (p1u.globalPosition.dy < 10) {
                      p1uy = 10;
                      setState(() {
                        draw[draw.length - 1].endTo =
                            Offset(draw[draw.length - 1].endTo.dx, p1uy);
                      });
                    } else if (p1u.globalPosition.dy > screen.height - 50) {
                      p1uy = screen.height - 50;
                      setState(() {
                        draw[draw.length - 1].endTo =
                            Offset(draw[draw.length - 1].endTo.dx, p1uy);
                      });
                    } else {
                      p1uy = p1u.globalPosition.dy;
                      setState(() {
                        draw[draw.length - 1].endTo =
                            Offset(draw[draw.length - 1].endTo.dx, p1uy);
                      });
                    }
                  },
                  child: save
                      ? SizedBox()
                      : Container(
                          width: 20.0,
                          height: 20.0,
                          color: Colors.transparent,
                          alignment: Alignment.center,
                          child: Text(
                            'E',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                ),
              ),
              Positioned(
                top: draw[draw.length - 1].point1.dy,
                left: draw[draw.length - 1].point1.dx,
                child: GestureDetector(
                  onPanUpdate: (p1u) {
                    print('pos : ${p1u.globalPosition}');
                    double p1ux = 200.0;
                    double p1uy = 0.0;
                    if (p1u.globalPosition.dx > screen.width - 20) {
                      p1ux = screen.width - 20;
                      setState(() {
                        draw[draw.length - 1].point1 =
                            Offset(p1ux, draw[draw.length - 1].point1.dy);
                      });
                    } else if (p1u.globalPosition.dx < 10.0) {
                      p1ux = 10.0;
                      setState(() {
                        draw[draw.length - 1].point1 =
                            Offset(p1ux, draw[draw.length - 1].point1.dy);
                      });
                    } else {
                      p1ux = p1u.globalPosition.dx;
                      setState(() {
                        draw[draw.length - 1].point1 =
                            Offset(p1ux, draw[draw.length - 1].point1.dy);
                      });
                    }

                    if (p1u.globalPosition.dy < 10) {
                      p1uy = 10;
                      setState(() {
                        draw[draw.length - 1].point1 =
                            Offset(draw[draw.length - 1].point1.dx, p1uy);
                      });
                    } else if (p1u.globalPosition.dy > screen.height - 50) {
                      p1uy = screen.height - 50;
                      setState(() {
                        draw[draw.length - 1].point1 =
                            Offset(draw[draw.length - 1].point1.dx, p1uy);
                      });
                    } else {
                      p1uy = p1u.globalPosition.dy;
                      setState(() {
                        draw[draw.length - 1].point1 =
                            Offset(draw[draw.length - 1].point1.dx, p1uy);
                      });
                    }
                  },
                  child: save
                      ? SizedBox()
                      : Container(
                          width: 20.0,
                          height: 20.0,
                          color: Colors.red,
                          alignment: Alignment.center,
                          child: Text(
                            'P1',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                ),
              ),
              Positioned(
                top: draw[draw.length - 1].point2.dy,
                left: draw[draw.length - 1].point2.dx,
                child: GestureDetector(
                  onPanUpdate: (p1u) {
                    print('pos : ${p1u.globalPosition}');
                    double p1ux = 200.0;
                    double p1uy = 0.0;
                    if (p1u.globalPosition.dx > screen.width - 20) {
                      p1ux = screen.width - 20;
                      setState(() {
                        draw[draw.length - 1].point2 =
                            Offset(p1ux, draw[draw.length - 1].point2.dy);
                      });
                    } else if (p1u.globalPosition.dx < 10.0) {
                      p1ux = 10.0;
                      setState(() {
                        draw[draw.length - 1].point2 =
                            Offset(p1ux, draw[draw.length - 1].point2.dy);
                      });
                    } else {
                      p1ux = p1u.globalPosition.dx;
                      setState(() {
                        draw[draw.length - 1].point2 =
                            Offset(p1ux, draw[draw.length - 1].point2.dy);
                      });
                    }

                    if (p1u.globalPosition.dy < 10) {
                      p1uy = 10;
                      setState(() {
                        draw[draw.length - 1].point2 =
                            Offset(draw[draw.length - 1].point2.dx, p1uy);
                      });
                    } else if (p1u.globalPosition.dy > screen.height - 50) {
                      p1uy = screen.height - 50;
                      setState(() {
                        draw[draw.length - 1].point2 =
                            Offset(draw[draw.length - 1].point2.dx, p1uy);
                      });
                    } else {
                      p1uy = p1u.globalPosition.dy;
                      setState(() {
                        draw[draw.length - 1].point2 =
                            Offset(draw[draw.length - 1].point2.dx, p1uy);
                      });
                    }
                  },
                  child: save
                      ? SizedBox()
                      : Container(
                          width: 20.0,
                          height: 20.0,
                          color: Colors.red,
                          alignment: Alignment.center,
                          child: Text(
                            'P2',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GreedPainter extends CustomPainter {
  final int curve1;
  final int curve2;
  final int curve3;
  final int curve4;

  GreedPainter({this.curve1, this.curve2, this.curve3, this.curve4});
  @override
  void paint(Canvas canvas, Size size) {
    double width = size.width;
    double height = size.height;

    Path greed = Path();

    for (double i = 1.0; i < height; i++) {
      greed.moveTo(i * (width / curve1), 0);
      greed.lineTo(i * (width / curve2), height);
      greed.moveTo(0, i * (width / curve3));
      greed.lineTo(width, i * (width / curve4));
    }

    canvas.drawPath(
        greed,
        Paint()
          ..color = Colors.grey[500]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ThisPainter extends CustomPainter {
  final Offset point1;
  final Offset point2;
  final Offset moveToP;
  final Offset endToP;
  final Color shapColor;

  ThisPainter({
    this.point1,
    this.point2,
    this.moveToP,
    this.endToP,
    this.shapColor,
  });
  @override
  void paint(Canvas canvas, Size size) {
    double width = size.width;
    double height = size.height;

    Path path = Path();
    path.moveTo(moveToP.dx, moveToP.dy);
    print("asd : $point1");

    path.cubicTo(
        point1.dx, point1.dy, point2.dx, point2.dy, endToP.dx, endToP.dy);

    /// cubic Curve..
    /// vertical and horizontal
    Color lineColor2 = shapColor;
    if (moveToP.dy.round() == point1.dy.round() &&
        moveToP.dy.round() == point2.dy.round() &&
        moveToP.dy.round() == endToP.dy.round() &&
        point1.dy.round() == point2.dy.round() &&
        point1.dy.round() == endToP.dy.round() &&
        point2.dy.round() == endToP.dy.round()) {
      print('true');
      lineColor2 = Colors.cyan;
    } else if (moveToP.dx.round() == point1.dx.round() &&
        moveToP.dx.round() == point2.dx.round() &&
        moveToP.dx.round() == endToP.dx.round() &&
        point1.dx.round() == point2.dx.round() &&
        point1.dx.round() == endToP.dx.round() &&
        point2.dx.round() == endToP.dx.round()) {
      lineColor2 = Colors.cyan;
    }

    canvas.drawPath(
        path,
        Paint()
          ..color = lineColor2
          ..strokeWidth = 4.0
          ..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class makePayment extends StatefulWidget {
  @override
  _makePaymentState createState() => _makePaymentState();
}

class _makePaymentState extends State<makePayment> {
  TextStyle style = TextStyle(fontFamily: 'Open Sans', fontSize: 15.0);
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: new Scaffold(
          backgroundColor: Colors.transparent,
          key: _scaffoldKey,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(45.0),
            child: new AppBar(
              backgroundColor: Colors.white,
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Paypal Payment Example',
                    style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.red[900],
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Open Sans'),
                  ),
                ],
              ),
            ),
          ),
          body: Container(
              width: MediaQuery.of(context).size.width,
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () {
                        // make PayPal payment

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) => PaypalPayment(
                              onFinish: (number) async {
                                // payment done
                                print('order id: ' + number);
                              },
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Pay with Paypal',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              )),
        ));
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FlutterLocalNotificationsPlugin _flutterNotification;

  @override
  void initState() {
    super.initState();
    var androidInitialization = AndroidInitializationSettings('app_icon');
    var iOSInitialization = IOSInitializationSettings();
    var initializationsSetting =
        InitializationSettings(androidInitialization, iOSInitialization);
    _flutterNotification = FlutterLocalNotificationsPlugin();
    _flutterNotification.initialize(initializationsSetting,
        onSelectNotification: notificationSelected);
  }

  Future _showNotification() async {
//    AndroidNotificationChannel androidDetails = AndroidNotificationChannel(
//        "Channel Id", "Content", "Description",
//        importance: Importance.Max);
    var androidDetails = AndroidNotificationDetails(
        "Channel_Id", "Content", "Description",
        importance: Importance.Max);
    var iosDetails = IOSNotificationDetails();
    var generalDetails = NotificationDetails(androidDetails, iosDetails);
    await _flutterNotification.show(
        0, "Task", "Created Notification", generalDetails);
  }

  Future _scheduleNotification() async {
    var androidDetails = AndroidNotificationDetails(
        "Channel_Id", "Content", "Description",
        importance: Importance.Max);
    var iosDetails = IOSNotificationDetails();
    var generalDetails = NotificationDetails(androidDetails, iosDetails);

//    _flutterNotification.schedule(
//        0,
//        "Schedule",
//        "This is the scheduled Notification...",
//        (DateTime.parse('2020-09-29')),
//        generalDetails);

    _flutterNotification.periodicallyShow(
        0, "title", "body", RepeatInterval.EveryMinute, generalDetails);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RaisedButton(
            onPressed: _showNotification,
            child: Text('Show Notifications'),
          ),
          RaisedButton(
            onPressed: _scheduleNotification,
            child: Text('Schedule Notification'),
          ),
        ],
      ),
    ));
  }

  Future notificationSelected(String payload) async {}
}
