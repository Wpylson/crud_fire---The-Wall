import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_fire/src/common/components/button.dart';
import 'package:crud_fire/src/common/components/text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  final Function()? onTap;
  const RegisterScreen({super.key, required this.onTap});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void singUp() async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    //make sure passowords match
    if (passwordTextController.text != confirmPasswordController.text) {
      //pop loading circle
      Navigator.pop(context);
      displayMessage(
        'As palavras-passes diferentes, por favor tente novamente',
      );
      return;
    }
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailTextController.text,
              password: passwordTextController.text);

      //after creating the user, create a new document in cloud firestore called Users
      FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
        'username': emailTextController.text.split('@')[0],
        'bio': 'Empty bio...' //Initally empty bio
        // add any additional fields as needed
      });

      //pop loading circle
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      //pop loading circle
      Navigator.pop(context);
      displayMessage(e.code);
    }
  }

  //Display a dialog message
  void displayMessage(String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Mensagem'),
              content: Text(message),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 50,
                ),
                Image.asset(
                  'assets/images/singup.jpg',
                  height: 200,
                  width: 200,
                ),
                /*const Icon(
                  Icons.lock,
                  size: 100,
                ),*/
                Text(
                  'Registar-se',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Venhar criar uma conta na maior comunidade!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                MyTextfield(
                  controller: emailTextController,
                  hintText: 'E-mail',
                  obscureText: false,
                ),
                const SizedBox(
                  height: 10,
                ),
                MyTextfield(
                  controller: passwordTextController,
                  hintText: 'Palavra-passe',
                  obscureText: true,
                ),
                const SizedBox(
                  height: 10,
                ),
                MyTextfield(
                  controller: confirmPasswordController,
                  hintText: 'Confirme Palavra-passe',
                  obscureText: true,
                ),
                const SizedBox(
                  height: 25,
                ),
                MyButton(
                  onTap: singUp,
                  text: 'Registar',
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Já tens uma conta?',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Entrar agora',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
