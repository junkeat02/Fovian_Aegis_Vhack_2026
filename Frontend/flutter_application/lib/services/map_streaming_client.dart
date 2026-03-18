import 'dart:async'; // Add this for Timer
import 'dart:typed_data';
import 'package:flutter/material.dart';
import "package:web_socket_channel/web_socket_channel.dart";

class MapServer extends StatefulWidget{
  final String host;
  final int port;

  const MapServer({
    super.key,
    this.host = "localhost",
    this.port = 8001,
    });

  @override
  State<MapServer> createState() => MapServerState();
}

class MapServerState extends State<MapServer>{
  WebSocketChannel? _channel;
  final StreamController<Uint8List> _imageStreamController = StreamController<Uint8List>.broadcast();
  bool _isConnected = false;
  Timer? _reconnectTimer;

  void connectServer(){
    if (_isConnected) return;
    _isConnected = true;
    final String uri = "ws://${widget.host}:${widget.port}";
    debugPrint("Connecting to $uri");


    try{
      _channel = WebSocketChannel.connect(Uri.parse(uri));
      _channel!.sink.add("REGISTER CONSUMER");

      _channel!.stream.listen(
        (data){
          if (data is Uint8List){
            _imageStreamController.add(data);
          }
          _isConnected = false;
        },
        onError: (error){
          debugPrint("Websocket error: $error");
          retryConnection();
        },
        onDone: () {
          debugPrint("Websocket closed.");
          retryConnection();
        },
        cancelOnError: true
      );
    }
    catch (e){
      debugPrint("Error: $e");
      retryConnection();
    }
  }

  void retryConnection(){
    _isConnected = false;
    _channel?.sink.close();

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 2), connectServer);
  }

  @override
  void initState(){
    super.initState();
    connectServer();

  }

  @override
  Widget build(BuildContext context){
    return(
      Center(child: _buildStreamMap(_channel!),)
    );
  }

  Widget _buildStreamMap(WebSocketChannel channel){
    return(
      StreamBuilder(
        stream: _imageStreamController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError){
            return Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10,),
                Text("${snapshot.error}", style: TextStyle(color: Colors.white)),
              ]
              );
          }
          
          if (snapshot.hasData){
            return Image.memory(
              snapshot.data as Uint8List,
              gaplessPlayback: true,
              fit: BoxFit.contain,
              );
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10,),
              Text("Waiting for the map...", style: TextStyle(color: Colors.white),)
            ]
            );
        },
      )
    );
  }

  @override
  void dispose() {
    // Always close your streams when the widget is destroyed
    _channel?.sink.close();
    _reconnectTimer?.cancel();
    _imageStreamController.close();
    super.dispose();
  }

}