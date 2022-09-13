import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> futureHour;
  String hour = '';

  Future<void> _setNotificationHour(TimeOfDay timeOfDay) async {
    final SharedPreferences prefs = await _prefs;
    hour = timeOfDay.hour.toString().padLeft(2, '0') +
        ':' +
        timeOfDay.minute.toString().padLeft(2, '0');

    setState(() {
      futureHour =
          prefs.setString("notification_hour", hour).then((bool success) {
        return hour;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    futureHour = SharedPreferences.getInstance().then((value) {
      if (value.containsKey("notification_hour") &&
          value.getString("notification_hour") != '') {
        return value.getString("notification_hour") ?? '09:00';
      } else {
        return '09:00';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ڕێکخستنەکان'),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Container(
          height: 120,
          width: double.infinity,
          child: Card(
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.all(
                10,
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'کاتی ئاگادارکردنەوەی ڕۆژبوون',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    Expanded(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FutureBuilder<String>(
                                future: futureHour,
                                builder: (BuildContext context,
                                    AsyncSnapshot<String> snapshot) {
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.waiting:
                                      return const CircularProgressIndicator();
                                    default:
                                      if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      } else {
                                        if (snapshot.data == '') {
                                          return Text('null');
                                        }
                                        return Text(
                                          '${snapshot.data}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline3,
                                        );
                                      }
                                  }
                                }),
                            SizedBox(
                              width: 30,
                            ),
                            SizedBox(
                              height: 40,
                              width: 200,
                              child: ElevatedButton(
                                onPressed: () {
                                  Future<TimeOfDay?> selectedTime =
                                      showTimePicker(
                                    initialTime: TimeOfDay.now(),
                                    context: context,
                                  ).then((value) {
                                    if (value != null) {
                                      _setNotificationHour(value);
                                    }
                                  });
                                },
                                child: Text(
                                  ' ددیاریکردنی کات',
                                  style: Theme.of(context).textTheme.subtitle2,
                                ),
                              ),
                            ),
                          ]),
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
