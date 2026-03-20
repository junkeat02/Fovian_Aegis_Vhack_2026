import "package:flutter/material.dart";
import 'package:flutter_application/components/container.dart';
import 'package:flutter_application/services/map_streaming_client.dart';
import 'package:flutter_application/components/chat_screen.dart';
import 'package:flutter_application/services/drone_status_client.dart';
import 'package:flutter_application/services/drones_status_tracker.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<bool> dronesConnection = [true, false];
  // final connectionTracker = DroneConnectionTracker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 176, 165, 165),

      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 42, 70),
        leading: DataContainer(
          backgroundColor: Color.fromARGB(255, 189, 255, 255),
          horPadding: 0,
          vertPadding: 0,
          borRadius: 10,
          child: _buildLogo(30, 30),
        ),
        title: _buildTitle(_buildFont("Fovier Rescue Swam Center", 20)),
        actions: [
          ListenableBuilder(
            listenable: connectionTracker,
            builder: (context, child) {
              return Row(
                children: [
                  // Status for Drone 0
                  for (var entry in connectionTracker.droneIds)
                    _buildConnectStatus(connectionTracker.isDroneOnline(entry), entry),
                ],
              );
            },
          )
        ],
        elevation: 10,
      ),

      body: Row(
        children: [
          Expanded(
            // left part of dashboard
            flex: 5,
            child: Center(child: DataContainer(borRadius: 6, child: MapServer())),
          ),
          Expanded(flex: 3, child: Center(child: _buildRightPanel())),
        ],
      ),
    );
  }

  Widget _buildLogo(double logoWidth, double logoHeight) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Image.asset(
        "assets/images/fovian_logo-removebg.png",
        width: logoWidth,
        height: logoHeight,
      ),
    );
  }

  Widget _buildTitle(Widget title) {
    return Center(child: title);
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

  Widget _buildConnectStatus(bool status, String droneKey) {
    int insertPosition = droneKey.length - 1;
    String actionDroneName = "${droneKey.substring(0, insertPosition)} ${droneKey.substring(insertPosition)}";
    return DataContainer(
      backgroundColor: status
          ? Color.fromARGB(255, 5, 157, 35)
          : Color.fromARGB(255, 152, 0, 0),
      borRadius: 6,
      vertMargin: 0,
      horMargin: 6,
      child: _buildFont(
        actionDroneName.toUpperCase(),
        15,
        fontColor_: Color.fromARGB(255, 255, 255, 255),
      ),
    );
  }

// In _buildRightPanel(), add it above the chat:
Widget _buildRightPanel() {
  return Column(
    children: [
      Expanded(flex: 2, child: _buildRescueProgress()), // New Progress Section
      Expanded(flex: 2, child: Center(child: DroneStatusClient())),
      Expanded(
        flex: 4,
        child: Center(child: DataContainer(borRadius: 6, child: ChatScreen())),
      ),
    ],
  );
}

  Widget _buildRescueProgress() {
  return ListenableBuilder(
    listenable: connectionTracker, // Or your specific rescue tracker
    builder: (context, child) {
      int found = connectionTracker.totalSurvivorsFound; 
      int total = 5; // Your NO_OF_SURVIVORS variable
      
      return DataContainer(
        borRadius: 10,
        backgroundColor: Colors.black26,
        child: Column(
          children: [
            _buildFont("MISSION PROGRESS", 14, fontColor_: Colors.orangeAccent),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: found / total,
              backgroundColor: Colors.white10,
              color: Colors.greenAccent,
              minHeight: 12,
            ),
            const SizedBox(height: 4),
            _buildFont("$found / $total Survivors Located", 12),
          ],
        ),
      );
    },
  );
}
}
