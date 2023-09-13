import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_fire/src/common/components/text_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //user
  final currentUser = FirebaseAuth.instance.currentUser;
  //Users collections
  final usersCollections = FirebaseFirestore.instance.collection('Users');

  //Edit field
  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Editar $field',
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Digite novo(a) $field",
            hintStyle: const TextStyle(color: Colors.white),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          //cancel button
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar',
                  style: TextStyle(
                    color: Colors.white,
                  ))),

          //true button
          TextButton(
              onPressed: () => Navigator.of(context).pop(newValue),
              child: const Text('Editar',
                  style: TextStyle(
                    color: Colors.white,
                  ))),
        ],
      ),
    );
    //Update to Firestore
    if (newValue.trim().isNotEmpty) {
      await usersCollections.doc(currentUser?.email).update({field: newValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: usersCollections.doc(currentUser!.email).snapshots(),
        builder: (context, snapshot) {
          //get user data
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;

            return ListView(
              children: [
                const SizedBox(
                  height: 50,
                ),
                //Profile pic
                const Icon(
                  Icons.person,
                  size: 72,
                ),

                const SizedBox(
                  height: 10,
                ),

                //user email
                Text(
                  currentUser!.email!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),

                const SizedBox(
                  height: 50,
                ),

                //user details
                Padding(
                  padding: const EdgeInsets.only(left: 25.00),
                  child: Text(
                    'Sobre',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                //username
                MyTextBox(
                  text: '${userData["username"]}',
                  sectionName: 'Nome',
                  onPressed: () => editField('username'),
                ),

                //bio
                MyTextBox(
                  text: userData['bio'],
                  sectionName: 'Bio',
                  onPressed: () => editField('bio'),
                ),

                const SizedBox(
                  height: 50,
                ),

                //user posts
                Padding(
                  padding: const EdgeInsets.only(left: 25.00),
                  child: Text(
                    'Publicações',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            Center(
              child: Text('Erro ${snapshot.error}'),
            );
          }
          return Center(
            child: CircularProgressIndicator(
              color: Colors.grey[900],
            ),
          );
        },
      ),
    );
  }
}
