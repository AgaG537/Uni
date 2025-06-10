import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:event_app/api/api_service.dart';
import 'package:event_app/models/event.dart';

class EventProvider with ChangeNotifier {
  List<Event> _events = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchEvents({String? creatorId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      String endpoint = '/events';
      if (creatorId != null) {
        endpoint += '?creator=$creatorId';
      }
      final response = await ApiService.get(endpoint);
      final List<dynamic> eventList = json.decode(response.body);
      _events = eventList.map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      _errorMessage = e.toString();
      _events = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createEvent(Event event) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await ApiService.post('/events', event.toJson(), requireAuth: true);
      final newEvent = Event.fromJson(json.decode(response.body));
      _events.add(newEvent);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteEvent(String eventId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await ApiService.delete('/events/$eventId', requireAuth: true);
      _events.removeWhere((event) => event.id == eventId);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}