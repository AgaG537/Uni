import 'package:event_app/models/user.dart';
import 'package:event_app/models/event.dart';

class Comment {
  final String id;
  final String content;
  final String authorId;
  final User? author;
  final String eventId;
  final Event? event;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.content,
    required this.authorId,
    this.author,
    required this.eventId,
    this.event,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'],
      content: json['content'],
      authorId: json['author'] is Map ? json['author']['_id'] : json['author'],
      author: json['author'] is Map ? User.fromJson(json['author']) : null,
      eventId: json['event'] is Map ? json['event']['_id'] : json['event'],
      event: json['event'] is Map ? Event.fromJson(json['event']) : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'author': authorId,
      'event': eventId,
    };
  }
}