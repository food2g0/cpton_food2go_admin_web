import 'package:cpton_food2go_admin_web/main_screen/RiderDetailScreen.dart';
import 'package:cpton_food2go_admin_web/main_screen/seller_details_screen.dart';
import 'package:cpton_food2go_admin_web/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

class TotalRidersScreen extends StatefulWidget {
  const TotalRidersScreen({Key? key}) : super(key: key);

  @override
  State<TotalRidersScreen> createState() => _TotalRidersScreenState();
}

class _TotalRidersScreenState extends State<TotalRidersScreen> {
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
    CollectionReference riders = FirebaseFirestore.instance.collection('riders');

    QuerySnapshot<Object?> querySnapshot = await riders.get();

    List<Map<String, dynamic>> riderDataList = [];

    for (DocumentSnapshot<Object?> doc in querySnapshot.docs) {
      // Fetch all records for the current rider from the ridersRecord collection
      QuerySnapshot<Object?> recordsSnapshot = await riders.doc(doc.id).collection('ridersRecord').get();

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

      Map<String, dynamic> riderData = {
        'riderName': doc['riderName'],
        'riderUID': doc['riderUID'],
        'riderEmail': doc['riderEmail'],
        'address': doc['address'],
        'riderAvatarUrl': doc['riderAvatarUrl'],
        'earnings': doc['earnings'],
        'phone': doc['phone'],
        'status': doc['status'],
        'averageRating': averageRating,
      };

      riderDataList.add(riderData);
    }

    return riderDataList;
  }


  Future<void> updateSellerStatus(String riderUID, bool block) async {
    CollectionReference riders = FirebaseFirestore.instance.collection('riders');


    if (block) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Block Rider'),
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
                  await riders.doc(riderUID).update({
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
    riders['riderName'].toLowerCase().contains(query.toLowerCase()) ||
        riders['riderUID'].toLowerCase().contains(query.toLowerCase())).toList();
  }

  void viewSellerDetails(Map<String, dynamic> riderData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Rider Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Rider Name: ${riderData['riderName']}'),
              Text('Rider UID: ${riderData['riderUID']}'),
              Text('Email: ${riderData['riderEmail']}'),
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

  void navigateToRiderDetailScreen(Map<String, dynamic> riderData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RiderDetailScreen(riderData: riderData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().white,
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text('Total Riders',
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
                    title: Text('Search Riders'),
                    content: TextField(
                      controller: searchController,
                      decoration: InputDecoration(labelText: 'Enter Rider name or UID'),
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
                  DataColumn(label: Text('Rider Name')),
                  DataColumn(label: Text('Rider UID')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Average Rating')),
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
                          child: Text(riderData['riderName']),
                        ),
                      ),
                      DataCell(Text(riderData['riderUID'])),
                      DataCell(
                        Text(
                          riderData['status'],
                          style: TextStyle(
                            color: riderData['status'] == 'approved' ? Colors.green : Colors.red,
                          ),
                        ),
                      ),

                      DataCell(
                        SmoothStarRating(
                          rating: riderData['averageRating'],
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
                                updateSellerStatus(riderData['riderUID'], !isBlocked);
                                setState(() {
                                  riderData['status'] = !isBlocked ? 'disapproved' : 'approved';
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
                                navigateToRiderDetailScreen(riderData);
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
