import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'station.dart';
import 'stationdata.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
IO.Socket socket = IO.io('https://rewes1.glitch.me',
    IO.OptionBuilder().setTransports(['websocket']).build());

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        StationDetail.nameRoute: (context) => const StationDetail(),
      },
      title: '',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: AnimatedSplashScreen(
        splash: 'images/radi.jpg',
        duration: 1000,
        nextScreen: MyHomePage(),
        splashTransition: SplashTransition.sizeTransition,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  // final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Station> stations = [];
  List<StationData> stationDataList = [];
  StationData stationTemp = StationData.empty();

  void initState() {
    super.initState();
    connectAndListen();
  }

  void connectAndListen() {
    print('Call func connectAndListen');
    socket.onConnect((_) {
      print('connect');
    });

    socket.on('stations', (data) {
      print('from server $data');
      // '{"name":"Tram2","geolocation":{"latitude":10,"longitude":106},"address":"227-NguyenVanCu","id":"8UKlMQhi9uXujou9AAAs"}';
      List<dynamic> _stations = data;
      setState(() {
        stations =
            _stations.map<Station>((json) => Station.fromJson(json)).toList();
      });
      //remove old station when refresh list station
      List<StationData> _stationDataList = [];
      stations.forEach((e1) {
        var index = stationDataList.indexWhere((e2) => e1.id == e2.id);
        if (index > -1) {
          _stationDataList.add(stationDataList[index]);
        } else {}
      });
      stationDataList = _stationDataList;
    });
    socket.on('temp2app', (data) {
      if (mounted) {
        StationData station_data = StationData.fromJson(data);
        var index = stationDataList
            .indexWhere((element) => station_data.id == element.id);
        if (index > -1) {
          stationDataList[index] = station_data;
        } else {
          stationDataList.add(station_data);
        }
        setState(() {
          stationTemp = station_data;
        });
        print(stationDataList.length);
      }
    });

    //When an event recieved from server, data is added to the stream
    socket.onDisconnect((_) => print('disconnect'));
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: null,
      body: ListView.builder(
          itemCount: stations.length,
          itemBuilder: (context, index) {
            return StationItem(
                item: stations[index],
                updatedItem: stationTemp,
                itemList: stationDataList);
          }),
      // bottomNavigationBar: BottomNavigationBar(
      //   // backgroundColor: Color.fromRGBO(71, 73, 246, 1),
      //     items: const [
      //       BottomNavigationBarItem(
      //         icon: Icon(Icons.dashboard,color: Colors.black,),
      //         label: '',
      //       ),
      //   BottomNavigationBarItem(
      //       icon: Icon(Icons.info,color: Colors.black,),
      //       label: '',
      //       )
      // ]),
      // body: Container(
      //   child: Center(
      //     child: Container(
      //       height: 300,
      //       padding: EdgeInsets.symmetric(vertical: 16),
      //       color: Colors.white,
      //       child: ListView(
      //         scrollDirection: Axis.horizontal,
      //         children: stations.length.map
      //       ),
      //     )
      //   ),
      // )// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class StationItem extends StatelessWidget {
  const StationItem(
      {Key? key,
      required this.item,
      required this.updatedItem,
      required this.itemList})
      : super(key: key);
  final Station item;
  final StationData updatedItem;
  final List<StationData> itemList;
  @override
  Widget build(BuildContext context) {
    final index = itemList.indexWhere((element) => element.id == item.id);
    final StationData station_data;
    if (index > -1) {
      station_data = updatedItem.id == item.id ? updatedItem : itemList[index];
    } else {
      station_data = StationData.empty();
    }

    return Column(
      children: [
        const SizedBox(
          height: 130,
        ),
        const Text('Real Time Monitor',
            style: TextStyle(
                fontFamily: 'Rubik-Bold',
                color: Color.fromRGBO(120, 101, 227, 1),
                fontSize: 30,
                letterSpacing: 1)),
    Text(
        '${station_data.date[8]}'
        '${station_data.date[9]}'
        '/'
        '${station_data.date[5]}'
        '${station_data.date[6]}'
        '/'
        '${station_data.date[0]}'
        '${station_data.date[1]}'
        '${station_data.date[2]}'
        '${station_data.date[3]}',
        style: const TextStyle(
          fontFamily: 'Rubik-Bold',
          color: Colors.black,
          fontSize: 15,
          letterSpacing: 1,
        )),
        const Text(
            '1.0 beta',
            style: TextStyle(
              fontFamily: 'Rubik-Bold',
              color: Colors.black,
              fontSize: 15,
              letterSpacing: 1,
            )),
        const SizedBox(
          height: 100,
        ),
        Container(
          height: 200,
          width: 200,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/radi.jpg'),
              fit: BoxFit.fill,
            ),
            shape: BoxShape.circle,
            // boxShadow: [
            //   BoxShadow(
            //       color: Colors.grey.withOpacity(0.6),
            //       offset: Offset(-6, 4),
            //       blurRadius: 10,
            //       spreadRadius: 2),
            // ],
          ),
        ),
        const SizedBox(
          height: 150,
        ),
        InkWell(
          onTap: () {
            print('Clicked ${item.name}');
            socket.emit('join-room', item.id);
            Navigator.pushNamed(context, StationDetail.nameRoute,
                arguments: item);
          },
          splashColor: Colors.grey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 350,
                height: 60,
                //margin: EdgeInsets.symmetric(horizontal: 16,vertical: 16) ,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(120, 101, 227, 1),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                    topRight: Radius.circular(40),
                    topLeft: Radius.circular(40),
                  ),
                  // topLeft: Radius.circular(16),
                  // topRight: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.6),
                        offset: const Offset(-6, 4),
                        blurRadius: 10,
                        spreadRadius: 2),
                  ],
                ),
                child: Column(
                  children: const [
                    // SizedBox(
                    //   height: 20,
                    // ),
                    Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('Station2',
                          style: TextStyle(
                              fontFamily: 'Rubik-Bold',
                              color: Colors.white,
                              fontSize: 15)),
                    ),
                    // const SizedBox(
                    //   height: 35,
                    //   width: 350,
                    //   child: Divider(
                    //     thickness: 2,
                    //     color: Colors.white,
                    //   ),
                    // ),
                    // Text(
                    //     '${station_data.date[8]}'
                    //     '${station_data.date[9]}'
                    //     '/'
                    //     '${station_data.date[5]}'
                    //     '${station_data.date[6]}'
                    //     '/'
                    //     '${station_data.date[0]}'
                    //     '${station_data.date[1]}'
                    //     '${station_data.date[2]}'
                    //     '${station_data.date[3]}',
                    //     style: const TextStyle(
                    //       fontFamily: 'Montserrat-Bold',
                    //       color: Colors.white,
                    //       fontSize: 15,
                    //     )),
                  ],
                ),
                // child: Column(
                //   children: [
                //     Container(
                //       // width:  double.infinity,
                //       width: 300,
                //       height: 200,
                //       margin: EdgeInsets.only(left: 30, top: 250, right: 30, bottom: 50),
                //       //margin: EdgeInsets.symmetric(horizontal: 16,vertical: 16) ,
                //       decoration: BoxDecoration(
                //         color: Colors.white,
                //         borderRadius: const BorderRadius.only(
                //             bottomLeft: Radius.circular(20),
                //             bottomRight: Radius.circular(20),
                //             topLeft: Radius.circular(20),
                //             topRight: Radius.circular(20)),
                //         boxShadow: [
                //           BoxShadow(
                //               color: Colors.grey.withOpacity(0.6),
                //               offset: Offset(-6, 4),
                //               blurRadius: 10,
                //               spreadRadius: 2),
                //         ],
                //       ),
                //       child:
                //         const Center(
                //           child:
                //             Text('',
                //               // item.name,
                //               style: TextStyle(
                //                 fontFamily: 'Montserrat-Bold',
                //                   color: Colors.black,
                //                   fontSize: 25,
                //                   fontWeight: FontWeight.bold),
                //             ),
                //         ),
                //     ),
                //   ],
                // ),
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 60,
          width: 200,
          child: Divider(
            color: Colors.grey,
            thickness: 1.5,
          ),
        ),
      ],
    );
  }
}

class StationDetail extends StatefulWidget {
  const StationDetail({Key? key}) : super(key: key);
  static const nameRoute = '/Detail';
  @override
  _StationDetailState createState() => _StationDetailState();
}

class _StationDetailState extends State<StationDetail> {
  late StationData _stationData;
  bool isLoaded = false;
  void initState() {
    super.initState();
    connectAndListen();
  }

  void connectAndListen() {
    print('Call func connectAndListen in detail');
    socket.onConnect((_) {
      print('connect');
    });
    socket.on('temp2web', (data) {
      print('temp2web from server $data');
      var station = StationData.fromJson(data);
      if (mounted) {
        setState(() {
          isLoaded = true;
          _stationData = station;
        });
      }
      print(_stationData);
    });

    //When an event recieved from server, data is added to the stream
    socket.onDisconnect((_) {
      print('disconnect');
      if (mounted) {
        Navigator.pop(context);
      }
      socket.off('temp2web');
    });
  }

  @override
  Widget build(BuildContext context) {
    // final item = ModalRoute.of(context)!.settings.arguments as Station;

    if (!isLoaded) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      // var mn = Colors.black;
      // var want = double.parse('${_stationData.uSv}');
      // if (want >3.0) {
      //   mn = Colors.red;
      // } else {
      //   mn = Colors.black;
      // }
      return WillPopScope(
        onWillPop: () async {
          print('willPopScope');
          socket.off('temp2web');
          return true;
        },
        child: Scaffold(
          appBar: null,
          body: Column(
            // verticalDirection: VerticalDirection.down,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                child: Column(
                  children: const [
                    Text('Chart is developing, see in next version...'),
                  ],
                ),
              ),
              const SizedBox(
                height: 175,
              ),
              Container(
                width: double.infinity,
                height: 400,
                //margin: EdgeInsets.symmetric(horizontal: 16,vertical: 16) ,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.6),
                        offset: const Offset(-6, 4),
                        blurRadius: 10,
                        spreadRadius: 2),
                  ],
                ),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(
                          width: 28,
                        ),
                        Container(
                          height: 45,
                          width: 45,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('images/temp.jpg'),
                              fit: BoxFit.fill,
                            ),
                            shape: BoxShape.circle,
                            // boxShadow: [
                            //   BoxShadow(
                            //       color: Colors.grey.withOpacity(0.6),
                            //       offset: Offset(-6, 4),
                            //       blurRadius: 10,
                            //       spreadRadius: 2),
                            // ],
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'TEMPERATURE',
                                  style: TextStyle(
                                      fontFamily: 'Rubik-Bold',
                                      color: Colors.black,
                                      fontSize: 15,
                                      letterSpacing: 1),
                                ),
                                const SizedBox(
                                  width: 130,
                                ),
                                Text(
                                  '${_stationData.tempC}',
                                  style: const TextStyle(
                                      fontFamily: 'Rubik-Bold',
                                      color: Colors.black,
                                      fontSize: 15,
                                      letterSpacing: 1),
                                ),
                              ],
                            ),
                            Row(
                              children: const [
                                SizedBox(
                                  width: 270,
                                ),
                                Text(
                                  'oC',
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: Colors.grey,
                                      fontSize: 15,
                                      letterSpacing: 1),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 35,
                      width: 350,
                      child: Divider(
                        color: Colors.grey,
                      ),
                    ),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 28,
                        ),
                        Container(
                          height: 45,
                          width: 45,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('images/humi.jpg'),
                              fit: BoxFit.fill,
                            ),
                            shape: BoxShape.circle,
                            // boxShadow: [
                            //   BoxShadow(
                            //       color: Colors.grey.withOpacity(0.6),
                            //       offset: Offset(-6, 4),
                            //       blurRadius: 10,
                            //       spreadRadius: 2),
                            // ],
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'HUMI',
                                  style: TextStyle(
                                      fontFamily: 'Rubik-Bold',
                                      color: Colors.black,
                                      fontSize: 15,
                                      letterSpacing: 1),
                                ),
                                const SizedBox(
                                  width: 227,
                                ),
                                Text(
                                  '${_stationData.humi}',
                                  style: const TextStyle(
                                      fontFamily: 'Rubik-Bold',
                                      color: Colors.black,
                                      fontSize: 15,
                                      letterSpacing: 1),
                                ),
                              ],
                            ),
                            Row(
                              children: const [
                                SizedBox(
                                  width: 280,
                                ),
                                Text(
                                  '%',
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: Colors.grey,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 35,
                      width: 350,
                      child: Divider(
                        color: Colors.grey,
                      ),
                    ),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 28,
                        ),
                        Container(
                          height: 45,
                          width: 45,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('images/radiation.jpg'),
                              fit: BoxFit.fill,
                            ),
                            shape: BoxShape.circle,
                            // boxShadow: [
                            //   BoxShadow(
                            //       color: Colors.grey.withOpacity(0.6),
                            //       offset: Offset(-6, 4),
                            //       blurRadius: 10,
                            //       spreadRadius: 2),
                            // ],
                          ),
                        ),
                        const SizedBox(
                          width: 18,
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'RADIATION',
                                  style: TextStyle(
                                      fontFamily: 'Rubik-Bold',
                                      color: Colors.black,
                                      fontSize: 15,
                                      letterSpacing: 1),
                                ),
                                const SizedBox(
                                  width: 165,
                                ),
                                Text(
                                  '${_stationData.uSv}',
                                  style: const TextStyle(
                                      fontFamily: 'Rubik-Bold',
                                      color: Colors.black,
                                      fontSize: 15,
                                      letterSpacing: 1),
                                ),
                              ],
                            ),
                            Row(
                              children: const [
                                SizedBox(
                                  width: 250,
                                ),
                                Text(
                                  'uSv/h',
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: Colors.grey,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 35,
                      width: 350,
                      child: Divider(
                        color: Colors.grey,
                      ),
                    ),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 28,
                        ),
                        Container(
                          height: 45,
                          width: 45,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('images/radiation.jpg'),
                              fit: BoxFit.fill,
                            ),
                            shape: BoxShape.circle,
                            // boxShadow: [
                            //   BoxShadow(
                            //       color: Colors.grey.withOpacity(0.6),
                            //       offset: Offset(-6, 4),
                            //       blurRadius: 10,
                            //       spreadRadius: 2),
                            // ],
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Column(
                          children: [
                            Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'CPS',
                                  style: TextStyle(
                                      fontFamily: 'Rubik-Bold',
                                      color: Colors.black,
                                      fontSize: 15,
                                      letterSpacing: 1),
                                ),
                                const SizedBox(
                                  width: 245,
                                ),
                                Text(
                                  '${_stationData.cps}',
                                  style: const TextStyle(
                                      fontFamily: 'Rubik-Bold',
                                      color: Colors.black,
                                      fontSize: 15,
                                      letterSpacing: 1),
                                ),
                              ],
                            ),
                            Row(
                              children: const [
                                SizedBox(
                                  width: 260,
                                ),
                                Text(
                                  'cps',
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: Colors.grey,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 35,
                      width: 350,
                      child: Divider(
                        color: Colors.grey,
                      ),
                    ),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 28,
                        ),
                        Container(
                          height: 45,
                          width: 45,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('images/radiation.jpg'),
                              fit: BoxFit.fill,
                            ),
                            shape: BoxShape.circle,
                            // boxShadow: [
                            //   BoxShadow(
                            //       color: Colors.grey.withOpacity(0.6),
                            //       offset: Offset(-6, 4),
                            //       blurRadius: 10,
                            //       spreadRadius: 2),
                            // ],
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'COUNTS',
                                  style: TextStyle(
                                      fontFamily: 'Rubik-Bold',
                                      color: Colors.black,
                                      fontSize: 15,
                                      letterSpacing: 1),
                                ),
                                const SizedBox(
                                  width: 165,
                                ),
                                Text(
                                  '${_stationData.counts}',
                                  style: const TextStyle(
                                      fontFamily: 'Rubik-Bold',
                                      color: Colors.black,
                                      fontSize: 15,
                                      letterSpacing: 1),
                                ),
                              ],
                            ),
                            Row(
                              children: const [
                                Text(
                                  '',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
