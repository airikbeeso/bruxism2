import 'package:bruxism2/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class ForgotPassword extends StatelessWidget {
  static String id = 'forgot-password';
  final emailController = TextEditingController();

  // Future resetPasword() async {
  //   await FirebaseAuth.instance
  //       .sendPasswordResetEmail(email: emailController.text.trim());
  //   const snackBar = SnackBar(
  //     content: Text('Email has been sent'),
  //   );
  //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.lightBlueAccent,
        body: Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: Image.asset("assets/images/bg.png").image,
                  fit: BoxFit.cover),
            ),
            child: GlassmorphicContainer(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.9,
              borderRadius: 0,
              blur: 7,
              alignment: Alignment.bottomCenter,
              border: 0,
              linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFF75035).withAlpha(55),
                    const Color(0xFFffffff).withAlpha(45),
                  ],
                  stops: const [
                    0.3,
                    1
                  ]),
              borderGradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                  colors: [
                    const Color(0xFF4579C5).withAlpha(100),
                    const Color(0xFFffffff).withAlpha(55),
                    const Color(0xFFF75035).withAlpha(10),
                  ],
                  stops: const [
                    0.06,
                    0.95,
                    1
                  ]),
              child: Form(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Email Your Email',
                        style: TextStyle(fontSize: 30, color: Colors.white),
                      ),
                      TextFormField(
                        style: const TextStyle(color: Colors.white),
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          icon: Icon(
                            Icons.mail,
                            color: Colors.white,
                          ),
                          errorStyle: TextStyle(color: Colors.white),
                          labelStyle: TextStyle(color: Colors.white),
                          hintStyle: TextStyle(color: Colors.white),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.sendPasswordResetEmail(
                              email: emailController.text.trim());
                          const snackBar = SnackBar(
                            content: Text('Email has been sent'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        },
                        child: const Text('SEND EMAIL'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return const MyHomePage(title: 'Main Page',);
                            },
                          ));
                        },
                        child: const Text('BACK'),
                      )
                    ],
                  ),
                ),
              ),
            )));
  }
}
