// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:path_provider/path_provider.dart';
// import 'permissions_service.dart';

// FlutterSoundRecorder? _audioRecorder;

// Future<void> initializeRecorder() async {
//   _audioRecorder = FlutterSoundRecorder();
//   await _audioRecorder!.openRecorder();
//   await _audioRecorder!.setSubscriptionDuration(const Duration(milliseconds: 10));
// }

// Future<void> startRecording() async {
//   await requestPermissions();
  
//   if (_audioRecorder!.isRecording) {
//     print('Already recording');
//     return;
//   }
  
//   final directory = await getExternalStorageDirectory();
//   final path = '${directory?.path}/call_recording.aac';

//   await _audioRecorder!.startRecorder(
//     toFile: path,
//     codec: Codec.aacADTS,
//   );
//   print('Recording started: $path');
// }

// Future<void> stopRecording() async {
//   if (!_audioRecorder!.isRecording) {
//     print('Not recording');
//     return;
//   }
  
//   final path = await _audioRecorder!.stopRecorder();
//   print('Recording stopped: $path');
// }
