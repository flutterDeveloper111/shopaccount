//import 'package:account/notifications/notificationservice.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();

    tz.initializeTimeZones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History Screen"),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                // NotificationService().cancelAllNotifications();
              },
              child: Container(
                height: 40,
                width: 200,
                color: Colors.red,
                child: const Center(
                  child: Text(
                    "Cancel All Notifications",
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                // NotificationService().showNotification(1, "title", "body", 10);
              },
              child: Container(
                height: 40,
                width: 200,
                color: Colors.green,
                child: const Center(
                  child: Text("Show Notification"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
