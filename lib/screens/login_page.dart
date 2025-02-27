import 'package:flutter/material.dart';
import 'package:to_do_notes_app/screens/sign_up_page.dart';
import '../data/auth_data.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback show;
  const LoginPage(this.show, {super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();

  //focus nodes
  FocusNode _node1 = FocusNode();
  FocusNode _node2 = FocusNode();
  bool isObscure = false;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      //backgroundColor: Colors.white,
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(11.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  // height: height / 19,
                  height: height / 200,
                ),
                Container(
                    height: height / 3,
                    child: Image.asset(
                      'assets/todo.jpeg',
                      fit: BoxFit.cover,
                    )),
                SizedBox(
                  height: height / 10,
                ),

                ///email
                textfield(emailCont, _node1, "Email", true),
                SizedBox(
                  height: height / 130,
                ),

                ///password
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9)),
                  child: TextField(
                    obscureText: isObscure,
                    focusNode: _node2,
                    style: TextStyle(fontSize: 19, color: Colors.black),
                    decoration: InputDecoration(
                        hintText: "Password",
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                        prefixIcon: Icon(
                          Icons.lock,
                          color: _node2.hasFocus ? Colors.green : null,
                          //Color(0xff18DAA3)
                        ),
                        suffixIcon: GestureDetector(
                          child: Icon(isObscure
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onTap: () {
                            setState(() {
                              isObscure = !isObscure;
                            });
                          },
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide:
                                BorderSide(width: 2, color: Color(0xffc5c5c5))),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide:
                                BorderSide(width: 2, color: Colors.green))),
                    controller: passwordCont,
                  ),
                ),
                //textfield(passwordCont, _node2, "Password", false),
                SizedBox(
                  height: height / 200,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Don't have an account?  "),
                    GestureDetector(
                      onTap: widget.show,
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: height / 60,
                ),
                GestureDetector(
                  onTap: () {
                    AuthDataReal().login(emailCont.text, passwordCont.text);
                  },
                  child: Container(
                    height: height / 16,
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(9)),
                    child: Center(
                        child: Text(
                      "Login",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget textfield(TextEditingController controller, FocusNode focusNode,
    String title, bool isEmail) {
  return Container(
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(9)),
    child: TextField(
      focusNode: focusNode,
      style: TextStyle(fontSize: 19, color: Colors.black),
      decoration: InputDecoration(
          hintText: title,
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          prefixIcon: Icon(isEmail == true ? Icons.email : Icons.lock,
              color: focusNode.hasFocus ? Colors.green : null),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: BorderSide(width: 2, color: Color(0xffc5c5c5))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: BorderSide(width: 2, color: Colors.green))),
      controller: controller,
    ),
  );
}

///2 ta text fieldni bitta widget qil!!!
