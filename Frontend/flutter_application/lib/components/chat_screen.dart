import 'dart:math';

import "package:flutter/material.dart";
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

class ChatScreen extends StatefulWidget{
  const ChatScreen({super.key});
  
  @override
  State<ChatScreen> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen>{
  final _chatController = InMemoryChatController();

  @override
  void dispose(){
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return(
      Center(
        child: Chat(
          backgroundColor: Color.fromARGB(0, 0, 0, 0),
          currentUserId: "user1", 
          resolveUser: (UserID id) async {
            return User(id: id, name: 'John Doe');
          }, 
          chatController: _chatController,
          onMessageSend: (text){
            _chatController.insertMessage(
              TextMessage(
                id: "${Random().nextInt(1000) + 1}", 
                authorId: "user1", 
                createdAt: DateTime.now().toUtc(),
                text: text)
            );
          },
          ),
        )
    );
  }
}