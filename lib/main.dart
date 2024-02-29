import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:untitled4/Screen/main_screen.dart';

void main() async {
  await AwesomeNotifications().initialize(null, [
    NotificationChannel(
        channelKey: "basic_channel",
        channelName: "Location Notification",
        channelDescription: "Location Notitfication channel")
  ], channelGroups: [
    NotificationChannelGroup(
        channelGroupKey: "basic_channel", channelGroupName: "basic Group")
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF656262))),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const MainScreen();
  }
}
