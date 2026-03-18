import 'dart:async'; // Add this for Timer
import 'dart:convert';

import "package:web_socket_channel/web_socket_channel.dart";
import "package:flutter/material.dart";
import "package:flutter_application/components/container.dart";

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
            dynamic drone1 = drones["drone0"];
            dynamic drone2 = drones["drone1"];
            return Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _buildDroneStatus(
                    drone1["id"] ?? 0,
                    drone1["battery"] ?? 0,
                    drone1["survivors"] ?? 0,
                  ),
                ),

                Expanded(
                  flex: 1,
                  child: _buildDroneStatus(
                    drone2["id"] ?? 0,
                    drone2["battery"] ?? 0,
                    drone2["survivors"] ?? 0,
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

  Widget _buildDroneStatus(int id, int battery, int survivors) {
    return DataContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildFont("Drone: $id", 20),
          _buildFont("Battery: $battery%", 20),
          _buildFont("Survivors: $survivors", 20),
        ],
      ),
    );
  }

  Widget _buildFont(
    String content,
    double fontSize_, {
    String fontFam = "Roboto",
    Color fontColor_ = const Color.fromARGB(255, 252, 252, 252),
  }) {
    return Text(
      content,
      style: TextStyle(
        fontSize: fontSize_,
        fontFamily: fontFam,
        color: fontColor_,
      ),
    );
  }
}
