import 'dart:async';

import 'package:cpton_food2go_admin_web/main_screen/SellersApplicant.dart';
import 'package:cpton_food2go_admin_web/main_screen/total_sellers_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String timeText = "";
  String dateText = "";
  int numberOfCustomers = 0; // Initialize with zero or the default value
  int numberOfSellers = 0; // Initialize with zero or the default value
  int numberOfSellersApplicant = 0; // Initialize with zero or the default value
  int numberOfRiders = 0; // Initialize with zero or the default value
  int numberOfRidersApplicant = 0; // Initialize with zero or the default value

  String formatCurrentLiveTime(DateTime time) {
    return DateFormat("hh:mm:ss a").format(time);
  }

  String formatCurrentDate(DateTime date) {
    return DateFormat("dd MMMM, yyyy").format(date);
  }

  getCurrentLiveTime() {
    final DateTime timeNow = DateTime.now();
    final String liveTime = formatCurrentLiveTime(timeNow);
    final String liveDate = formatCurrentDate(timeNow);

    if (this.mounted) {
      setState(() {
        timeText = liveTime;
        dateText = liveDate;
      });
    }
  }

  Future<void> fetchNumberOfCustomers() async {
    // Reference to Firestore collection 'users'
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    // Get the documents from the collection
    QuerySnapshot querySnapshot = await users.get();

    setState(() {
      numberOfCustomers = querySnapshot.size;
    });
  }

  Future<void> fetchNumberOfSellers() async {
    // Reference to Firestore collection 'sellers'
    CollectionReference sellers = FirebaseFirestore.instance.collection('sellers');

    // Get the documents with status 'approved' from the collection
    QuerySnapshot querySnapshot = await sellers.where('status', isEqualTo: 'approved').get();

    // Get the number of documents (sellers) with status 'approved' in the collection
    setState(() {
      numberOfSellers = querySnapshot.size;
    });
  }

  Future<void> fetchNumberOfSellersApplicants() async {
    // Reference to Firestore collection 'sellers'
    CollectionReference sellers = FirebaseFirestore.instance.collection('sellers');

    // Get the documents with status 'disapproved' from the collection
    QuerySnapshot querySnapshot = await sellers.where('status', isEqualTo: 'disapproved').get();

    // Get the number of documents (sellers) with status 'disapproved' in the collection
    setState(() {
      numberOfSellersApplicant = querySnapshot.size;
    });
  }


  Future<void> fetchNumberOfRiders() async {
    // Reference to Firestore collection 'users'
    CollectionReference users = FirebaseFirestore.instance.collection('riders');

    // Get the documents from the collection
    QuerySnapshot querySnapshot = await users.get();

    // Get the number of documents (customers) in the collection
    setState(() {
      numberOfRiders = querySnapshot.size;
    });
  }

  Future<void> fetchNumberOfRidersApplicant() async {
    // Reference to Firestore collection 'users'
    CollectionReference riders = FirebaseFirestore.instance.collection('riders');

    QuerySnapshot querySnapshot = await riders.where('status', isEqualTo: 'disapproved').get();


    // Get the number of documents (customers) in the collection
    setState(() {
      numberOfRidersApplicant = querySnapshot.size;
    });
  }

  @override
  void initState() {
    super.initState();

    // Fetch the initial number of customers
    fetchNumberOfCustomers();
    fetchNumberOfRiders();
    fetchNumberOfSellers();
    fetchNumberOfSellersApplicants();

    // Set up the timer for live time
    Timer.periodic(const Duration(seconds: 1), (timer) {
      getCurrentLiveTime();
    });
  }

  // ... (Previous code remains unchanged)
  void viewAllCustomers() {
    // Implement the action for "View All Customers"
    // For example, navigate to a new screen or show a dialog
  }

  void viewAllSellers() {
    // Implement the action for "View All Sellers"
   Navigator.push(context, MaterialPageRoute(builder: (c)=> TotalSellerScreen()));
  }

  void viewAllRiders() {
    // Implement the action for "View All Riders"
    // For example, navigate to a new screen or show a dialog
  }

  void viewAllRidersApplicants() {
    // Implement the action for "View All Rider Applicants"
    // For example, navigate to a new screen or show a dialog
  }

  void viewAllSellersApplicants() {
    // Implement the action for "View All Seller Applicants"
    // For example, navigate to a new screen or show a dialog
    Navigator.push(context, MaterialPageRoute(builder: (c)=> SellersApplicants()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Admin Dashboard'),
            Text(
              '$timeText $dateText',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Admin Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Dashboard'),
              onTap: () {
                // Handle dashboard tap
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Users'),
              onTap: () {
                // Handle users tap
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Products'),
              onTap: () {
                // Handle products tap
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Settings'),
              onTap: () {
                // Handle settings tap
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCard('Total Customers', numberOfCustomers.toString(), 'View All Customers', viewAllCustomers),
                _buildCard('Total Sellers', numberOfSellers.toString(), 'View All Sellers', viewAllSellers),
                _buildCard('Total Riders', numberOfRiders.toString(), 'View All Riders', viewAllRiders),
                _buildCard('New Rider Applicant', numberOfRidersApplicant.toString(), 'View All Riders', viewAllRidersApplicants),
                _buildCard('New Seller Applicant', numberOfSellersApplicant.toString(), 'View All Seller', viewAllSellersApplicants),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, String count, String viewAllLabel, void Function() onPressed) {
    return Container(
      height: 150,
      width: 250,
      color: AppColors().black1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              count,
              style: TextStyle(fontSize: 24,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: onPressed,
              child: Text(
                viewAllLabel,
                style: TextStyle(fontSize: 12, color: AppColors().red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

