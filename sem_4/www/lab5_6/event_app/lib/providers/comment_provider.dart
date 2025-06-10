import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:event_app/api/api_service.dart';
import 'package:event_app/models/comment.dart';

class CommentProvider with ChangeNotifier {
  List<Comment> _comments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCommentsForEvent(String eventId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await ApiService.get('/comments/event/$eventId');

      final List<dynamic> commentList = json.decode(response.body);
      _comments = commentList.map((json) => Comment.fromJson(json)).toList();
    } catch (e) {
      _errorMessage = e.toString();
      _comments = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createComment(String content, String eventId, String authorId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await ApiService.post('/comments', {
        'content': content,
        'event': eventId,
        'author': authorId,
      }, requireAuth: true);
      final newComment = Comment.fromJson(json.decode(response.body));
      _comments.add(newComment);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteComment(String commentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await ApiService.delete('/comments/$commentId', requireAuth: true);
      _comments.removeWhere((comment) => comment.id == commentId);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}