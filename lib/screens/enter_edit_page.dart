import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:intl/intl.dart';
//import 'package:path/path.dart' as path;
//import "package:path_provider/path_provider.dart";
import 'package:to_do_notes_app/functions/firebase_functions.dart';

class EnterEditPage extends StatefulWidget {
  //id of the posts
  final String? postId;

  const EnterEditPage({super.key, this.postId});

  @override
  State<EnterEditPage> createState() => _EnterEditPageState();
}

class _EnterEditPageState extends State<EnterEditPage> {
  File? image;

  TextEditingController titleCont = TextEditingController();
  TextEditingController subTitleCont = TextEditingController();

  FocusNode fNode1 = FocusNode();
  FocusNode fNode2 = FocusNode();

  bool _isEditing = false;

  ///for alarm
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.postId != null) {
      _isEditing = true;
      loadPostData();
    }
  }

  // Show DatePicker to select a day
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    } else {
      setState(() {
        _selectedDate = DateTime.now();
      });
    }
  }

  //first load the previous data from database
  Future<void> loadPostData() async {
    try {
      DocumentSnapshot postSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth
              .instance.currentUser!.uid) // Get the current user's UID
          .collection('posts')
          .doc(widget.postId) // Get the post with the specific ID
          .get();

      if (postSnapshot.exists) {
        // Pre-fill the form with existing data
        var postData = postSnapshot.data() as Map<String, dynamic>;

        if (mounted) {
          setState(() {
            titleCont.text = postData['title'];
            subTitleCont.text = postData['subtitle'];
          });
        }
      }
    } catch (e) {
      print("Error occurred while re-loading: $e");
    }
  }

  //function to get image from gallery
  Future<void> getImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    } /*else {
      setState(() {
        image = File('');
      });
    }*/
  }

  Future<void> savePost() async {
    if (titleCont.text == null || subTitleCont.text == null) {
      print("Please fill all fields");
      return;
    }

    //save the path of the image
    String imagePath =
        //(image == null) ? await FirebaseFunctions.saveImageLocally(image!) : '';
        await FirebaseFunctions.saveImageLocally(image!);

    if (_isEditing) {
      //update to the firebase
      await FirebaseFunctions.updatePost(context, titleCont.text,
          subTitleCont.text, imagePath, _isEditing, widget.postId!);
    }
    //post everything to the firebase
    await FirebaseFunctions.savePost(
        context,
        titleCont.text,
        subTitleCont.text,
        //imagePath == null ? imagePath : '', _selectedDate!);
        imagePath,
        _selectedDate!);
  }

  //

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 90),
        child: SingleChildScrollView(
          child: Column(
            children: [
              textContainer(titleCont, fNode1, Colors.white, "Title", true,
                  () => _selectDate(context)),
              SizedBox(
                height: height / 45,
              ),
              textContainer(
                  subTitleCont, fNode2, Colors.white, "Subtitle", false, () {}),
              SizedBox(
                height: height / 100,
              ),
              GestureDetector(
                onTap: () {
                  getImage();
                },
                child: Container(
                    height: height / 5,
                    //width: width / 1.2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Image.network(
                      "https://th.bing.com/th/id/OIP.Ve9O3aNxfOTTEluNI6eiKgHaHa?rs=1&pid=ImgDetMain",
                      fit: BoxFit.contain,
                    )),
              ),
              SizedBox(
                height: height / 30,
              ),

              ///place for beautiful image picker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      ///there will be the add button function
                      savePost();
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: height / 15,
                      width: width / 2.3,
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(5)),
                      child: Center(
                        child: Text(
                          _isEditing ? " Edit task" : "Add task",
                          style: TextStyle(fontSize: 19.5, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ///there will be the cancel button function
                      setState(() {
                        titleCont.text = '';
                        subTitleCont.text = '';
                      });
                    },
                    child: Container(
                      height: height / 15,
                      width: width / 2.3,
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(5)),
                      child: Center(
                        child: Text(
                          "Cancel",
                          style: TextStyle(fontSize: 19.5, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///make them the same namely containers!!!
Widget textContainer(TextEditingController cont, FocusNode node, Color color,
    String text, bool isCalendar, Function? onTapCallBack) {
  return Container(
    decoration:
        BoxDecoration(color: color, borderRadius: BorderRadius.circular(9)),
    child: TextField(
      focusNode: node,
      style: TextStyle(fontSize: 19, color: Colors.black),
      maxLines: text == "Subtitle" ? 3 : 1,
      decoration: InputDecoration(
          hintText: text,
          suffixIcon: isCalendar
              ? GestureDetector(
                  onTap: () {
                    //there will be the function of calendar
                    if (onTapCallBack != null) {
                      onTapCallBack(); // Call the callback function here
                    }
                  },
                  child: Icon(
                    Icons.calendar_today_outlined,
                    color: node.hasFocus ? Colors.green : null,
                  ),
                )
              : null,
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: BorderSide(width: 2, color: Color(0xffc5c5c5))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: BorderSide(width: 2, color: Colors.green))),
      controller: cont,
    ),
  );
}

///in there also add the time and date for alarm, // cannot do
///work with the Gesture detector
