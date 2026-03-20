import 'package:flutter/material.dart';

class DroneConnectionTracker extends ChangeNotifier {
  // --- Status Variables ---
  bool _isServerConnected = false;
  int _totalSurvivorsFound = 0;
  String _missionStatus = "Awaiting Mission Start...";

  // Track individual drone statuses: {"drone0": true, "drone1": false}
  // Initializing with default keys ensures UI doesn't break on first load
  final Map<String, bool> _droneStatuses = {"drone0": false, "drone1": false};

  // --- Getters ---
  bool get isServerConnected => _isServerConnected;
  int get totalSurvivorsFound => _totalSurvivorsFound;
  String get missionStatus => _missionStatus;
  Map<String, bool> get droneStatuses => _droneStatuses;
  List<String> get droneIds => _droneStatuses.keys.toList();

  // --- Update Methods ---

  /// Updates the main WebSocket server status (Port 8000 connection)
  void setServerStatus(bool status) {
    if (_isServerConnected != status) {
      _isServerConnected = status;
      _missionStatus = status ? "System Online" : "System Offline";
      notifyListeners();
    }
  }

  /// Explicitly update a specific drone's connectivity status
  void updateDroneStatus(String droneId, bool isOnline) {
    if (_droneStatuses[droneId] != isOnline) {
      _droneStatuses[droneId] = isOnline;
      notifyListeners();
    }
  }

void updateStatus(Map<String, dynamic> data) {
    bool shifted = false;

    // 1. Update Aggregate Survivor Count (for the Progress Bar)
    if (data.containsKey('survivors_found')) {
      int newTotal = data['survivors_found'];
      if (_totalSurvivorsFound != newTotal) {
        _totalSurvivorsFound = newTotal;
        shifted = true;
      }
    }

    // 2. Handle individual drone data from the 'drones' Map
    if (data.containsKey('drones')) {
      // Changed from List to Map to match your Python payload
      Map<String, dynamic> dronesMap = data['drones'];
      
      dronesMap.forEach((droneKey, droneData) {
        // Update connection status (the red/green indicators in AppBar)
        bool isOnline = droneData['online'] ?? false;
        if (_droneStatuses[droneKey] != isOnline) {
          _droneStatuses[droneKey] = isOnline;
          shifted = true;
        }
      });
    }

    if (data.containsKey('message')) {
      _missionStatus = data['message'];
      shifted = true;
    }

    if (shifted) {
      notifyListeners();
    }
  }

  /// Helper to check a specific drone's status safely
  bool isDroneOnline(String droneId) {
    return _droneStatuses[droneId] ?? false;
  }
}

// Global instance for the app to listen to
final connectionTracker = DroneConnectionTracker();
