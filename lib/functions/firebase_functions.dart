import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
//import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class FirebaseFunctions {
  // Function to save image locally
  static Future<String> saveImageLocally(File imageFile) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      String fileName = path.basename(imageFile.path);
      final File savedFile = File('${appDir.path}/$fileName');
      await imageFile.copy(savedFile.path);
      return savedFile.path;
    } catch (e) {
      print("Error saving image locally: $e");
      return '';
    }
  }

  // for only updating to Firestore
  static Future<void> updatePost(BuildContext context, String title,
      String subtitle, String imagePath, bool isEditing, String postID) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("User is not signed in");
        return;
      }

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      Timestamp timestamp = Timestamp.fromDate(DateTime.now());

      //for editing or adding
      if (isEditing) {
        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('posts')
            .doc(postID)
            .update({
          'title': title,
          'subtitle': subtitle,
          'imagePath':
              //(imagePath == null || imagePath.isEmpty) ? "" : imagePath,
              imagePath,
          'timestamp': timestamp,
          'done': false,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Data changed successfully!")),
        );

        print("Post changed successfully!");
      }
    } catch (e) {
      print("Error saving post: $e");
    }
  }

//for only adding
  static Future<void> savePost(BuildContext context, String title,
      String subtitle, String imagePath, DateTime timeOfTask) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("User is not signed in");
        return;
      }

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      Timestamp timestamp = Timestamp.fromDate(DateTime.now());

      //for adding
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('posts')
          .add({
        'title': title,
        'subtitle': subtitle,
        'imagePath': //(imagePath == null || imagePath.isEmpty) ? "" : imagePath,
            imagePath,
        'timestamp': timestamp,
        'done': false,
        'taskDate': timeOfTask,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data posted successfully!")),
      );

      print("Post saved successfully!");
    } catch (e) {
      print("Error saving post: $e");
    }
  }

  static Future<void> deletePost(BuildContext context, String postID) async {
    User? user = FirebaseAuth.instance.currentUser;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('posts')
          .doc(postID)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data deleted successfully!")),
      );
    } catch (e) {
      print("Error occurred during deletion: $e");
    }
  }

  //for updating done field
  static Future<void> updatePostDone(
      BuildContext context, String docID, bool newStatus) async {
    User? user = FirebaseAuth.instance.currentUser;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('posts')
          .doc(docID)
          .update({'done': newStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data updated successfully!")),
      );
    } catch (e) {
      print("Error occurred during updating: $e");
    }
  }
}

/// add also the time(with time selector) and date(with calendar)
