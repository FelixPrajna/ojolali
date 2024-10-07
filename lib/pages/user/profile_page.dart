import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart'; // Untuk memilih gambar dari galeri atau kamera

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = "";
  String userEmail = "";
  String userPhone = "";
  String profileImageUrl = ""; // URL gambar profil

  @override
  void initState() {
    super.initState();
    getUserProfileData();
  }

  // Mengambil data profil pengguna dari Firebase Realtime Database
  void getUserProfileData() async {
    DatabaseReference usersRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid);

    usersRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        setState(() {
          userName = (snap.snapshot.value as Map)["name"];
          userEmail = (snap.snapshot.value as Map)["email"];
          userPhone = (snap.snapshot.value as Map)["phone"];
          profileImageUrl = (snap.snapshot.value as Map)["profileImageUrl"] ??
              ""; // Ambil URL gambar profil dari Firebase Database
        });
      }
    });
  }

  // Fungsi untuk memilih gambar dari galeri
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery); // Memilih gambar dari galeri

    if (image != null) {
      // Di sini Anda bisa mengupload gambar ke Firebase Storage dan mendapatkan URL-nya
      // Setelah berhasil diupload, simpan URL gambar di Firebase Realtime Database
      setState(() {
        profileImageUrl = image.path; // Sementara, kita gunakan path lokal
        // Nanti Anda bisa simpan URL dari Firebase di sini
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Tampilan gambar profil
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: profileImageUrl.isNotEmpty
                        ? NetworkImage(profileImageUrl)
                        : const AssetImage("images/default_profile.png")
                            as ImageProvider, // Gambar default jika tidak ada URL
                  ),
                  const SizedBox(height: 10),
                  // Tombol untuk mengganti gambar profil
                  TextButton.icon(
                    onPressed:
                        _pickImage, // Fungsi untuk mengganti gambar profil
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Change Profile Image"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Teks menampilkan nama pengguna
            Text(
              "Name: $userName",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Teks menampilkan email pengguna
            Text(
              "Email: $userEmail",
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            // Teks menampilkan nomor telepon pengguna
            Text(
              "Phone: $userPhone",
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
