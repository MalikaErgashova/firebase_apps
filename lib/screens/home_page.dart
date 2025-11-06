import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:to_do_notes_app/functions/firebase_functions.dart';
import 'package:to_do_notes_app/screens/enter_edit_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: StreamBuilder<QuerySnapshot>(
          stream: firestore
              .collection('users')
              .doc(auth.currentUser
                  ?.uid) // Get the user document based on the current user
              .collection('posts')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text("No tasks found"));
            }

            var posts = snapshot.data!.docs;

            return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  var post = posts[index];

                  String docID = post.id;
                  String title = post['title'];
                  String subtitle = post['subtitle'];
                  String imagePath = post['imagePath'] ?? '';
                  Timestamp timestamp = post['timestamp'];
                  Timestamp taskDate = post['taskDate'];

                  bool done = post['done'];

                  DateTime dateTime =
                      timestamp.toDate(); 

                  //formatted time
                  String formattedTime = DateFormat('HH:mm').format(dateTime);

                  //formatted date
                  String formattedDate =
                      DateFormat('dd/MM/yy').format(dateTime);
                  ///for the taskDate
                  DateTime taskTime =
                      taskDate.toDate(); // Convert timestamp to DateTime

                  //formatted date
                  String formattedTaskDate =
                      DateFormat('dd/MM/yy').format(taskTime);

                  //for image
                  File imageFile = File(imagePath);

                  return Dismissible(
                    key: Key(docID),
                    background: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.red,
                      ), // Set background color when swiping
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(Icons.delete,
                          color: Colors.white), // Icon that shows when swiped
                    ),
                    onDismissed: (direction) {
                      FirebaseFunctions.deletePost(context, docID);
                    },
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 11.0, right: 11, top: 16),
                      child: Column(
                        children: [
                          Container(
                            height: height / 7,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                        0.2), // shadow color with opacity
                                    offset: Offset(
                                        2, 2), // x and y offset of the shadow
                                    blurRadius: 10, // how blurry the shadow is
                                    spreadRadius: 2,
                                  )
                                ]),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0, right: 15, bottom: 5, top: 5),
                              child: Row(
                                children: [
                                  (imagePath == null || imagePath.isEmpty)
                                      ? Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Image.network(
                                            "https://th.bing.com/th/id/OIP.sLISvnG1Z7yYZrmeAAzC5gHaHa?rs=1&pid=ImgDetMain",
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Image.file(
                                              //width: double.infinity,
                                              imageFile),
                                        ),
                                  SizedBox(
                                    width: width / 40,
                                  ),
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: width / 3,
                                            child: Text(
                                              title.length > 15
                                                  ? '${title.substring(0, 12)}...' 
                                                  : title,
                                              style: TextStyle(
                                                fontSize:
                                                    17, // Adjust font size based on text length
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow
                                                  .ellipsis,
                                            ),
                                          ),
                                          SizedBox(
                                            width: width / 6,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                done = !done;
                                                FirebaseFunctions
                                                    .updatePostDone(
                                                        context, docID, done);
                                              });
                                            },
                                            child: done == false
                                                ? Icon(Icons
                                                    .check_box_outline_blank_rounded)
                                                : Icon(
                                                    Icons.check_box_outlined),
                                          )
                                        ],
                                      ),
                                      Text(
                                        subtitle.length > 40
                                            ? '${subtitle.substring(0, 40)}...'
                                            : subtitle,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          EnterEditPage(
                                                            postId: post.id,
                                                          )));
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: Colors.green[100],
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 9.0,
                                                        vertical: 5),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.edit,
                                                      color: Colors.green,
                                                      size: 18,
                                                    ),
                                                    Text(
                                                      "Edit",
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: Colors.green,
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 9.0,
                                                      vertical: 5),
                                                  child: Row(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            //'${formattedTime}',
                                                            '${formattedDate}',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            //'${formattedTime}',
                                                            '${formattedTime}',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Icon(
                                                Icons.arrow_forward_rounded,
                                                size: 19,
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: Colors.green,
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 9.0,
                                                      vertical: 5),
                                                  child: Text(
                                                    //'${formattedTime}',
                                                    '${formattedTaskDate}',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
          }),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => EnterEditPage()));
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 27,
        ),
      ),
    );
  }
}


