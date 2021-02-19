import 'package:chat_app/pages/login.dart';
import 'package:chat_app/pages/users.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/socket.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffF2F2F2),
        body: SafeArea(
          child: Column(
            children: [_Logo()],
          ),
        ));
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkLoginState(context),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        return Center(
          child: Text('Espere...'),
        );
      },
    );
  }

  Future checkLoginState(BuildContext context) async {
    final authservice = Provider.of<AuthService>(context, listen: false);
    final socketService = Provider.of<SocketService>(context, listen: false);

    final autenticado = await authservice.isLoggedIn();

    if (autenticado) {
      socketService.connect();
      // Navigator.pushReplacementNamed(context, 'users');
      Navigator.pushReplacement(
          context, PageRouteBuilder(pageBuilder: (_, __, ___) => UsersPage()));
    } else {
      Navigator.pushReplacement(
          context, PageRouteBuilder(pageBuilder: (_, __, ___) => LoginPage()));
    }
  }
}
