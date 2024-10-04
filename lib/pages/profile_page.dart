import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() =>  _ProfilePageState();
}

class  _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "ProfilePage",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          )
        ),
      )
    );
  }
}