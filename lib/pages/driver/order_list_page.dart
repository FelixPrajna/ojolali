import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ojolali/global/global.dart';

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
    _fetchOrders();
  }

  // Fetch orders from Firebase assigned to this driver
  void _fetchOrders() async {
    String driverId =
        firebaseAuth.currentUser!.uid; // Driver's ID from global auth

    _ordersRef
        .orderByChild('driverId')
        .equalTo(driverId)
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
        title: const Text("Your Orders"),
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

  void _acceptOrder(String orderId) async {
    await _ordersRef.child(orderId).update({
      'status': 'accepted',
      'driverId': firebaseAuth.currentUser!.uid, // Assign to current driver
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Order accepted!")),
    );
  }

  void _rejectOrder(String orderId) async {
    await _ordersRef.child(orderId).update({
      'status': 'rejected',
      'driverId': null, // Remove the driver assignment
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Order rejected!")),
    );
  }
}
