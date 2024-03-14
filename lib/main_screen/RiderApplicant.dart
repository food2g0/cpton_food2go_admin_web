import 'package:cpton_food2go_admin_web/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../assistant/assisstant_method.dart';

class RidersApplicants extends StatefulWidget {
  const RidersApplicants({Key? key}) : super(key: key);

  @override
  State<RidersApplicants> createState() => _RidersApplicantsState();
}

class _RidersApplicantsState extends State<RidersApplicants> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text(
          'Rider Applicant',
          style: TextStyle(
            color: AppColors().white,
            fontFamily: "Poppins",
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('riders')
            .where('status', isEqualTo: 'disapproved')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No Riders Applicant found.'),
            );
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Address')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: snapshot.data!.docs.map((doc) {
                      final sellersName = doc['riderName'];
                      final sellersEmail = doc['riderEmail'];
                      final sellersAddress = doc['address'];
                      final registrationToken = doc['registrationToken'];
                      return DataRow(cells: [
                        DataCell(Text(sellersName)),
                        DataCell(Text(sellersEmail)),
                        DataCell(Text(sellersAddress)),
                        DataCell(Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Implement view button action
                                _viewSeller(doc['ridersUID'], context);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors().yellow,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  )
                              ),
                              child: Text('View',
                                style: TextStyle(
                                    color: AppColors().white,
                                    fontFamily: "Poppins"
                                ),),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                // Implement approve button action
                                _approveSeller(doc.id);
                                sendNotificationToRiderNowApproved(doc.id, registrationToken);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors().green,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  )
                              ),
                              child: Text('Approve',
                                style: TextStyle(
                                    color: AppColors().white,
                                    fontFamily: "Poppins"
                                ),),
                            ),
                          ],
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _approveSeller(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('riders')
          .doc(docId)
          .update({'status': 'approved'});
      // Optionally, you can show a success message or perform other actions after updating the status.
    } catch (error) {
      // Handle errors here
      print('Error approving seller: $error');
    }
  }
}
Future<void> _viewSeller(String sellersUID, BuildContext context) async {
  try {
    DocumentSnapshot sellerDoc = await FirebaseFirestore.instance
        .collection('RidersDocs')
        .doc(sellersUID)
        .get();

    if (sellerDoc.exists) {
      // Check if the document exists
      var data = sellerDoc.data();
      if (data != null && data is Map<String, dynamic>) {
        // Check if the document has data and cast data to Map<String, dynamic>
        if (data.containsKey('documentUrl')) {
          // If documentUrl field exists, it's an image
          String documentUrl = data['documentUrl'];
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: Image.network(documentUrl),
            ),
          );
        } else if (data.containsKey('fileName')) {
          // If fileName field exists, it's a file
          String fileName = data['fileName'];
          // Display the file name using Text
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: Text(fileName),
            ),
          );
        } else {
          // Handle other types of documents or display an error message
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: Text('Unknown document type'),
            ),
          );
        }
      }
    } else {
      // Handle the case where the document does not exist
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text('Seller document not found'),
        ),
      );
    }
  } catch (error) {
    // Handle errors here
    print('Error viewing seller: $error');
  }
}

void sendNotificationToRiderNowApproved(String docId, String registrationToken) {
  FirebaseFirestore.instance.collection("riders").doc(docId).get().then((DocumentSnapshot snap) {
    if (snap.exists) {
      Map<String, dynamic>? userData = snap.data() as Map<String, dynamic>?;

      if (userData != null && userData.containsKey('registrationToken')) {
        String registrationToken = userData['registrationToken'] as String;

        //send notification
        AssistantMethods.sendNotificationToRidersApplicationApproved(registrationToken);


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
      // Handle the case where the document does not exist
      print('Seller document not found');
    }
  }).catchError((error) {
    print("Error retrieving user document: $error");
  });
}

