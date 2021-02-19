import 'dart:io';

import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/chat.dart';
import 'package:chat_app/services/socket.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:chat_app/models/messages_response.dart';
import 'package:chat_app/widgets/chat_message.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final _textController = new TextEditingController();
  final _focusNode = new FocusNode();

  ChatService chatService;
  SocketService socketService;
  AuthService authService;
  List<ChatMessage> _messages = [];

  bool _isWritting = false;

  @override
  void initState() {
    super.initState();
    this.chatService = Provider.of<ChatService>(context, listen: false);
    this.socketService = Provider.of<SocketService>(context, listen: false);
    this.authService = Provider.of<AuthService>(context, listen: false);

    this.socketService.socket.on('msg', _escucharMensaje);

    _cargarHistorial(this.chatService.userTo.uid);
  }

  void _cargarHistorial(String uid) async {
    List<Mensaje> chat = await this.chatService.getChat(uid);

    final history = chat.map((m) => new ChatMessage(
          text: m.msg,
          uid: m.from,
          animationController: new AnimationController(
              vsync: this, duration: Duration(milliseconds: 0))
            ..forward(),
        ));
    setState(() {
      _messages.insertAll(0, history);
    });
  }

  void _escucharMensaje(dynamic payload) {
    ChatMessage message = new ChatMessage(
      text: payload['msg'],
      uid: payload['from'],
      animationController: AnimationController(
          vsync: this, duration: Duration(milliseconds: 200)),
    );

    setState(() {
      _messages.insert(0, message);
    });

    message.animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final userTo = chatService.userTo;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        title: Column(
          children: [
            CircleAvatar(
              child: Text(userTo.nombre.substring(0, 2),
                  style: TextStyle(fontSize: 12)),
              backgroundColor: Colors.blue[100],
              maxRadius: 13,
            ),
            SizedBox(
              height: 3,
            ),
            Text(
              userTo.nombre,
              style: TextStyle(color: Colors.black87, fontSize: 12),
            )
          ],
        ),
      ),
      body: Container(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: _messages.length,
                itemBuilder: (_, i) => _messages[i],
                reverse: true,
              ),
            ),
            Divider(height: 1),
            Container(
              color: Colors.white,
              child: _inputChat(),
            )
          ],
        ),
      ),
    );
  }

  Widget _inputChat() {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmit,
                onChanged: (String text) {
                  setState(() {
                    if (text.trim().length > 0) {
                      _isWritting = true;
                    } else {
                      _isWritting = false;
                    }
                  });
                },
                decoration:
                    InputDecoration.collapsed(hintText: 'Enviar mensaje'),
                focusNode: _focusNode,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: !Platform.isIOS
                  ? CupertinoButton(
                      child: Text('Enviar'),
                      onPressed: _isWritting
                          ? () => _handleSubmit(_textController.text.trim())
                          : null,
                    )
                  : Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.0),
                      child: IconTheme(
                        data: IconThemeData(color: Colors.blue[400]),
                        child: IconButton(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          icon: Icon(Icons.send),
                          onPressed: _isWritting
                              ? () => _handleSubmit(_textController.text.trim())
                              : null,
                        ),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }

  _handleSubmit(String text) {
    if (_isWritting) {
      _textController.clear();

      final newMessage = new ChatMessage(
        uid: authService.user.uid,
        text: text,
        animationController: AnimationController(
            vsync: this, duration: Duration(milliseconds: 200)),
      );
      _messages.insert(0, newMessage);
      newMessage.animationController.forward();
      setState(() {
        _isWritting = false;
      });

      this.socketService.emit('msg', {
        'from': this.authService.user.uid,
        'to': this.chatService.userTo.uid,
        'msg': text
      });
    }
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    for (ChatMessage message in _messages) {
      message.animationController.dispose();
    }
    this.socketService.socket.off('msg');
    super.dispose();
  }
}
