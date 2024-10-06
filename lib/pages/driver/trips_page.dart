import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; 
import 'dart:math'; 

class TripsPage extends StatefulWidget {
  const TripsPage({super.key});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  final List<Map<String, dynamic>> tripHistory = [];
  final TextEditingController _startLocationController =
      TextEditingController();
  final TextEditingController _endLocationController = TextEditingController();
  final TextEditingController _distanceController =
      TextEditingController(); // Dalam KM

  @override
  void initState() {
    super.initState();
    _loadTripHistory();
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

  void _addTrip() {
    if (_startLocationController.text.isNotEmpty &&
        _endLocationController.text.isNotEmpty &&
        _distanceController.text.isNotEmpty) {
      final distance = double.tryParse(_distanceController.text);
      if (distance != null) {
        setState(() {
          final newTrip = {
            'orderId': _generateOrderId(),
            'startLocation': _startLocationController.text,
            'endLocation': _endLocationController.text,
            'distance': distance,
          };
          tripHistory.add(newTrip);
        });
        _startLocationController.clear();
        _endLocationController.clear();
        _distanceController.clear();
        _saveTripHistory(); // Save data after adding trip
      }
    }
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _startLocationController,
                    decoration: const InputDecoration(
                      labelText: 'Lokasi Awal',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _endLocationController,
                    decoration: const InputDecoration(
                      labelText: 'Lokasi Akhir',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _distanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jarak Tempuh (KM)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _addTrip,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text("Tambahkan Perjalanan"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: tripHistory.length,
                itemBuilder: (context, index) {
                  final trip = tripHistory[index];
                  return ListTile(
                    title: Text(
                      "Order ID: ${trip['orderId']}",
                    ),
                    subtitle: Text(
                      "Dari: ${trip['startLocation']} ke ${trip['endLocation']} - Jarak: ${trip['distance']} KM",
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
