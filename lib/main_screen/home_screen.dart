import 'dart:async';

import 'package:cpton_food2go_admin_web/assistant/assisstant_method.dart';
import 'package:cpton_food2go_admin_web/main_screen/RiderApplicant.dart';
import 'package:cpton_food2go_admin_web/main_screen/SellersApplicant.dart';
import 'package:cpton_food2go_admin_web/main_screen/TotalCustomerScreen.dart';
import 'package:cpton_food2go_admin_web/main_screen/releasing_screen.dart';
import 'package:cpton_food2go_admin_web/main_screen/total_riders.dart';
import 'package:cpton_food2go_admin_web/main_screen/total_sellers_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter_new/flutter.dart' as charts;
import '../Sales.dart';
import '../theme/colors.dart';
import 'Tabel_2.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String timeText = "";
  String dateText = "";
  int numberOfCustomers = 0;
  int numberOfSellers = 0;
  int numberOfSellersApplicant = 0;
  int numberOfRiders = 0;
  int numberOfRidersApplicant = 0;
  late Stream<QuerySnapshot> _ordersStream;
  late Stream<QuerySnapshot> _ordersStreamforSellerFeedback;
  QuerySnapshot? _previousSnapshot;

  @override
  void initState() {
    super.initState();
    // Timer.periodic(const Duration(seconds: 1), (timer) {
    //   getCurrentLiveTime();
    // });
    fetchNumbers();
    _ordersStream = fetchOrdersStream();
    _ordersStreamforSellerFeedback= fetchSellerFeedbackStream();
  }

  void fetchNumbers() {
    fetchNumberOfCustomers();
    fetchNumberOfRiders();
    fetchNumberOfSellers();
    fetchNumberOfSellersApplicants();
    fetchNumberOfRidersApplicants();
  }


  List<charts.Series<Sales, String>> _seriesBarData = [];

  late List<Sales> myData;

  _generateData(myData) {
    _seriesBarData.add(
      charts.Series(
        domainFn: (Sales sales, _) => sales.saleYear.toString(),
        measureFn: (Sales sales, _) => sales.saleVal,
        colorFn: (Sales sales, _) =>
            charts.ColorUtil.fromDartColor(Color(int.parse(sales.colorVal))),
        id: 'Sales',
        data: myData,
        labelAccessorFn: (Sales row, _) => "${row.saleYear}",
      ),
    );
  }

  Future<void> fetchNumberOfCustomers() async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    QuerySnapshot querySnapshot = await users.get();
    setState(() {
      numberOfCustomers = querySnapshot.size;
    });
  }

  Future<void> fetchNumberOfSellers() async {
    CollectionReference sellers = FirebaseFirestore.instance.collection('sellers');
    QuerySnapshot querySnapshot = await sellers.where('status', isEqualTo: 'approved').get();
    setState(() {
      numberOfSellers = querySnapshot.size;
    });
  }

  Future<void> fetchNumberOfSellersApplicants() async {
    CollectionReference sellers = FirebaseFirestore.instance.collection('sellers');
    QuerySnapshot querySnapshot = await sellers.where('status', isEqualTo: 'disapproved').get();
    setState(() {
      numberOfSellersApplicant = querySnapshot.size;
    });
  }

  Future<void> fetchNumberOfRiders() async {
    CollectionReference users = FirebaseFirestore.instance.collection('riders');
    QuerySnapshot querySnapshot = await users.get();
    setState(() {
      numberOfRiders = querySnapshot.size;
    });
  }

  Future<void> fetchNumberOfRidersApplicants() async {
    CollectionReference riders = FirebaseFirestore.instance.collection('riders');
    QuerySnapshot querySnapshot = await riders.where('status', isEqualTo: 'disapproved').get();
    setState(() {
      numberOfRidersApplicant = querySnapshot.size;
    });
  }

  Stream<QuerySnapshot> fetchOrdersStream() {
    return FirebaseFirestore.instance.collection('orders').where('status', isEqualTo: 'ToPay').snapshots();
  }
  Stream<QuerySnapshot> fetchSellerFeedbackStream() {
    return FirebaseFirestore.instance.collection('sellers').snapshots();
  }

  Stream<List<QuerySnapshot>> fetchAllSellersFeedbackStream() {
    return fetchSellerFeedbackStream().asyncMap((snapshot) async {
      List<QuerySnapshot> feedbackStreams = [];
      for (final doc in snapshot.docs) {
        final sellerUID = doc.id;
        final sellerFeedbackStream = await FirebaseFirestore.instance
            .collection('sellers')
            .doc(sellerUID)
            .collection("sellersRecord")
            .snapshots()
            .first;
        feedbackStreams.add(sellerFeedbackStream);
      }
      return feedbackStreams;
    });
  }


  String formatCurrentLiveTime(DateTime time) {
    return DateFormat("hh:mm:ss a").format(time);
  }

  String formatCurrentDate(DateTime date) {
    return DateFormat("dd MMMM, yyyy").format(date);
  }

  void getCurrentLiveTime() {
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

  void viewAllCustomers() {
    // Implement the action for "View All Customers"
    // For example, navigate to a new screen or show a dialog
     Navigator.push(context, MaterialPageRoute(builder: (c) => TotalCustomerScreen()));
  }

  void viewAllRiders() {
    Navigator.push(context, MaterialPageRoute(builder: (c) => TotalRidersScreen()));
  }

  void viewAllSellers() {
    Navigator.push(context, MaterialPageRoute(builder: (c) => TotalSellerScreen()));
  }

  void viewAllSellersApplicants() {
    Navigator.push(context, MaterialPageRoute(builder: (c) => SellersApplicants()));
  }

  void viewAllRidersApplicants() {
    Navigator.push(context, MaterialPageRoute(builder: (c) => RidersApplicants()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().white1,
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Dashboard',
              style: TextStyle(
                color: AppColors().white,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$timeText $dateText',
              style: TextStyle(fontSize: 14, fontFamily: "Poppins", color: AppColors().black),
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
                color: AppColors().red,
              ),
              child: const Text(
                'Admin Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: "Poppins",
                ),
              ),
            ),
            ListTile(
              title: const Text('Dashboard'),
              onTap: () {
                // Handle dashboard tap
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Users'),
              onTap: () {
                // Handle users tap
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Releasing sellers Earnings'),
              onTap: () {
                // Handle products tap
                Navigator.push(context, MaterialPageRoute(builder: (c)=> ReleasingScreen()));
              },
            ),
            ListTile(
              title: const Text('Releasing Riders Earnings'),
              onTap: () {
                // Handle products tap
                Navigator.push(context, MaterialPageRoute(builder: (c)=> ReleasingScreen()));
              },
            ),

          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
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
                      _buildCard('New Seller Applicant', numberOfSellersApplicant.toString(), 'View All Seller Applicants', viewAllSellersApplicants),
                    ],
                  ),
                  SizedBox(height: 50,),
                  SizedBox(
                    width: 1500,
                    height: 500,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('admin').doc("L2XpbhbHgLUkHrk45en6AJL1krI3").collection("sales").snapshots(),
                      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return LinearProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData || snapshot.data == null) {
                          return Text('No data available');
                        } else {
                          List<Sales> sales = snapshot.data!.docs.map((documentSnapshot) => Sales.fromMap(documentSnapshot.data() as Map<String, dynamic>)).toList();
                          print(sales);
                          return _buildChart(context, sales);
                        }
                      },
                    ),
                  ),

                  SizedBox(height: 10),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 50),
            ),
            SliverToBoxAdapter(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 70, bottom: 20),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Orders with Gcash Payment",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 700, bottom: 20),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "All Orders",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: _ordersStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        return _buildDataTable(snapshot.data!);
                      } else {
                        return Text('No orders with GCash payment method.');
                      }
                    },
                  ),
                  SizedBox(width: 10),
                  BigContainer(),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 50),
            ),
          

          ],
        ),
      ),
    );
  }




  Widget _buildChart(BuildContext context, List<Sales> sales) {
    myData = sales;
    _seriesBarData.clear(); // Clear the list before generating new data
    _generateData(myData);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Container(
          height: 300, // Set a finite height
          child: Center(
            child: Column(
              children: <Widget>[
                Text(
                  "Sales by Month",
                  style: TextStyle(
                    color: AppColors().black,
                    fontFamily: "Poppins",
                    fontSize: 12,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: charts.BarChart(
                    _seriesBarData,
                    animate: true,
                    animationDuration: Duration(seconds: 2),
                    primaryMeasureAxis: charts.NumericAxisSpec(
                      renderSpec: charts.GridlineRendererSpec(
                        labelStyle: charts.TextStyleSpec(
                          fontSize: 12,
                          // Adjust the font size as needed
                          color: charts.MaterialPalette.black,
                          // Adjust the font color as needed
                          fontFamily: 'Poppins', // Change the font family to your desired font
                        ),
                      ),
                    ),
                    // Adjust the bar grouping type to make bars narrower
                    defaultRenderer: charts.BarRendererConfig(
                      groupingType: charts.BarGroupingType.grouped,
                        maxBarWidthPx:60
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }














  Widget _buildDataTable(QuerySnapshot snapshot) {
    return SingleChildScrollView(
      child: SizedBox(
        height: 300,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppColors().white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Order ID',style: TextStyle(
                  fontFamily: "Poppins",
                    fontWeight: FontWeight.bold
                ),)),
                DataColumn(label: Text('Total Amount',style: TextStyle(
                  fontFamily: "Poppins",
                    fontWeight: FontWeight.bold
                ),)),
                DataColumn(label: Text('Reference Number',style: TextStyle(
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.bold
                ),)),
                DataColumn(label: Text('Actions',style: TextStyle(
                  fontFamily: "Poppins",
                    fontWeight: FontWeight.bold
                ),)),
              ],
              rows: snapshot.docs.map<DataRow>((order) {
                String orderId = order.id;
                String totalAmount = order['totalAmount'].toString();
                String referenceNumber = order['referenceNumber'].toString();
                String orderBy = order['orderBy'].toString();

                return DataRow(cells: [
                  DataCell(Text(orderId,style: const TextStyle(
                    fontFamily: "Poppins",
                  ),)),
                  DataCell(Text(totalAmount,style: const TextStyle(
                    fontFamily: "Poppins",
                  ),)),
                  DataCell(Text(referenceNumber,style: const TextStyle(
                    fontFamily: "Poppins",
                  ),)),
                  DataCell(Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            sendNotificationToUserNowOrderApproved(orderId, orderBy);
                            // Update the order status
                            await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
                              'status': 'normal', // Assuming the field for status is 'status'
                            });

                            // Update the user's document
                            await FirebaseFirestore.instance.collection('users').doc(orderBy).collection('orders').doc(orderId).update({
                              'status': 'normal', // Assuming the field for status is 'status'
                            });

                          } catch (e) {
                            print('Error approving order: $e');
                            // Handle error
                          }

                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors().green,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                          ),
                        ),
                        child: Text('Approve', style: TextStyle(color: AppColors().white, fontFamily: "Poppins")),
                      ),

                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Implement disapprove action
                          disapproveOrder(orderId, orderBy);

                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors().red,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                          ),
                        ),
                        child: Text('Disapprove',style: TextStyle(
                            fontFamily: "Poppins",
                            color: AppColors().white
                        ),),
                      ),
                    ],
                  )),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void disapproveOrder(String orderId, String orderBy) {
    String reason = '';
    TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Reason for Disapproval'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(hintText: 'Enter reason'),
            onChanged: (value) {
              reason = value;
            },
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async {
                try {

                  sendNotificationToUserNow(orderId, orderBy);
                  // Update the order status
                  await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
                    'status': 'cancel', // Assuming the field for status is 'status'
                    'disapprovalReason': reason, // Save reason in the 'orders' collection
                  });

                  // Update the user's document in the 'users' collection
                  await FirebaseFirestore.instance.collection('users').doc(orderBy).collection('orders').doc(orderId).update({
                    'status': 'cancel', // Assuming the field for status is 'status'
                    'disapprovalReason': reason, // Save reason in the 'users' collection
                  });

                } catch (e) {
                  print('Error disapproving order: $e');
                  // Handle error
                }
                // Close the dialog
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                primary: AppColors().red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
  void sendNotificationToUserNow(String orderId, String orderBy) {
    FirebaseFirestore.instance.collection("users").doc(orderBy).get().then((DocumentSnapshot snap) {
      if (snap.exists) {
        Map<String, dynamic>? userData = snap.data() as Map<String, dynamic>?;

        if (userData != null && userData.containsKey('registrationToken')) {
          String registrationToken = userData['registrationToken'] as String;

          //send notification
          AssistantMethods.sendNotificationToUserNow(registrationToken, orderId,);


          if (registrationToken.isNotEmpty) {
            // Send notification using the registrationToken
            print('Registration token found: $registrationToken');
            // Call your notification sending function here with the registrationToken
          } else {
            print('Registration token not found or empty.');
          }
        } else {
          print('Registration token not found in user data.');
        }
      } else {
        print('User document not found for order by: $orderBy');
      }
    }).catchError((error) {
      print("Error retrieving user document: $error");
    });
  }
  void sendNotificationToUserNowOrderApproved(String orderId, String orderBy) {
    FirebaseFirestore.instance.collection("users").doc(orderBy).get().then((DocumentSnapshot snap) {
      if (snap.exists) {
        Map<String, dynamic>? userData = snap.data() as Map<String, dynamic>?;

        if (userData != null && userData.containsKey('registrationToken')) {
          String registrationToken = userData['registrationToken'] as String;

          //send notification
          AssistantMethods.sendNotificationToUserNowOrderApproved(registrationToken, orderId,);


          if (registrationToken.isNotEmpty) {
            // Send notification using the registrationToken
            print('Registration token found: $registrationToken');
            // Call your notification sending function here with the registrationToken
          } else {
            print('Registration token not found or empty.');
          }
        } else {
          print('Registration token not found in user data.');
        }
      } else {
        print('User document not found for order by: $orderBy');
      }
    }).catchError((error) {
      print("Error retrieving user document: $error");
    });
  }

  Widget _buildCard(String title, String count, String viewAllLabel, void Function() onPressed) {
    return Container(
      height: 170,
      width: 270,
      decoration: BoxDecoration(
        color: AppColors().white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.bold,
                    color: AppColors().black,
                  ),
                ),
                const SizedBox(width: 20,),
                Icon(
                  Icons.info_outline,
                  color: AppColors().black,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w500,
                color: AppColors().black,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(
                Icons.remove_red_eye,
                size: 18,
                color: AppColors().white,
              ),
              label: Text('View',
                style: TextStyle(color: AppColors().white,
                    fontFamily: "Poppins"),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors().black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
