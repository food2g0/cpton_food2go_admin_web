import 'package:cpton_food2go_admin_web/main_screen/seller_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TotalSellerScreen extends StatefulWidget {
  const TotalSellerScreen({Key? key}) : super(key: key);

  @override
  State<TotalSellerScreen> createState() => _TotalSellerScreenState();
}

class _TotalSellerScreenState extends State<TotalSellerScreen> {
  late Future<List<Map<String, dynamic>>> sellersData;
  late TextEditingController blockingReasonController;
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    sellersData = fetchSellersData();
    blockingReasonController = TextEditingController();
    searchController = TextEditingController();
  }

  Future<List<Map<String, dynamic>>> fetchSellersData() async {
    CollectionReference sellers = FirebaseFirestore.instance.collection('sellers');

    QuerySnapshot<Object?> querySnapshot = await sellers.get();

    return querySnapshot.docs.map((DocumentSnapshot<Object?> doc) {
      return {
        'sellersName': doc['sellersName'],
        'sellersUID': doc['sellersUID'],
        'sellersEmail': doc['sellersEmail'],
        'sellersAddress': doc['sellersAddress'],
        'sellerPhoto': doc['sellersImageUrl'],
        'sellerEarnings': doc['earnings'],
        'sellersphone': doc['sellersphone'],

        'status': doc['status'],
      };
    }).toList();
  }

  Future<void> updateSellerStatus(String sellerUID, bool block) async {
    CollectionReference sellers = FirebaseFirestore.instance.collection('sellers');

    if (block) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Block Seller'),
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
                  await sellers.doc(sellerUID).update({
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
    } else {
      await sellers.doc(sellerUID).update({'status': 'approved'});
    }
  }

  List<Map<String, dynamic>> filterSellers(String query, List<Map<String, dynamic>> sellers) {
    return sellers.where((seller) =>
    seller['sellersName'].toLowerCase().contains(query.toLowerCase()) ||
        seller['sellersUID'].toLowerCase().contains(query.toLowerCase())).toList();
  }

  void viewSellerDetails(Map<String, dynamic> sellerData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Seller Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Seller Name: ${sellerData['sellersName']}'),
              Text('Seller UID: ${sellerData['sellersUID']}'),
              Text('Email: ${sellerData['sellersEmail']}'),
              Text('Address: ${sellerData['sellersAddress']}'),
              Text('Phone: ${sellerData['sellersphone']}'),
              Text('Status: ${sellerData['status']}'),
              if (sellerData['status'] == 'disapproved')
                Text('Blocking Reason: ${sellerData['blockingReason']}'),
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

  void navigateToSellerDetailScreen(Map<String, dynamic> sellerData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SellerDetailScreen(sellerData: sellerData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Total Sellers'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Search Sellers'),
                    content: TextField(
                      controller: searchController,
                      decoration: InputDecoration(labelText: 'Enter seller name or UID'),
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
                            sellersData = fetchSellersData().then(
                                  (sellers) => filterSellers(searchController.text, sellers),
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
        future: sellersData,
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
              child: Text('No sellers found.'),
            );
          } else {
            return Align(
              alignment: Alignment.topCenter,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Seller Name')),
                  DataColumn(label: Text('Seller UID')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: snapshot.data!.map<DataRow>((sellerData) {
                  bool isBlocked = sellerData['status'] == 'disapproved';
                  return DataRow(
                    cells: [
                      DataCell(
                        InkWell(
                          onTap: () {
                            viewSellerDetails(sellerData);
                          },
                          child: Text(sellerData['sellersName']),
                        ),
                      ),
                      DataCell(Text(sellerData['sellersUID'])),
                      DataCell(Text(sellerData['status'])),
                      DataCell(
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                updateSellerStatus(sellerData['sellersUID'], !isBlocked);
                                setState(() {
                                  sellerData['status'] = !isBlocked ? 'disapproved' : 'approved';
                                });
                              },
                              child: Text(!isBlocked ? 'Block Seller' : 'Unblock Seller'),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                navigateToSellerDetailScreen(sellerData);
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.green, // Set the button color to green
                              ),
                              child: Text('View Details'),
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


