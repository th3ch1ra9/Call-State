// FeedbackForm is a data class which stores data fields of Feedback.
class FeedbackForm {
  String name;
  String number;
  String call_type;
  String duration;
  String timestamp;
  String call_start;
  String call_end;


  FeedbackForm(
      this.name,
      this.number,
      this.call_type,
      this.duration,
      this.timestamp,
      this.call_start,
      this.call_end,);

  factory FeedbackForm.fromJson(dynamic json) {
    return FeedbackForm(
      "${json['name'] ?? 'Unknown'}",
      "${json['number']}",
      "${json['call_type']}",
      "${json['duration']}",
      "${json['timestamp']}",
      "${json['call_start']}",
      "${json['call_end']}",
    );
  }

  // Method to convert FeedbackForm to JSON format.
  Map toJson() => {
        'name': name,
        'number': number,
        'call_type': call_type,
        'duration': duration,
        'timestamp': timestamp,
        'call_start': call_start,
        'call_end': call_end,
      };
}