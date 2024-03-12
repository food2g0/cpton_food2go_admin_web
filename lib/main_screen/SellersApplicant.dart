import 'package:cpton_food2go_admin_web/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../assistant/assisstant_method.dart';

class SellersApplicants extends StatefulWidget {
  const SellersApplicants({Key? key}) : super(key: key);

  @override
  State<SellersApplicants> createState() => _SellersApplicantsState();
}

class _SellersApplicantsState extends State<SellersApplicants> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text(
          'Sellers Applicant',
          style: TextStyle(
            color: AppColors().white,
            fontFamily: "Poppins",
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sellers')
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
              child: Text('No Sellers Applicant found.'),
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
                      final sellersName = doc['sellersName'];
                      final sellersEmail = doc['sellersEmail'];
                      final sellersAddress = doc['sellersAddress'];
                      final sellersRegistration = doc['sellersAddress'];
                      return DataRow(cells: [
                        DataCell(Text(sellersName)),
                        DataCell(Text(sellersEmail)),
                        DataCell(Text(sellersAddress)),
                        DataCell(Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Implement view button action
                                _viewSeller(doc['sellersUID'], context);
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
                                sendNotificationToSellerNowApproved(doc.id, sellersRegistration);

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
          .collection('sellers')
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
        .collection('sellersDocs')
        .doc(sellersUID)
        .get();

    if (sellerDoc.exists) {
      // Check if the document exists
      var data = sellerDoc.data();
      if (data != null && data is Map<String, dynamic>) {
        if (data.containsKey('documentUrl')) {
          // If documentUrl field exists, it's an image
          String documentUrl = data['documentUrl'];
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Document'),
              content: Text('Do you want to view this document?'),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (await canLaunch(documentUrl)) {
                      await launch(documentUrl);
                    } else {
                      throw 'Could not launch $documentUrl';
                    }
                  },
                  child: Text('View'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
              ],
            ),
          );
        } else {
          // Handle the case where documentUrl field is not present
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: Text('Document URL not found'),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text('An error occurred while viewing the document'),
      ),
    );
  }
}
void sendNotificationToSellerNowApproved(String docId, String registrationToken) {
  FirebaseFirestore.instance.collection("sellers").doc(docId).get().then((DocumentSnapshot snap) {
    if (snap.exists) {
      Map<String, dynamic>? userData = snap.data() as Map<String, dynamic>?;

      if (userData != null && userData.containsKey('registrationToken')) {
        String registrationToken = userData['registrationToken'] as String;

        //send notification
        AssistantMethods.sendNotificationToSellersApplicationApproved(registrationToken);


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


