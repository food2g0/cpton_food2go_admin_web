 // Make sure to import the correct file for order details screen
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TotalOrderScreen extends StatefulWidget {
  const TotalOrderScreen({Key? key}) : super(key: key);

  @override
  State<TotalOrderScreen> createState() => _TotalOrderScreenState();
}

class _TotalOrderScreenState extends State<TotalOrderScreen> {
  late Future<List<Map<String, dynamic>>> ordersData;
  late TextEditingController blockingReasonController;
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    ordersData = fetchOrdersData();
    blockingReasonController = TextEditingController();
    searchController = TextEditingController();
  }

  Future<List<Map<String, dynamic>>> fetchOrdersData() async {
    CollectionReference orders = FirebaseFirestore.instance.collection('orders');
    QuerySnapshot querySnapshot = await orders.where('status', isEqualTo: 'ToPay').get();

    print('Number of documents with status ToPay: ${querySnapshot.docs.length}');

    return querySnapshot.docs.map((DocumentSnapshot<Object?> doc) {
      print('Order ID: ${doc['orderId']}');
      print('Status: ${doc['status']}');
      print('orderBy: ${doc['orderBy']}');
      print('paymentDetails: ${doc['paymentDetails']}');
      print('referenceNumber: ${doc['referenceNumber']}');

      return {
        'Order By': doc['orderBy'],
        'Order ID': doc['orderId'],
        'Seller ID': doc['sellerUID'],
        'Payment Method': doc['paymentDetails'],
        'Reference Number': doc['referenceNumber'],
        'Total Amount': doc['totalAmount'],
        'Status': doc['status'],
      };
    }).toList();
  }


  Future<void> updateOrderStatus(String orderId) async {
    CollectionReference orders = FirebaseFirestore.instance.collection('orders');

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Order Status'),
          content: Column(
            children: [
              Text('Enter the reason for updating the status:'),
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
                await orders.doc(orderId).update({
                  'status': 'normal',
                  'blockingReason': blockingReasonController.text,
                });

                blockingReasonController.clear();
                Navigator.of(context).pop();
              },
              child: Text('Update Status'),
            ),
          ],
        );
      },
    );
  }


  List<Map<String, dynamic>> filterOrders(String query, List<Map<String, dynamic>> orders) {
    return orders.where((order) =>
    order['orderBy'].toLowerCase().contains(query.toLowerCase()) ||
        order['orderId'].toLowerCase().contains(query.toLowerCase())).toList();
  }

  void viewOrderDetails(Map<String, dynamic> orderData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Order Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Order ID: ${orderData['Order ID'] ?? 'N/A'}'),
              Text('Payment Method: ${orderData['Payment Method'] ?? 'N/A'}'),
              Text('Reference Number: ${orderData['Reference Number'] ?? 'N/A'}'),
              Text('Total Amount: ${orderData['Total Amount'] ?? 'N/A'}'),
              Text('Status: ${orderData['Status'] ?? 'N/A'}'),
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


  void navigateToOrderDetailScreen(Map<String, dynamic> orderData) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => OrderDetailScreen(orderData: orderData),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Total Orders'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Search Orders'),
                    content: TextField(
                      controller: searchController,
                      decoration: InputDecoration(labelText: 'Enter order by or order ID'),
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
                            ordersData = fetchOrdersData().then(
                                  (orders) => filterOrders(searchController.text, orders),
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
        future: ordersData,
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
              child: Text('No orders found.'),
            );
          } else {
            return Align(
              alignment: Alignment.topCenter,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Order ID')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Total Amount')),
                  DataColumn(label: Text('Reference Number')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: snapshot.data!.map<DataRow>((orderData) {
                  return DataRow(
                    cells: [
                      DataCell(
                        InkWell(
                          onTap: () {
                            viewOrderDetails(orderData);
                          },
                          child: Text(' ${orderData['Order ID'] ?? 'N/A'}'), // Use null-aware operator
                        ),
                      ),
                      DataCell(      Text(' ${orderData['Status'] ?? 'N/A'}')), // Use null-aware operator
                      DataCell(      Text(' ${orderData['Total Amount'] ?? 'N/A'}')), // Use null-aware operator
                      DataCell(      Text(' ${orderData['Reference Number'] ?? 'N/A'}')), // Use null-aware operator
                      DataCell(
                        Row(
                          children: [
                            SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                navigateToOrderDetailScreen(orderData);
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
