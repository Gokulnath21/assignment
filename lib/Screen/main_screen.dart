import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as location;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled4/Utils/utils_class.dart';

import '../Data Class/location.dart';
import '../Notification/notification.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Locations> _locationHistory = [];
  late location.Location _locationService;
  late Timer _timer;
  late SharedPreferences _locationinfo;
  bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  Future<void> locationPermission() async {
    PermissionStatus permissionStatus = await Permission.location.request();
    if (permissionStatus != PermissionStatus.granted) {
      await openAppSettings();
    }
  }

  Future<void> initSharedPreferences() async {
    _locationinfo = await SharedPreferences.getInstance();
  }

  Future<void> conformationDialogBox() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conformation Alert!'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Are you ready to share your location updates'),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              child: const Text(
                'Yes',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () async {
                _locationService = location.Location();
                PermissionStatus permissionStatus =
                    await Permission.location.request();
                PermissionStatus notificationStatus =
                    await Permission.notification.request();
                if (permissionStatus != PermissionStatus.granted) {
                  ToastMessage.showToast("Allow location Permission");
                } else {
                  startLocationUpdates();
                }
                if (notificationStatus != PermissionStatus.granted) {
                  ToastMessage.showToast("Allow notification Permission");
                } else {
                  _getNotification();
                }
                _getNotification();

                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('No', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  Future<void> startLocationUpdates() async {
    _locationService.requestPermission().then((value) {
      if (value == PermissionStatus.granted) {
        _locationService.onLocationChanged
            .listen((location.LocationData result) {
          setState(() {
            _saveLocationData(result);
          });
        });
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      location.LocationData? currentLocation =
          await _locationService.getLocation();
      setState(() {
        _saveLocationData(currentLocation);
      });
    });
  }

  void _getNotification() {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 1,
          channelKey: "basic_channel",
          title: "Hai",
          body: "Location update started"),
    );
  }

  void stopLocationUpdate() {
    _timer.cancel();
    ToastMessage.showToast("Location update has been stopped");
  }

  Future<void> notificationPermission() async {
    PermissionStatus permissionStatus = await Permission.notification.request();
    if (permissionStatus != PermissionStatus.granted) {
      await openAppSettings();
    }
  }

  Future<void> _saveLocationData(location.LocationData? locationData) async {
    if (locationData != null) {
      _locationinfo.setString('latitude', locationData.latitude.toString());
      _locationinfo.setString('longitude', locationData.longitude.toString());
      Locations newLocation =
          Locations(lat: locationData.latitude!, lng: locationData.longitude!);
      _locationHistory.add(newLocation);
    }
  }

  @override
  void initState() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
      onNotificationCreatedMethod:
          NotificationController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod:
          NotificationController.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod:
          NotificationController.onDismissActionReceivedMethod,
    );
    initSharedPreferences();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isMobile(context)) {
      return _mobileScreen();
    } else {
      return _deskTopScreen();
    }
  }

  Widget _mobileScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test App"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(230),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(
                  left: 30,
                  right: 30,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    locationPermission();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5))),
                  child: const Text("Request Location Permission",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(left: 30, right: 30, top: 10),
                child: ElevatedButton(
                  onPressed: () {
                    notificationPermission();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5))),
                  child: const Text("Request Notification Permission",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(left: 30, right: 30, top: 10),
                child: ElevatedButton(
                  onPressed: () {
                    conformationDialogBox();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5))),
                  child: const Text(
                    "Start Location update",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(
                    left: 30, right: 30, top: 10, bottom: 10),
                child: ElevatedButton(
                  onPressed: () {
                    stopLocationUpdate();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5))),
                  child: const Text("Stop Location Update",
                      style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _locationHistory.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(left: 30, right: 30, top: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Request${index + 1}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        child: Row(
                          children: [
                            Text("Lat=${_locationHistory[index].lng}"),
                            const SizedBox(
                              width: 20,
                            ),
                            Text("Lng:${_locationHistory[index].lng}")
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _deskTopScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test App"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: (MediaQuery.of(context).size.width / 2) - 80,
                      margin: const EdgeInsets.only(
                        left: 30,
                        right: 30,
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          locationPermission();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5))),
                        child: const Text("Request Location Permission",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    Container(
                      width: (MediaQuery.of(context).size.width / 2) - 80,
                      margin: const EdgeInsets.only(
                        left: 30,
                        right: 30,
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          notificationPermission();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5))),
                        child: const Text("Request Notification Permission",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: (MediaQuery.of(context).size.width / 2) - 80,
                      margin:
                          const EdgeInsets.only(left: 30, right: 30, top: 10),
                      child: ElevatedButton(
                        onPressed: () {
                          conformationDialogBox();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5))),
                        child: const Text("Start Location update",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    Container(
                      width: (MediaQuery.of(context).size.width / 2) - 80,
                      margin:
                          const EdgeInsets.only(left: 30, right: 30, top: 10),
                      child: ElevatedButton(
                        onPressed: () {
                          stopLocationUpdate();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5))),
                        child: const Text("Stop Location Update",
                            style: TextStyle(color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  childAspectRatio: (10 / 2.5)),
              shrinkWrap: true,
              itemCount: _locationHistory.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 5,
                  height: 100,
                  margin: const EdgeInsets.only(left: 30, right: 30, top: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Request${index + 1}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        child: Row(
                          children: [
                            Text("Lat:${_locationHistory[index].lng}"),
                            const SizedBox(
                              width: 20,
                            ),
                            Text("Lng:${_locationHistory[index].lat}")
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
