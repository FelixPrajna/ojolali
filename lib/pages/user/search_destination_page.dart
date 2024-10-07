import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_database/firebase_database.dart';

class SearchDestinationPage extends StatefulWidget {
  const SearchDestinationPage({Key? key}) : super(key: key);

  @override
  State<SearchDestinationPage> createState() => _SearchDestinationPageState();
}

class _SearchDestinationPageState extends State<SearchDestinationPage> {
  TextEditingController pickupTextEditingController = TextEditingController();
  TextEditingController destinationTextEditingController =
      TextEditingController();
  List<Placemark> pickupPlaces = [];
  List<Placemark> destinationPlaces = [];

  // Database reference
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  void searchPickupLocation(String query) async {
    if (query.isNotEmpty) {
      // Fetch the Location from the address
      var locations = await locationFromAddress(query);
      // If you want to convert Location to Placemark, use the first Location to fetch Placemark
      if (locations.isNotEmpty) {
        var placemarks = await placemarkFromCoordinates(
            locations.first.latitude, locations.first.longitude);
        setState(() {
          pickupPlaces = placemarks; // Store the placemarks
        });
      }
    }
  }

  void searchDestinationLocation(String query) async {
    if (query.isNotEmpty) {
      // Fetch the Location from the address
      var locations = await locationFromAddress(query);
      // If you want to convert Location to Placemark, use the first Location to fetch Placemark
      if (locations.isNotEmpty) {
        var placemarks = await placemarkFromCoordinates(
            locations.first.latitude, locations.first.longitude);
        setState(() {
          destinationPlaces = placemarks; // Store the placemarks
        });
      }
    }
  }

  void createOrder() async {
    String pickupAddress = pickupTextEditingController.text;
    String destinationAddress = destinationTextEditingController.text;

    print("Pickup Address: $pickupAddress"); // Tambahkan log untuk memeriksa
    print("Destination Address: $destinationAddress");

    // Logika untuk membuat order di sini
    if (pickupAddress.isNotEmpty && destinationAddress.isNotEmpty) {
      // Menyimpan order ke Firebase
      final orderId = _database
          .child('orders')
          .push()
          .key; // Menghasilkan ID unik untuk order
      await _database.child('orders/$orderId').set({
        'pickupAddress': pickupAddress,
        'destinationAddress': destinationAddress,
        'status': 'pending', // Status order dapat disesuaikan
        'createdAt': DateTime.now().toIso8601String(),
      }).then((_) {
        // Tampilkan notifikasi atau navigasi ke halaman lain
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Order created successfully!")),
        );
        pickupTextEditingController.clear();
        destinationTextEditingController.clear();
      }).catchError((error) {
        // Tampilkan pesan kesalahan jika terjadi error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create order: $error")),
        );
      });
    } else {
      // Tampilkan pesan kesalahan jika alamat tidak lengkap
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in both addresses.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              elevation: 10,
              child: Container(
                height: 300,
                decoration: const BoxDecoration(
                  color: Colors.black12,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 24, top: 48, right: 26, bottom: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 6),

                      // Icon button - title
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context); // Aksi untuk kembali
                            },
                            child: const Icon(Icons.arrow_back,
                                color: Colors.white),
                          ),
                          const Center(
                            child: Text(
                              "Set Dropoff Location",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Pickup text field
                      Row(
                        children: [
                          Image.asset(
                            "images/initial.png",
                            height: 16,
                            width: 16,
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3),
                                child: TextField(
                                  controller: pickupTextEditingController,
                                  onChanged: searchPickupLocation,
                                  decoration: const InputDecoration(
                                    hintText: "Pickup Address",
                                    fillColor: Colors.white12,
                                    filled: true,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                      left: 11,
                                      top: 9,
                                      bottom: 9,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 11),

                      // Destination text field
                      Row(
                        children: [
                          Image.asset(
                            "images/final.png",
                            height: 16,
                            width: 16,
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3),
                                child: TextField(
                                  controller: destinationTextEditingController,
                                  onChanged: searchDestinationLocation,
                                  decoration: const InputDecoration(
                                    hintText: "Destination Address",
                                    fillColor: Colors.white12,
                                    filled: true,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                      left: 11,
                                      top: 9,
                                      bottom: 9,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Create Order button
                      ElevatedButton(
                        onPressed: createOrder,
                        child: const Text("Create Order"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
