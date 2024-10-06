import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:ojolali/main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Map to store the driver's profile information
  Map<String, dynamic> driverDataMap = {};
  bool isLoading = true;

  // Function to load the driver's data from Firebase
  Future<void> loadDriverData() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      DatabaseReference driverRef = FirebaseDatabase.instance
          .ref()
          .child("drivers")
          .child(currentUser.uid);

      DataSnapshot snapshot = await driverRef.get();
      if (snapshot.exists) {
        setState(() {
          driverDataMap = Map<String, dynamic>.from(snapshot.value as Map);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Function to handle logout
  void logoutUser() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MyApp()),
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    loadDriverData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Page"),
        backgroundColor: Colors.pink,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : driverDataMap.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Profile Image
                        driverDataMap['photo'] != null
                            ? CircleAvatar(
                                radius: 60,
                                backgroundImage: NetworkImage(
                                    driverDataMap['photo'] as String),
                              )
                            : const CircleAvatar(
                                radius: 60,
                                backgroundImage:
                                    AssetImage("images/avatarman.png"),
                              ),
                        const SizedBox(height: 20),

                        // Driver's Name
                        Text(
                          driverDataMap['name'] ?? 'Unknown',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),

                        // Driver's Email
                        Text(
                          driverDataMap['email'] ?? 'No email provided',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 5),

                        // Driver's Phone Number
                        Text(
                          driverDataMap['phone'] ?? 'No phone number provided',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),

                        // Car Information (Model, Color, Number)
                        const Text(
                          'Car Information:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Model: ${driverDataMap['car_details']['carModel'] ?? 'Unknown'}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Color: ${driverDataMap['car_details']['carColor'] ?? 'Unknown'}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Number: ${driverDataMap['car_details']['carNumber'] ?? 'Unknown'}',
                          style: const TextStyle(fontSize: 16),
                        ),

                        const SizedBox(height: 30),

                        // Log Out Button
                        ElevatedButton(
                          onPressed: logoutUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 80, vertical: 10),
                          ),
                          child: const Text(
                            "Log Out",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const Center(
                  child: Text('No Profile Data Available'),
                ),
    );
  }
}
