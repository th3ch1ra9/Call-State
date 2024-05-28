import 'package:http/http.dart' as http;
import 'package:callstate/forny.dart';

class FormController {
  // Google App Script Web URL.
  static const String URL ="https://script.google.com/macros/s/AKfycbz2jJK94OSf5WyV9MehApz_PcWOrqn3SyR1ImmsXF0JMmVNYFRvKC0lLodLMbNDDrDi6g/exec";  // Success Status Message
  static const STATUS_SUCCESS = "SUCCESS";

  /// Async function which saves feedback by sending HTTP POST request to the specified URL.
  Future<void> submitForm(
      FeedbackForm feedbackForm, void Function(String) callback) async {
    try {
      final response =
          await http.post(Uri.parse(URL), body: feedbackForm.toJson());
      print(response.body);
      if (response.statusCode == 200) {
        callback(response.body);
      } else if (response.statusCode == 302) {
        // Follow redirection
        final redirectUrl = response.headers['location'];
        final redirectResponse = await http.get(Uri.parse(redirectUrl!));
        callback(redirectResponse.body);
      } else {
        callback('Error: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print(e);
      callback('Error: $e');
    }
  }
}