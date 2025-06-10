import 'package:event_app/models/user.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String creatorId;
  final User? creator;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.creatorId,
    this.creator,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      creatorId: json['creator'] is Map ? json['creator']['_id'] : json['creator'],
      creator: json['creator'] is Map ? User.fromJson(json['creator']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'creator': creatorId,
    };
  }
}