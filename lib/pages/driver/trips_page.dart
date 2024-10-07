import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

class TripsPage extends StatefulWidget {
  final String startLocation;
  final String endLocation;
  final double distance;

  const TripsPage({
    Key? key,
    required this.startLocation,
    required this.endLocation,
    required this.distance,
  }) : super(key: key);

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  final List<Map<String, dynamic>> tripHistory = [];
  final TextEditingController _startLocationController =
      TextEditingController();
  final TextEditingController _endLocationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTripHistory();

    // Add the trip from order details
    _addTripFromOrder(
        widget.startLocation, widget.endLocation, widget.distance);
  }

  Future<void> _loadTripHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedTripList = prefs.getStringList('tripHistory');

    if (savedTripList != null) {
      setState(() {
        tripHistory.clear();
        tripHistory.addAll(savedTripList
            .map((trip) => Map<String, dynamic>.from(jsonDecode(trip))));
      });
    }
  }

  Future<void> _saveTripHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> tripStringList =
        tripHistory.map((trip) => jsonEncode(trip)).toList();
    await prefs.setStringList('tripHistory', tripStringList);
  }

  void _addTripFromOrder(String startLocation, String endLocation, double distance) {
    double randomDistance = _generateRandomDistance(); // Get a random distance
    setState(() {
      final newTrip = {
        'orderId': _generateOrderId(),
        'startLocation': startLocation,
        'endLocation': endLocation,
        'distance': randomDistance,
        'status': 'in progress',
      };
      tripHistory.add(newTrip);
    });
    _saveTripHistory(); // Save data after adding trip
  }

  void _completeTrip(int orderId) async {
  // Find the trip by orderId in tripHistory
  setState(() {
    final tripIndex =
        tripHistory.indexWhere((trip) => trip['orderId'] == orderId);
    if (tripIndex != -1) {
      // Save completed trip's distance and earnings
      final completedTrip = tripHistory[tripIndex];

      // You can save completed trips in SharedPreferences or another list
      _saveCompletedTrip(completedTrip);

      // Remove the trip from the list
      tripHistory.removeAt(tripIndex); // Remove the completed trip from the list
    }
    });

    // Update the trip status in Firebase
  await FirebaseDatabase.instance.ref('orders/$orderId').update({
    'status': 'completed',
  });

    // Save the changes to local storage
    _saveTripHistory(); // Save changes in local storage
  }

  Future<void> _saveCompletedTrip(Map<String, dynamic> completedTrip) async {
  final prefs = await SharedPreferences.getInstance();
  final List<String>? completedTripList = prefs.getStringList('completedTrips') ?? [];
  completedTripList?.add(jsonEncode(completedTrip));
  await prefs.setStringList('completedTrips', completedTripList!);
}

  double _generateRandomDistance() {
    final random = Random();
    return random.nextDouble() * 500 + 1; // Generate a random distance between 1 and 100
  }

  int _generateOrderId() {
    final random = Random();
    return random.nextInt(90000000) + 10000000; // Generate 8-digit order ID
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trips Page"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: tripHistory.length,
                itemBuilder: (context, index) {
                  final trip = tripHistory[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(
                        "Order ID: ${trip['orderId']}",
                      ),
                      subtitle: Text(
                        "Dari: ${trip['startLocation']} ke ${trip['endLocation']} - Jarak: ${trip['distance']} KM\nStatus: ${trip['status']}",
                      ),
                      trailing: trip['status'] == 'in progress'
                          ? ElevatedButton(
                              onPressed: () {
                                _completeTrip(trip['orderId']);
                              },
                              child: const Text("Complete"),
                            )
                          : const Text("Completed",
                              style: TextStyle(color: Colors.green)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
