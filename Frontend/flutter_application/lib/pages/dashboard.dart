import "package:flutter/material.dart";
import 'package:flutter_application/components/container.dart';
import 'package:flutter_application/services/map_streaming_client.dart';
import 'package:flutter_application/components/chat_screen.dart';
import 'package:flutter_application/services/drone_status_client.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<bool> dronesConnection = [true, false];

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
          _buildConnectStatus(dronesConnection[0], 1),
          _buildConnectStatus(dronesConnection[1], 2),
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

  Widget _buildConnectStatus(bool status, int droneNum) {
    String droneName = "Drone$droneNum";
    return DataContainer(
      backgroundColor: status
          ? Color.fromARGB(255, 5, 157, 35)
          : Color.fromARGB(255, 152, 0, 0),
      borRadius: 6,
      vertMargin: 0,
      horMargin: 6,
      child: _buildFont(
        droneName,
        15,
        fontColor_: Color.fromARGB(255, 255, 255, 255),
      ),
    );
  }

  Widget _buildRightPanel() {
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: Center(
            child: DataContainer(borRadius: 6, child: ChatScreen()),
          ),
        ),

        Expanded(flex: 1, child: Center(child: DroneStatusClient())),
      ],
    );
  }
}
