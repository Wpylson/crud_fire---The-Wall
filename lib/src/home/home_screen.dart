import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_fire/src/common/components/drawer.dart';
import 'package:crud_fire/src/common/components/text_field.dart';
import 'package:crud_fire/src/common/components/wall_post.dart';
import 'package:crud_fire/src/helper/helper_methods.dart';
import 'package:crud_fire/src/profile/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;
  final textController = TextEditingController();

  //final Stream<QuerySnapshot> _postsStream = FirebaseFirestore.instance.collection('User Posts').orderBy('Timestamp',descending: false).snapshots();
  //sing user out
  void singOut() async {
    FirebaseAuth.instance.signOut();
  }

  //make post
  void postMessage() {
    if (textController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('User Posts').add({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'Timestamp': Timestamp.now(),
        'Likes': [],
      });
    }

    setState(() {
      textController.clear();
    });
  }

  //go to profile screen
  void goToProfilePage() {
    //pop menu drawer
    Navigator.pop(context);
    //got to profile screen
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('The Wall'),
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onSingOut: singOut,
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("User Posts")
                    .orderBy(
                      'Timestamp',
                      descending: true,
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        //get posts
                        final post = snapshot.data!.docs[index];
                        return WallPost(
                          message: post['Message'],
                          user: post['UserEmail'],
                          postId: post.id,
                          likes: List<String>.from(post['Likes'] ?? []),
                          time: formatDate(post['Timestamp']),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Erro:${snapshot.error}',
                      ),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            //Post Message
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                children: [
                  Expanded(
                    child: MyTextfield(
                      controller: textController,
                      hintText: 'O que estás a pensar?',
                      obscureText: false,
                    ),
                  ),

                  //Post button
                  IconButton(
                    onPressed: postMessage,
                    icon: const Icon(
                      Icons.arrow_circle_up,
                      color: Colors.grey,
                    ),
                    iconSize: 40,
                  )
                ],
              ),
            ),
            //Currents user
            Text(
              'Logado como: ${currentUser.email!}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}
