import 'package:cpton_food2go_admin_web/main_screen/seller_details_screen.dart';
import 'package:cpton_food2go_admin_web/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

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

    List<Map<String, dynamic>> sellerDataList = [];

    for (DocumentSnapshot<Object?> doc in querySnapshot.docs) {
      // Fetch all records for the current rider from the ridersRecord collection
      QuerySnapshot<Object?> recordsSnapshot = await sellers.doc(doc.id).collection('sellersRecord').get();

      // Calculate average rating
      double averageRating = 0;
      int totalRatings = 0;
      double sumRatings = 0;

      // Iterate over the records to sum up ratings
      recordsSnapshot.docs.forEach((ratingDoc) {
        totalRatings++;
        sumRatings += (ratingDoc['rating'] as num).toDouble();
      });

      // Avoid division by zero
      if (totalRatings > 0) {
        averageRating = sumRatings / totalRatings;
      }

      Map<String, dynamic> sellerData = {
        'sellersName': doc['sellersName'],
        'sellersUID': doc['sellersUID'],
        'sellersEmail': doc['sellersEmail'],
        'sellersAddress': doc['sellersAddress'],
        'sellerPhoto': doc['sellersImageUrl'],
        'sellerEarnings': doc['earnings'],
        'sellersphone': doc['sellersphone'],
        'status': doc['status'],
        'averageRating': averageRating,
      };

      sellerDataList.add(sellerData);
    }

    return sellerDataList;
  }

  Future<void> updateSellerStatus(String sellersUID, bool block) async {
    CollectionReference sellers = FirebaseFirestore.instance.collection('sellers');
    CollectionReference items = FirebaseFirestore.instance.collection('items');

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
                  await sellers.doc(sellersUID).update({
                    'status': 'blocked',
                    'blockingReason': blockingReasonController.text,
                  });

                  await items.where('sellersUID', isEqualTo: sellersUID).get().then((querySnapshot) {
                    querySnapshot.docs.forEach((doc) {
                      doc.reference.update({'status': 'disapproved'});
                    });
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
      await sellers.doc(sellersUID).update({'status': 'approved'});

      await items.where('sellersUID', isEqualTo: sellersUID).get().then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.update({'status': 'available'});
        });
      });
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
      backgroundColor: AppColors().white,
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text('Total Sellers',
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
                  DataColumn(label: Text('Average Rating')),
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
                      DataCell(
                        Text(
                          sellerData['status'],
                          style: TextStyle(
                            color: sellerData['status'] == 'approved' ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                      DataCell(
                        SmoothStarRating(
                          rating: sellerData['averageRating'],
                          size: 16, // Set the size of the stars
                          filledIconData: Icons.star, // Icon to display for filled stars
                          halfFilledIconData: Icons.star_half, // Icon to display for half-filled stars
                          defaultIconData: Icons.star_border, // Icon to display for empty stars
                          color: Colors.yellow, // Set the color of the stars
                          borderColor: AppColors().black, // Set the border color of the stars
                          starCount: 5, // Set the total number of stars
                          allowHalfRating: true, // Allow half ratings
                          spacing: 2.0, // Set spacing between stars
                        ),
                      ),

                      DataCell(
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                updateSellerStatus(sellerData['sellersUID'], !isBlocked);
                                setState(() {
                                  sellerData['status'] = !isBlocked ? 'disapproved' : 'approved';
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
                            SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                navigateToSellerDetailScreen(sellerData);
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: Icon(
                                Icons.visibility,
                                color: AppColors().white,
                              ),
                              label: Text(
                                'View',
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
