import 'package:chat_app/global/enviroments.dart';
import 'package:chat_app/models/messages_response.dart';
import 'package:chat_app/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:chat_app/models/user.dart';

class ChatService with ChangeNotifier {
  User userTo;

  Future<List<Mensaje>> getChat(String userId) async {
    final resp = await http.get('${Enviroment.apiUrl}/messages/$userId',
        headers: {
          'Content-Type': 'application/json',
          'x-token': await AuthService.getToken()
        });

    final messagesResp = messagesResponseFromJson(resp.body);

    return messagesResp.mensajes;
  }
}
