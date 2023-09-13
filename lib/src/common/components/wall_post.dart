import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_fire/src/common/components/comment.dart';
import 'package:crud_fire/src/common/components/comment_button.dart';
import 'package:crud_fire/src/common/components/like_button.dart';
import 'package:crud_fire/src/helper/helper_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final String time;
  final String postId;
  final List<String> likes;
  //final String time;
  const WallPost({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
    required this.time,
  });

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  //user
  final currentUser = FirebaseAuth.instance.currentUser;
  bool isLiked = false;
  final _commentTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser?.email);
  }

  //toogle like
  void toogleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    //Access the document is Firebase
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);
    if (isLiked) {
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser?.email])
      });
    } else {
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser?.email])
      });
    }
  }

  //add a comment
  void addComment(String commentText) {
    //write the comment to firestore under the comments collectio for this post
    FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postId)
        .collection("Comments")
        .add({
      "CommentText": commentText,
      "CommentedBy": currentUser!.email,
      "CommentTime": Timestamp.now(), // remember to format this when displaying
    });
  }

  // show a dialog box for adding comment
  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Comentar"),
        content: TextField(
          controller: _commentTextController,
          decoration: const InputDecoration(hintText: "Ecreve um comentário.."),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _commentTextController.clear();
            },
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              addComment(_commentTextController.text);
              Navigator.pop(context);
              _commentTextController.clear();
            },
            child: const Text("Comentar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Wallpost
          const SizedBox(width: 15),
          //message and user email
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Message
              Text(widget.message),

              const SizedBox(
                height: 10,
              ),

              //User
              Row(
                children: [
                  Text(
                    widget.user,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  Text('  . ', style: TextStyle(color: Colors.grey[500])),
                  Text(widget.time, style: TextStyle(color: Colors.grey[500])),
                ],
              )
            ],
          ),
          const SizedBox(height: 10),

          //Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Like
              Column(
                children: [
                  //Like Button
                  LikeButton(
                    isLiked: isLiked,
                    onTap: toogleLike,
                  ),
                  const SizedBox(height: 5),
                  //Like count
                  Text(
                    widget.likes.length.toString(),
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 10),

              //Comment
              Column(
                children: [
                  //comment Button
                  CommentButton(
                    onTap: showCommentDialog,
                  ),

                  const SizedBox(height: 5),
                  //Coment count
                  const Text(
                    "0",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // comments under the post
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("User Posts")
                .doc(widget.postId)
                .collection("Comments")
                .orderBy('CommentTime', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              //show loading circle if no data yet
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: snapshot.data!.docs.map((doc) {
                  //get the comment
                  final commetData = doc.data() as Map<String, dynamic>;

                  //return the comment
                  return Comment(
                    text: commetData['CommentText'],
                    user: commetData["CommentedBy"],
                    time: formatDate(commetData["CommentTime"]),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
