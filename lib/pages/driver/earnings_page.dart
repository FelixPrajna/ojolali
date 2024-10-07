import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EarningsPage extends StatefulWidget {
  final String userId;
  const EarningsPage({super.key, required this.userId});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  final List<Map<String, dynamic>> orders = []; // To store trip-based orders
  double totalEarnings = 0;
  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id_ID', // Locale Indonesia
    symbol: 'Rp', // Symbol for Rupiah
    decimalDigits: 0, // No decimal places for Rupiah
  );

  @override
  void initState() {
    super.initState();
    _loadEarnings(); // Load total earnings and orders
  }

  Future<void> _loadEarnings() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? completedTripList =
        prefs.getStringList('completedTrips');

    if (completedTripList != null) {
      double totalFromTrips = 0;

      // Iterate through the completed trips and calculate earnings for each trip
      for (var tripJson in completedTripList) {
        final trip = Map<String, dynamic>.from(jsonDecode(tripJson));

        final distanceKm = trip['distance'] as double;
        final earningsFromTrip = (distanceKm * 10) * 1000; // Calculate earnings
        totalFromTrips += earningsFromTrip;

        // Add to order history
        orders.add({
          'orderId': trip['orderId'],
          'startLocation': trip['startLocation'],
          'endLocation': trip['endLocation'],
          'distance': distanceKm,
          'earnings': earningsFromTrip,
        });
      }

      setState(() {
        totalEarnings = totalFromTrips; // Update total earnings
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Earnings Page"),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return ListTile(
                    title: Text("Order ID: ${order['orderId']}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Dari: ${order['startLocation']}"),
                        Text("Ke: ${order['endLocation']}"),
                        Text("Jarak: ${order['distance']} KM"),
                        Text(
                            "Pendapatan: ${currencyFormatter.format(order['earnings'])}")
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Total Pendapatan: ${currencyFormatter.format(totalEarnings)}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
