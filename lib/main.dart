import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'call_state_service.dart';
import 'home.dart';
import 'permissions_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  CallStateService.startServiceListening();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: checkPermissions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            if (snapshot.data == true) {
              return FutureBuilder<String>(
                future: getUserName(),
                builder: (context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else {
                    final String userName = snapshot.data ?? '';
                    return Home();
                  }
                },
              );
            } else {
              return Scaffold(
                body: Center(child: Text("Permissions not granted!")),
              );
            }
          }
        },
      ),
    );
  }

  Future<String> getUserName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName') ?? '';
  }
}
