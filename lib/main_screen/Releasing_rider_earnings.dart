import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_admin_web/theme/colors.dart';
import 'package:flutter/material.dart';

class ReleasingRiderEarnings extends StatefulWidget {
  const ReleasingRiderEarnings({Key? key});

  @override
  State<ReleasingRiderEarnings> createState() => _ReleasingRiderEarningsState();
}

class _ReleasingRiderEarningsState extends State<ReleasingRiderEarnings> {
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
          stream: FirebaseFirestore.instance.collection('riders').snapshots(),
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
                    DataColumn(label: Text('Rider ID')),
                    DataColumn(label: Text('Rider Name')),
                    DataColumn(label: Text('Amount')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    String riderUID = document.id;
                    String riderName = data['riderName'] ?? '';
                    double originalAmount = data['earningsGCash'] ?? 0.0;
                    double deductedAmount = originalAmount * 0.7; // Subtracting 10%
                    return DataRow(
                      cells: [
                        DataCell(Text(riderUID)),
                        DataCell(Text(riderName)),
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
