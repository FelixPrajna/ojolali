import 'package:flutter/material.dart';
import 'package:ojolali/pages/earnings_page.dart';
import 'package:ojolali/pages/homepage_driver.dart';
import 'package:ojolali/pages/profile_page.dart';
import 'package:ojolali/pages/trips_page.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin
{
  TabController? controller;
  int indexSelected = 0;


  onBarItemClicked(int i)
  {
    setState(() {
      indexSelected = i;
      controller!.index = indexSelected;
    });
  }
  
  @override
  void initState() {
    // TODO: implement initState
    
    
    controller = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller!.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
      physics: const NeverScrollableScrollPhysics(),
      controller: controller,
      children: const [
        HomeDriverPage(),
        EarningsPage(),
        TripsPage(),
        ProfilePage(),
      ],
    ),
      bottomNavigationBar: BottomNavigationBar(
        items: const
        [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home"
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: "Earnings"
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.account_tree),
            label: "Trips"
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile"
          ),
        ],
        currentIndex: indexSelected,
        //backgroundColor: Colors.grey,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.pink,
        showSelectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        onTap: onBarItemClicked,
       ),
    );
  }
}
