import 'package:cpton_food2go_admin_web/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TurnOverEarnings extends StatefulWidget {
  const TurnOverEarnings({Key? key}) : super(key: key);

  @override
  State<TurnOverEarnings> createState() => _TurnOverEarningsState();
}

class _TurnOverEarningsState extends State<TurnOverEarnings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text('Turnover Earnings',
        style: TextStyle(fontFamily: "Poppins"),),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('turnover').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          List<DataRow> rows = [];
          snapshot.data!.docs.forEach((document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            DataRow row = DataRow(cells: [
              DataCell(Text(data['userId'].toString())),
              DataCell(Text(data['timestamp'].toDate().toString())),
              DataCell(Text('\$${data['amount'].toStringAsFixed(2)}')),
              DataCell(Text(data['referenceNumber'].toString())),
              DataCell(Text(data['status'].toString())),
              DataCell(
                ElevatedButton(
                  onPressed: () {
                    // Handle action when "Receive" button is pressed
                    updateStatus(document.id, 'Received'); // Update status to "Received"
                  },
                  child: Text('Receive'),
                ),
              ),

            ]);
            rows.add(row);
          });

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('User ID')),
                  DataColumn(label: Text('Time Stamp')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Reference Number')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Action')), // New column for "Receive" button
             // New column for "Not Receive" button
                ],
                rows: rows,
              ),
            ),
          );
        },
      ),
    );
  }

  void updateStatus(String documentId, String newStatus) {
    FirebaseFirestore.instance.collection('turnover').doc(documentId).update({
      'status': newStatus,
    }).then((_) {
      // Handle success
      print('Status updated successfully');
    }).catchError((error) {
      // Handle error
      print('Error updating status: $error');
    });
  }
}
