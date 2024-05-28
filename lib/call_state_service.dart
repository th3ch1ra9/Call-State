import 'dart:async';
import 'dart:ui';
import 'package:call_log/call_log.dart';
import 'package:callstate/FormController.dart';
import 'package:callstate/forny.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'recorder_service.dart';

class CallStateService {
  static const MethodChannel _channel = MethodChannel('call_state_channel');

  static Stream<String> get callStateStream {
    return EventChannel('call_state_event')
        .receiveBroadcastStream()
        .map((dynamic event) => event.toString());
  }

  static Stream<bool> get callStartedStream {
    return callStateStream.map((callState) => callState == 'OFFHOOK');
  }

  static Stream<bool> get callEndedStream {
    return callStateStream.map((callState) => callState == 'IDLE');
  }

  static void startServiceListening() {
    callStartedStream.listen((callStarted) {
      if (callStarted) {
        FlutterBackgroundService().invoke('startRecording');
      }
    });

    callEndedStream.listen((callEnded) {
      if (callEnded) {
        FlutterBackgroundService().invoke('stopRecording');
      }
    });
  }
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground',
    'MY FOREGROUND SERVICE',
    description: 'This channel is used for important notifications.',
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      autoStartOnBoot: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializings',
      foregroundServiceNotificationId: 888,
    ), iosConfiguration: IosConfiguration(autoStart: true),
  );
}

Future<void> onStart(ServiceInstance service) async {
  try {
    await _getAndUploadNewCallLogs();
    print(" uploading call logs");
  } catch (e) {
    print("Error fetching or uploading call logs: $e");
  }

  DartPluginRegistrant.ensureInitialized();
  // await initializeRecorder();

  // if (service is AndroidServiceInstance) {
  //   service.on('startRecording').listen((event) {
  //     startRecording();
  //   });

  //   service.on('stopRecording').listen((event) {
  //     stopRecording();
  //   });
  // }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Timer.periodic(const Duration(seconds: 5), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        await _getAndUploadNewCallLogs();
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final callLogs = await CallLog.get();
        final recentCalls = callLogs.take(1).map((callLog) {
          final timestamp = DateTime.fromMillisecondsSinceEpoch(callLog.timestamp ?? 0);
          return '${callLog.name ?? 'Unknown'} (${callLog.number})';
        }).join('\n');

        flutterLocalNotificationsPlugin.show(
          888,
          'Call Log Service',
          'Recent calls:\n$recentCalls',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'my_foreground',
              'MY FOREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: true,
            ),
          ),
        );
      }
    }
  });
}

Future<void> _getAndUploadNewCallLogs() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    Iterable<CallLogEntry> callLogs = await CallLog.get();
    List<CallLogEntry> newCallLogs = callLogs.where((callLog) => !prefs.containsKey("${callLog.number}_${callLog.timestamp}")).toList();
    for (var callLog in newCallLogs) {
     // Mark call log as uploaded
      await uploadCallLog(callLog);

      final key = "${callLog.number}_${callLog.timestamp}";
      prefs.setBool(key, true);
    }
    print("Call logs updated");
  } catch (e) {
    print("Error fetching or uploading call logs: $e");
  }
}

Future<void> uploadCallLog(CallLogEntry callLog) async {
print("CAlling this ");
  final formController = FormController();
  final startTime = DateTime.fromMillisecondsSinceEpoch(callLog.timestamp!);
  final endTime = startTime.add(Duration(seconds: callLog.duration ?? 0));
  
  final feedbackFor = FeedbackForm(
    callLog.name ?? "null",
    callLog.number ?? 'null',
    callLog.callType.toString().split('.').last,
    callLog.duration?.toString() ?? "null",
    formatDate(callLog.timestamp),
    formatTimestamp(callLog.timestamp),
    formatEndTime(endTime),
  );
  
  await formController.submitForm(feedbackFor, (status) {
    print("Form submitted with status: $status");
  });
  
}

String formatDate(int? timestamp) {
  if (timestamp != null) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String formattedDate = "${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)}";
    return formattedDate;
  } else {
    return "N/A";
  }
}

String _twoDigits(int n) {
  if (n >= 10) return "$n";
  return "0$n";
}

String formatTimestamp(int? timestamp) {
  if (timestamp != null) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String formattedTime = "${_twoDigit(dateTime.hour)}:${_twoDigit(dateTime.minute)}:${_twoDigit(dateTime.second)}";
    return formattedTime;
  } else {
    return "N/A";
  }
}

String formatEndTime(DateTime dateTime) {
  String formattedEndTime = "${_twoDigit(dateTime.hour)}:${_twoDigit(dateTime.minute)}:${_twoDigit(dateTime.second)}";
  return formattedEndTime;
}

String _twoDigit(int n) {
  if (n >= 10) return "$n";
  return "0$n";
}