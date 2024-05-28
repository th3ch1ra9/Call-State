import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  await Permission.microphone.request();
  await Permission.storage.request();
}

Future<bool> checkPermissions() async {
  var phone = await Permission.phone.request();
  var contact = await Permission.contacts.request();
  var microphone = await Permission.microphone.request();
    var storage = await Permission.storage.request();

  if (phone.isGranted && contact.isGranted && microphone.isGranted && storage.isGranted) {
    return true;
  } else {
    return false;
  }
}
