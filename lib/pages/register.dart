import 'package:chat_app/helpers/show_alert.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/socket.dart';
import 'package:chat_app/widgets/btn_blue.dart';
import 'package:chat_app/widgets/custom_input.dart';
import 'package:chat_app/widgets/labels.dart';
import 'package:chat_app/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatelessWidget {
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
                    title: 'Registro',
                  ),
                  _Form(),
                  Labels(
                    title: '¿Ya tienes una cuenta?',
                    subtitle: 'Ingresa ahora',
                    route: 'login',
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
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

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
            icon: Icons.perm_identity,
            placeholder: 'Nombre',
            keyboardType: TextInputType.text,
            textController: nameCtrl,
          ),
          CustomInput(
            icon: Icons.mail_outline,
            placeholder: 'Correo',
            keyboardType: TextInputType.emailAddress,
            textController: emailCtrl,
          ),
          CustomInput(
            icon: Icons.lock_outline,
            placeholder: 'Contraseña',
            textController: passCtrl,
            isPassword: true,
          ),
          BlueBtn(
            text: 'Crear cuenta',
            onPressed: () async {
              final registroOk = await authService.register(
                  nameCtrl.text.trim(),
                  emailCtrl.text.trim(),
                  passCtrl.text.trim());

              if (registroOk == true) {
                socketService.connect();
                Navigator.pushReplacementNamed(context, 'users');
              } else {
                showAlert(context, 'Registro invalido', registroOk);
              }
            },
          )
        ],
      ),
    );
  }
}
