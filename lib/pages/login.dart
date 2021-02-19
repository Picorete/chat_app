import 'package:chat_app/helpers/show_alert.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/socket.dart';
import 'package:chat_app/widgets/btn_blue.dart';
import 'package:chat_app/widgets/custom_input.dart';
import 'package:chat_app/widgets/labels.dart';
import 'package:chat_app/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffF2F2F2),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.9,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Logo(
                    title: 'Messenger',
                  ),
                  _Form(),
                  Labels(
                    title: '¿No tienes cuenta?',
                    subtitle: 'Crea una ahora!',
                    route: 'register',
                  ),
                  Text(
                    'Terminos y condiciones de uso',
                    style: TextStyle(
                      fontWeight: FontWeight.w200,
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}

class _Form extends StatefulWidget {
  @override
  __FormState createState() => __FormState();
}

class __FormState extends State<_Form> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  final FocusNode passNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final socketService = Provider.of<SocketService>(context);

    return Container(
      margin: EdgeInsets.only(top: 40),
      padding: EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
          CustomInput(
            icon: Icons.mail_outline,
            placeholder: 'Correo',
            keyboardType: TextInputType.emailAddress,
            textController: emailCtrl,
            onSubmitted: (_) => {passNode.requestFocus()},
          ),
          CustomInput(
            icon: Icons.lock_outline,
            placeholder: 'Contraseña',
            textController: passCtrl,
            isPassword: true,
            focusNode: passNode,
          ),

          // TODO: Crear boton
          BlueBtn(
            text: 'Ingrese',
            onPressed: authService.busy
                ? null
                : () async {
                    FocusScope.of(context).unfocus();
                    final loginOk = await authService.login(
                        emailCtrl.text.trim(), passCtrl.text.trim());
                    if (loginOk) {
                      socketService.connect();
                      Navigator.pushReplacementNamed(context, 'users');
                    } else {
                      showAlert(context, 'Login incorrecto',
                          'Credenciales invalidas');
                    }
                  },
          )
        ],
      ),
    );
  }
}
