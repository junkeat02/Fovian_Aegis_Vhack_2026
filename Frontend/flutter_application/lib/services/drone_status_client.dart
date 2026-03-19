import 'dart:async'; // Add this for Timer
import 'dart:convert';

import "package:web_socket_channel/web_socket_channel.dart";
import "package:flutter/material.dart";
import "package:flutter_application/components/container.dart";
import 'package:flutter_application/services/drones_status_tracker.dart';

class DroneStatusClient extends StatefulWidget {
  final String host;
  final int port;

  const DroneStatusClient({
    super.key,
    this.host = "localhost",
    this.port = 8001,
  });

  @override
  State<DroneStatusClient> createState() => DroneStatusClientState();
}

class DroneStatusClientState extends State<DroneStatusClient> {
  WebSocketChannel? _channel;
  final StreamController<String> _statusStreamController =
      StreamController<String>.broadcast();
  bool _isConnected = false;
  Timer? _reconnectTimer;

  @override
  void initState() {
    super.initState();
    connectServer();
  }

  @override
  void dispose() {
    // Always close your streams when the widget is destroyed
    _channel?.sink.close();
    _reconnectTimer?.cancel();
    _statusStreamController.close();
    super.dispose();
  }

  void retryConnection() {
    _isConnected = false;
    _channel?.sink.close();
    for (var id in connectionTracker.droneIds) {
      connectionTracker.updateDroneStatus(id, false);
    }
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 2), connectServer);
  }

  void connectServer() {
    if (_isConnected) return;
    _isConnected = true;
    final String uri = "ws://${widget.host}:${widget.port}";
    debugPrint("Connecting to $uri");

    try {
      _channel = WebSocketChannel.connect(Uri.parse(uri));
      _channel!.sink.add("REGISTER CONSUMER");

      _channel!.stream.listen(
        (data) {
          if (data is String) {
            _statusStreamController.add(data);
          }
          _isConnected = false;
        },
        onError: (error) {
          debugPrint("Websocket error: $error");
          retryConnection();
        },
        onDone: () {
          debugPrint("Websocket closed.");
          retryConnection();
        },
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint("Error: $e");
      retryConnection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildDronePanel();
  }

  Widget _buildDronePanel() {
    return StreamBuilder(
      stream: _statusStreamController.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text("${snapshot.error}", style: TextStyle(color: Colors.white)),
            ],
          );
        }
        if (snapshot.hasData) {
          try {
            Map<String, dynamic> drones = jsonDecode(snapshot.data.toString());
            // debugPrint(drones.toString());
            WidgetsBinding.instance.addPostFrameCallback((_) {
              for (var key in drones.keys) {
                connectionTracker.updateDroneStatus(key, true);
              }
            });
            return Row(
              children: [
                for (var entry in drones.entries)
                  Expanded(
                    flex: 1,
                    child: _buildDroneStatus(
                      entry.value["id"] ?? 0,
                      entry.value["battery"] ?? 0,
                      entry.value["survivors"] ?? 0,
                      droneKey: entry.key,
                    ),
                  ),
              ],
            );
          } catch (e) {
            debugPrint(e.toString());
          }
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text(
              "Waiting for the status...",
              style: TextStyle(color: Colors.white),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDroneStatus(
    int id,
    int battery,
    int survivors, {
    required String droneKey,
  }) {
    return DataContainer(
      // if (connectionTracker.isDroneOnline("drone$id"))
      opacity_: connectionTracker.isDroneOnline("drone$id") ? 1 : 0.5,
      borRadius: 6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFont("DRONE $id", 14, fontWeight_: FontWeight.bold),
              Icon(Icons.wifi, color: Colors.greenAccent, size: 16),
            ],
          ),
          SizedBox(height: 8),
          // Battery Bar
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: battery / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: battery > 20 ? Colors.greenAccent : Colors.redAccent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          _buildFont("Battery: $battery%", 14),
          _buildFont("Survivors: $survivors", 14),
        ],
      ),
    );
  }

  Widget _buildFont(
    String content,
    double fontSize_, {
    FontWeight fontWeight_ = FontWeight.normal,
    String fontFam = "Roboto",
    Color fontColor_ = const Color.fromARGB(255, 252, 252, 252),
  }) {
    return Text(
      content,
      style: TextStyle(
        fontSize: fontSize_,
        fontFamily: fontFam,
        fontWeight: fontWeight_,
        color: fontColor_,
      ),
    );
  }
}
