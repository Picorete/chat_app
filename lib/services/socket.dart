import 'package:chat_app/global/enviroments.dart';
import 'package:chat_app/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;

  IO.Socket _socket;
  ServerStatus get serverStatus => this._serverStatus;
  IO.Socket get socket => this._socket;

  Function get emit => this._socket.emit;

  void connect() async {
    final token = await AuthService.getToken();

    // Dart client
    this._socket = IO.io(
        Enviroment.socketUrl,
        IO.OptionBuilder()
            .setExtraHeaders({'x-token': token})
            .enableForceNew()
            .enableAutoConnect()
            .setTransports(['websocket'])
            .build());

    this._socket.onConnect((_) {
      this._serverStatus = ServerStatus.Online;
      notifyListeners();
    });

    this._socket.onDisconnect((_) {
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

    this._socket.on('nuevo-mensaje', (payload) {
      print('nuevo-mensaje: $payload');
    });
  }

  void disconnect() {
    this._socket.disconnect();
  }
}
