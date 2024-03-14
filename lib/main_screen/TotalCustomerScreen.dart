import 'package:cpton_food2go_admin_web/main_screen/RiderDetailScreen.dart';
import 'package:cpton_food2go_admin_web/main_screen/seller_details_screen.dart';
import 'package:cpton_food2go_admin_web/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

class TotalCustomerScreen extends StatefulWidget {
  const TotalCustomerScreen({Key? key}) : super(key: key);

  @override
  State<TotalCustomerScreen> createState() => _TotalCustomerScreenState();
}

class _TotalCustomerScreenState extends State<TotalCustomerScreen> {
  late Future<List<Map<String, dynamic>>> riderData;
  late TextEditingController blockingReasonController;
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    riderData = fetchRiderData();
    blockingReasonController = TextEditingController();
    searchController = TextEditingController();
  }

  Future<List<Map<String, dynamic>>> fetchRiderData() async {
    CollectionReference riders = FirebaseFirestore.instance.collection('users');

    QuerySnapshot<Object?> querySnapshot = await riders.get();

    List<Map<String, dynamic>> riderDataList = [];

    for (DocumentSnapshot<Object?> doc in querySnapshot.docs) {
      // Fetch all records for the current rider from the ridersRecord collection

      // Calculate average rating


      // Iterate over the records to sum up ratings


      Map<String, dynamic> riderData = {
        'customersName': doc['customersName'],
        'customersUID': doc['customersUID'],
        'customersEmail': doc['customersEmail'],
        'address': doc['address'],
        'customerImageUrl': doc['customerImageUrl'],
        'phone': doc['phone'],
        'status': doc['status'],

      };

      riderDataList.add(riderData);
    }

    return riderDataList;
  }


  Future<void> updateSellerStatus(String customersUID, bool block) async {
    CollectionReference riders = FirebaseFirestore.instance.collection('users');


    if (block) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Block Customer'),
            content: Column(
              children: [
                Text('Enter the reason for blocking:'),
                TextField(
                  controller: blockingReasonController,
                  decoration: InputDecoration(labelText: 'Reason'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await riders.doc(customersUID).update({
                    'status': 'disapproved',
                    'blockingReason': blockingReasonController.text,
                  });

                  blockingReasonController.clear();
                  Navigator.of(context).pop();
                },
                child: Text('Block'),
              ),
            ],
          );
        },
      );
    }
  }

  List<Map<String, dynamic>> filterRiders(String query, List<Map<String, dynamic>> riders) {
    return riders.where((riders) =>
    riders['customersName'].toLowerCase().contains(query.toLowerCase()) ||
        riders['customersUID'].toLowerCase().contains(query.toLowerCase())).toList();
  }

  void viewSellerDetails(Map<String, dynamic> riderData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Customers Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Customer Name: ${riderData['customersName']}'),
              Text('Customer UID: ${riderData['customersUID']}'),
              Text('Email: ${riderData['customersEmail']}'),
              Text('Address: ${riderData['address']}'),
              Text('Phone: ${riderData['phone']}'),
              Text('Status: ${riderData['status']}'),
              if (riderData['status'] == 'disapproved')
                Text('Blocking Reason: ${riderData['blockingReason']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().white,
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text('Total Customer',
          style: TextStyle(color: AppColors().white,
              fontFamily: "Poppins"),),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Search Customer'),
                    content: TextField(
                      controller: searchController,
                      decoration: InputDecoration(labelText: 'Enter Customer name or UID'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            riderData = fetchRiderData().then(
                                  (riders) => filterRiders(searchController.text, riders),
                            );
                          });
                          Navigator.of(context).pop();
                        },
                        child: Text('Search'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: riderData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No riders found.'),
            );
          } else {
            return Align(
              alignment: Alignment.topCenter,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Customer Name')),
                  DataColumn(label: Text('Customer UID')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: snapshot.data!.map<DataRow>((riderData) {
                  bool isBlocked = riderData['status'] == 'disapproved';
                  return DataRow(
                    cells: [
                      DataCell(
                        InkWell(
                          onTap: () {
                            // viewSellerDetails(riderData);
                          },
                          child: Text(riderData['customersName']),
                        ),
                      ),
                      DataCell(Text(riderData['customersUID'])),
                      DataCell(
                        Text(
                          riderData['status'],
                          style: TextStyle(
                            color: riderData['status'] == 'approved' ? Colors.green : Colors.red,
                          ),
                        ),
                      ),



                      DataCell(
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                updateSellerStatus(riderData['customersUID'], !isBlocked);
                                setState(() {
                                  riderData['status'] = !isBlocked ? 'blocked' : 'approved';
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                primary: !isBlocked ? Colors.red : Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: Icon(
                                !isBlocked ? Icons.block : Icons.check_circle,
                                color: AppColors().white,
                              ),
                              label: Text(
                                !isBlocked ? 'Block' : 'Unblock',
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  color: AppColors().white,
                                ),
                              ),
                            ),

                          ],
                        ),

                      ),
                    ],
                  );
                }).toList(),
              ),
            );
          }
        },
      ),
    );
  }
}
