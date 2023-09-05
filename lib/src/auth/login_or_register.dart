import 'package:crud_fire/src/login/login_scrren.dart';
import 'package:crud_fire/src/register/register_screen.dart';
import 'package:flutter/material.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  //Inicializar, show the login screen
  bool showloginPage = true;

  //toogle between login and register screen
  void tooglePages() {
    setState(() {
      showloginPage = !showloginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showloginPage) {
      return LoginScreen(onTap: tooglePages);
    } else {
      return RegisterScreen(onTap: tooglePages);
    }
  }
}
