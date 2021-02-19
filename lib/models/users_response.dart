// To parse this JSON data, do
//
//     final userResponse = userResponseFromJson(jsonString);

import 'dart:convert';

import 'package:chat_app/models/user.dart';

UserResponse userResponseFromJson(String str) =>
    UserResponse.fromJson(json.decode(str));

String userResponseToJson(UserResponse data) => json.encode(data.toJson());

class UserResponse {
  UserResponse({
    this.ok,
    this.usuarios,
  });

  bool ok;
  List<User> usuarios;

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
        ok: json["ok"],
        usuarios:
            List<User>.from(json["usuarios"].map((x) => User.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "ok": ok,
        "usuarios": List<dynamic>.from(usuarios.map((x) => x.toJson())),
      };
}
