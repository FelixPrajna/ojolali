import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl for currency formatting
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class EarningsPage extends StatefulWidget {
  final String userId; // Add userId to identify the account
  const EarningsPage({super.key, required this.userId});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  final List<double> earnings = [];
  final TextEditingController _controller = TextEditingController();
  double totalEarnings = 0;

  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id_ID', // Locale Indonesia
    symbol: 'Rp', // Symbol for Rupiah
    decimalDigits: 0, // No decimal places for Rupiah
  );

  @override
  void initState() {
    super.initState();
    _loadEarnings();
  }

  // Function to load earnings from SharedPreferences based on userId
  Future<void> _loadEarnings() async {
    final prefs = await SharedPreferences.getInstance();

    // Load earnings for the specific user
    final List<String>? earningsList =
        prefs.getStringList('${widget.userId}_earnings');
    final double? savedTotalEarnings =
        prefs.getDouble('${widget.userId}_totalEarnings');

    if (earningsList != null) {
      setState(() {
        earnings.clear();
        earnings.addAll(earningsList.map((e) => double.parse(e)).toList());
        totalEarnings = savedTotalEarnings ?? 0;
      });
    }
  }

  // Function to save earnings to SharedPreferences based on userId
  Future<void> _saveEarnings() async {
    final prefs = await SharedPreferences.getInstance();

    // Save earnings for the specific user
    final List<String> earningsStringList =
        earnings.map((e) => e.toString()).toList();
    await prefs.setStringList('${widget.userId}_earnings', earningsStringList);
    await prefs.setDouble('${widget.userId}_totalEarnings', totalEarnings);
  }

  // Function to add new order earnings
  void _addEarning() {
    if (_controller.text.isNotEmpty) {
      final earning = double.tryParse(_controller.text);
      if (earning != null) {
        setState(() {
          earnings.add(earning);
          totalEarnings += earning;
        });
        _controller.clear();
        _saveEarnings(); // Save data after adding earnings
      }
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
            // Input field for manual entry
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Masukkan Pendapatan Order',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addEarning,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                  ),
                  child: const Text("Tambahkan"),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Display list of earnings
            Expanded(
              child: ListView.builder(
                itemCount: earnings.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      "Order ${index + 1}: ${currencyFormatter.format(earnings[index])}",
                    ),
                  );
                },
              ),
            ),

            // Total earnings display
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
