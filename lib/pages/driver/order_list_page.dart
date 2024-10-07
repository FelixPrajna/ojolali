import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'trips_page.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({Key? key}) : super(key: key);

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  final DatabaseReference _ordersRef = FirebaseDatabase.instance.ref('orders');
  List<Map<String, dynamic>> orders = [];
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchPendingOrders(); // Fetch pending orders when the page initializes
  }

  // Fetch pending orders from Firebase
  void _fetchPendingOrders() async {
    _ordersRef
        .orderByChild('status')
        .equalTo('pending')
        .onValue
        .listen((event) {
      if (event.snapshot.exists) {
        List<Map<String, dynamic>> tempOrders = [];
        event.snapshot.children.forEach((orderSnapshot) {
          Map<String, dynamic> orderData =
              Map<String, dynamic>.from(orderSnapshot.value as Map);
          orderData['orderId'] =
              orderSnapshot.key; // Include orderId for further actions
          tempOrders.add(orderData);
        });

        setState(() {
          orders = tempOrders;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pending Orders"),
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          var order = orders[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(
                  "Order from ${order['pickupAddress']} to ${order['destinationAddress']}"),
              subtitle: Text("Status: ${order['status']}"),
              trailing: order['status'] == 'pending'
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            _acceptOrder(order['orderId']);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () {
                            _rejectOrder(order['orderId']);
                          },
                        ),
                      ],
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  // Function to accept an order
  void _acceptOrder(String orderId) async {
    // Fetch order details from Firebase
    DatabaseEvent event = await _ordersRef.child(orderId).once();
    if (event.snapshot.exists) {
      Map<String, dynamic> orderData =
          Map<String, dynamic>.from(event.snapshot.value as Map);

      // Update the order status in Firebase
      await _ordersRef.child(orderId).update({
        'status': 'accepted',
        'driverId': firebaseAuth.currentUser!.uid, // Assign to current driver
      });

      // Navigate to TripsPage with order details
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TripsPage(
            startLocation:
                orderData['pickupAddress'] ?? '', // Ensure default value
            endLocation:
                orderData['destinationAddress'] ?? '', // Ensure default value
            distance: orderData['distance'] ?? 0.0, // Ensure default value
          ),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order accepted!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order not found!")),
      );
    }
  }

  // Function to reject an order
  void _rejectOrder(String orderId) async {
    await _ordersRef.child(orderId).update({
      'status': 'rejected',
      'driverId': null, // Remove the driver assignment if rejected
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Order rejected!")),
    );
  }
}
