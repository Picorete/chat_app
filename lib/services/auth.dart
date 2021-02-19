import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:chat_app/global/enviroments.dart';
import 'package:chat_app/models/login_response.dart';
import 'package:chat_app/models/user.dart';

class AuthService with ChangeNotifier {
  User user;
  bool _busy = false;
  final _storage = new FlutterSecureStorage();

  bool get busy => this._busy;
  set busy(bool val) {
    this._busy = val;
    notifyListeners();
  }

  // Getters del token de forma estatica
  static Future<String> getToken() async {
    final _storage = new FlutterSecureStorage();
    final token = await _storage.read(key: 'token');
    return token;
  }

  static Future<void> deleteToken() async {
    final _storage = new FlutterSecureStorage();
    await _storage.delete(key: 'token');
  }

  Future<bool> login(String email, String password) async {
    this.busy = true;

    final data = {'email': email, 'password': password};

    final resp = await http.post('${Enviroment.apiUrl}/login',
        body: jsonEncode(data), headers: {'Content-Type': 'application/json'});

    this.busy = false;

    if (resp.statusCode == 200) {
      final loginResponse = loginResponseFromJson(resp.body);
      this.user = loginResponse.usuario;

      await this._guardarToken(loginResponse.token);

      return true;
    } else {
      return false;
    }
  }

  Future register(String nombre, String email, String password) async {
    this.busy = true;

    final data = {
      'nombre': nombre,
      'email': email,
      'password': password,
    };

    final resp = await http.post('${Enviroment.apiUrl}/login/new',
        body: jsonEncode(data), headers: {'Content-Type': 'application/json'});
    this.busy = false;

    if (resp.statusCode == 200) {
      await this.login(email, password);
      return true;
    } else {
      final respBody = jsonDecode(resp.body);
      return respBody['msg'];
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await this._storage.read(key: 'token');

    final resp = await http.get('${Enviroment.apiUrl}/login/renew', headers: {
      'Content-Type': 'application/json',
      'x-token': token,
    });

    if (resp.statusCode == 200) {
      final loginResponse = loginResponseFromJson(resp.body);
      this.user = loginResponse.usuario;
      await this._guardarToken(loginResponse.token);

      return true;
    } else {
      this.logout();
      return false;
    }
  }

  Future _guardarToken(String token) async {
    return await _storage.write(key: 'token', value: token);
  }

  Future logout() async {
    await _storage.delete(key: 'token');
  }
}
