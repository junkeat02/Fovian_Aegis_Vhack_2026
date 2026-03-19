import 'package:flutter/material.dart';

class DroneConnectionTracker extends ChangeNotifier {
  // Track server status
  bool _isServerConnected = false;
  List<String> get droneIds => _droneStatuses.keys.toList();

  
  // Track individual drone statuses: {"drone0": true, "drone1": false}
  final Map<String, bool> _droneStatuses = {};

  bool get isServerConnected => _isServerConnected;
  Map<String, bool> get droneStatuses => _droneStatuses;

  // Update the main WebSocket server status
  void setServerStatus(bool status) {
    if (_isServerConnected != status) {
      _isServerConnected = status;
      notifyListeners();
    }
  }

  // Update a specific drone's status
  void updateDroneStatus(String droneId, bool isOnline) {
    if (_droneStatuses[droneId] != isOnline) {
      _droneStatuses[droneId] = isOnline;
      notifyListeners(); // UI updates only when a drone toggles state
    }
  }
  // Helper to check a specific drone's status safely
  bool isDroneOnline(String droneId) {
    return _droneStatuses[droneId] ?? false;
  }
}

final connectionTracker = DroneConnectionTracker();