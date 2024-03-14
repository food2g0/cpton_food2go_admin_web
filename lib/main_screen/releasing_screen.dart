import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_admin_web/theme/colors.dart';
import 'package:flutter/material.dart';

class ReleasingScreen extends StatefulWidget {
  const ReleasingScreen({Key? key});

  @override
  State<ReleasingScreen> createState() => _ReleasingScreenState();
}

class _ReleasingScreenState extends State<ReleasingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text(
          'Releasing Sellers Earnings',
          style: TextStyle(fontFamily: "Poppins"),
        ),
      ),
      body: Center(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('sellers').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Sellers ID')),
                    DataColumn(label: Text('Sellers Name')),
                    DataColumn(label: Text('Amount')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    String sellersID = document.id;
                    String sellersName = data['sellersName'] ?? '';
                    double originalAmount = data['earningsGCash'] ?? 0.0;
                    double deductedAmount = originalAmount * 0.9; // Subtracting 10%
                    return DataRow(
                      cells: [
                        DataCell(Text(sellersID)),
                        DataCell(Text(sellersName)),
                        DataCell(Text(deductedAmount.toString())),
                        DataCell(
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors().red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)
                              )
                            ),
                            onPressed: () {
                              // Reset earningsGCash to 0
                              resetEarningsGCash(document.reference);
                            },
                            child: Text('Release',
                            style: TextStyle(
                              color: AppColors().white,
                              fontFamily: "Poppins"
                            ),),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
            }
            return Center(
              child: Text('No data available'),
            );
          },
        ),
      ),
    );
  }

  Future<void> resetEarningsGCash(DocumentReference documentReference) async {
    try {
      await documentReference.update({'earningsGCash': 0});
      // Show success message or perform any other actions after resetting earningsGCash
      print('EarningsGCash reset successfully');
    } catch (error) {
      print('Error resetting earningsGCash: $error');
      // Handle error
    }
  }
}
