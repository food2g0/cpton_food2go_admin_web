import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/colors.dart';

class BigContainer extends StatefulWidget {
  const BigContainer({Key? key}) : super(key: key);

  @override
  _BigContainerState createState() => _BigContainerState();
}
class _BigContainerState extends State<BigContainer> {
  late Stream<QuerySnapshot> _ordersStream;

  @override
  void initState() {
    super.initState();
    _ordersStream = fetchAllOrdersStream();
  }

  Stream<QuerySnapshot> fetchAllOrdersStream() {
    return FirebaseFirestore.instance.collection('orders').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors().white,
        borderRadius: BorderRadius.circular(10),
      ),
      width: MediaQuery.of(context).size.width * 0.4,
      height: 300, // Set the fixed height for the container
      child: StreamBuilder<QuerySnapshot>(
        stream: _ordersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No orders available.'),
            );
          }

          List<DocumentSnapshot> orders = snapshot.data!.docs;
          return SingleChildScrollView(
            child: SizedBox(
              height: 500, // Same as the container's height
              child: Column(
                children: [
                  // _buildDataTableHeader(), // Create DataTable header
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Order ID', style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, color: AppColors().black))),
                        const DataColumn(label: Text('Total Amount', style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold))),
                        const DataColumn(label: Text('Status', style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold))),
                        const DataColumn(label: Text('Payment Details', style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold))),
                      ],
                      rows: orders.map((order) {
                        return _buildDataRow(order);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  DataRow _buildDataRow(DocumentSnapshot order) {
    String orderId = order.id;
    String totalAmount = order['totalAmount'].toString();
    String status = order['status'].toString();
    String paymentDetails = order['paymentDetails'].toString();

    return DataRow(cells: [
      DataCell(Text(orderId, style: const TextStyle(fontFamily: "Poppins"))),
      DataCell(Text(totalAmount, style: const TextStyle(fontFamily: "Poppins"))),
      DataCell(Text(status, style: const TextStyle(fontFamily: "Poppins"))),
      DataCell(Text(paymentDetails, style: const TextStyle(fontFamily: "Poppins"))),
    ]);
  }
}






